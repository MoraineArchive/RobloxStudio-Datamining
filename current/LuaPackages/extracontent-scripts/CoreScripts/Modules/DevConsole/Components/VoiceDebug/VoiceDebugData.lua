local CircularBuffer = require(script.Parent.Parent.Parent.CircularBuffer)
local Signal = require(script.Parent.Parent.Parent.Signal)
local VoiceDebugFieldMeta = require(script.Parent.VoiceDebugFieldMeta)

local voiceChatService = game:GetService("VoiceChatService")

local MAX_DATASET_COUNT = tonumber(settings():GetFVariable("NewDevConsoleMaxGraphCount")) or 60

export type StatsData = {
	rttMs: number?,
	incomingStreams: number?,
	outgoingStreams: number?,
	incomingJitterMs: number?,
	outgoingJitterMs: number?,
	incomingPackets: number?,
	outgoingPackets: number?,
	incomingPacketsLost: number?,
	outgoingPacketsLost: number?,
	incomingPacketsDiscarded: number?,
	outgoingPacketsDiscarded: number?,
	jitterBufferDelayMs: number?,
	incomingFecPackets: number?,
	incomingFecPacketsDiscarded: number?,
	incomingBytes: number?,
	outgoingBytes: number?,
	incomingBitrateKbps: number?,
	outgoingBitrateKbps: number?,
	outgoingCodec: string?,
	incomingLossPercent: number?,
	[string]: any,
}

export type IceCandidateData = {
	candidate: string,
	sdpMid: string,
	sdpMLineIndex: number,
}

export type SeriesEntry = {
	max: number,
	min: number,
	dataSet: any,
}

export type SeriesMap = { [string]: SeriesEntry }

export type ConnectivityData = {
	iceGatheringStatePublish: string?,
	iceGatheringStateSubscribe: string?,
	iceConnectionStatePublish: string?,
	iceConnectionStateSubscribe: string?,
	signalingStatePublish: string?,
	signalingStateSubscribe: string?,
	rebootCount: number?,
	icePublishCandidates: { IceCandidateData }?,
	iceSubscribeCandidates: { IceCandidateData }?,
	sdpPublishOffer: string?,
	sdpPublishRemoteAnswer: string?,
	sdpSubscribeRemoteOffer: string?,
	sdpSubscribeAnswer: string?,
}

local getFFlagVoiceDebugConsoleV2 = require(script.Parent.GetFFlagVoiceDebugConsoleV2)

local function parseCodecFromSdp(sdp: string?): string?
	if not sdp or sdp == "" then
		return nil
	end
	local payload, codec, clockRate, channels = string.match(sdp, "a=rtpmap:(%d+) (%a+)/(%d+)/(%d+)")
	if not codec or not clockRate or not channels then
		return nil
	end
	return string.format("%s/%s/%s", codec, clockRate, channels)
end

local function computeBitrateKbps(currentBytes: number?, prevBytes: number?, dtSeconds: number?): number?
	if
		type(currentBytes) ~= "number"
		or type(prevBytes) ~= "number"
		or type(dtSeconds) ~= "number"
		or dtSeconds <= 0
	then
		return nil
	end
	if currentBytes < prevBytes then
		return nil
	end
	return (currentBytes - prevBytes) * 8 / dtSeconds / 1000
end

local function computeLossPercent(packets: number?, packetsLost: number?): number?
	if type(packets) ~= "number" or type(packetsLost) ~= "number" then
		return nil
	end
	local total = packets + packetsLost
	if total <= 0 then
		return nil
	end
	return packetsLost / total * 100
end

-- packets/packetsLost from lastVoiceChatStats() are cumulative session totals (same as the
-- incomingBytes/outgoingBytes computeBitrateKbps diffs above), so computeLossPercent needs a delta
-- since the previous sample, not the raw totals -- otherwise a short loss burst early in a call
-- permanently inflates the session-average loss percent for everything after it.
local function deltaSince(current: number?, prev: number?): number?
	if type(current) ~= "number" or type(prev) ~= "number" or current < prev then
		return nil
	end
	return current - prev
end

local VoiceDebugData = {}
VoiceDebugData.__index = VoiceDebugData

function VoiceDebugData.new()
	local self = {}
	setmetatable(self, VoiceDebugData)

	self._statsUpdated = Signal.new()
	self._statsData = {} :: StatsData
	self._series = {} :: SeriesMap
	self._connectivityData = {} :: ConnectivityData
	self._isRunning = false
	return self
end

function VoiceDebugData:Signal()
	return self._statsUpdated
end

function VoiceDebugData:getCurrentData(): StatsData
	return self._statsData
end

function VoiceDebugData:getSeries(): SeriesMap
	return self._series
end

function VoiceDebugData:isRunning()
	return self._isRunning
end

function VoiceDebugData:getConnectivity(): ConnectivityData
	return self._connectivityData
end

function VoiceDebugData:_updateSeriesValue(key: string, value: number, time: number)
	if not self._series[key] then
		local newBuffer = CircularBuffer.new(MAX_DATASET_COUNT)
		newBuffer:push_back({
			value = value,
			time = time,
		})
		self._series[key] = {
			max = value,
			min = value,
			dataSet = newBuffer,
		}
		return
	end

	local dataEntry = self._series[key]
	local currMax = dataEntry.max
	local currMin = dataEntry.min

	local update = {
		value = value,
		time = time,
	}

	local overwrittenEntry = dataEntry.dataSet:push_back(update)

	if overwrittenEntry and (currMax == overwrittenEntry.value or currMin == overwrittenEntry.value) then
		-- The evicted entry held one (or, for a flat series, both) of the cached bounds -- rescan the
		-- remaining buffer for both bounds together from a single iterator pass. Recomputing them from
		-- two separate passes over one shared iterator is a bug: the first pass exhausts it, so the
		-- second silently sees no data and falls back to whatever the first pass just computed.
		local iter = dataEntry.dataSet:iterator()
		local dat = iter:next()
		local newMax = dat and dat.value
		local newMin = dat and dat.value
		while dat do
			newMax = dat.value < newMax and newMax or dat.value
			newMin = newMin < dat.value and newMin or dat.value
			dat = iter:next()
		end
		if currMax == overwrittenEntry.value then
			currMax = newMax
		end
		if currMin == overwrittenEntry.value then
			currMin = newMin
		end
	end

	dataEntry.max = currMax < value and value or currMax
	dataEntry.min = currMin < value and currMin or value
end

function VoiceDebugData:start()
	if voiceChatService and not self._statsListenerConnection then
		self._statsListenerConnection = (voiceChatService :: any).VoiceChatStatsCollected:Connect(function()
			self._statsData = (voiceChatService :: any):lastVoiceChatStats()
			-- Already redacted natively (see lastVoiceChatConnectivity()'s implementation) before it
			-- ever reaches Lua -- no client-side redaction needed here.
			self._connectivityData = (voiceChatService :: any):lastVoiceChatConnectivity()

			local time = os.time()

			if getFFlagVoiceDebugConsoleV2() then
				local clockNow = os.clock()
				local dt = self._prevBytesClock and (clockNow - self._prevBytesClock) or nil
				self._statsData.incomingBitrateKbps =
					computeBitrateKbps(self._statsData.incomingBytes, self._prevIncomingBytes, dt)
				self._statsData.outgoingBitrateKbps =
					computeBitrateKbps(self._statsData.outgoingBytes, self._prevOutgoingBytes, dt)
				self._prevIncomingBytes = self._statsData.incomingBytes
				self._prevOutgoingBytes = self._statsData.outgoingBytes
				self._prevBytesClock = clockNow

				self._statsData.outgoingCodec = parseCodecFromSdp(self._connectivityData.sdpPublishOffer)

				self._statsData.incomingLossPercent = computeLossPercent(
					deltaSince(self._statsData.incomingPackets, self._prevIncomingPackets),
					deltaSince(self._statsData.incomingPacketsLost, self._prevIncomingPacketsLost)
				)
				self._prevIncomingPackets = self._statsData.incomingPackets
				self._prevIncomingPacketsLost = self._statsData.incomingPacketsLost
			end

			for key, value in self._statsData do
				local meta = VoiceDebugFieldMeta[key]
				if meta and meta.plottable and type(value) == "number" then
					self:_updateSeriesValue(key, value, time)
				end
			end

			self._statsUpdated:Fire(self._statsData)
		end)
		self._isRunning = true
	end
end

function VoiceDebugData:stop()
	self._isRunning = false
	if self._statsListenerConnection then
		self._statsListenerConnection:Disconnect()
		self._statsListenerConnection = nil :: any
	end
	-- Clear so the first sample after a resume is treated as having no previous sample (nil deltas),
	-- rather than being averaged/diffed over the paused interval.
	self._prevBytesClock = nil
	self._prevIncomingBytes = nil
	self._prevOutgoingBytes = nil
	self._prevIncomingPackets = nil
	self._prevIncomingPacketsLost = nil
end

VoiceDebugData._parseCodecFromSdp = parseCodecFromSdp
VoiceDebugData._computeBitrateKbps = computeBitrateKbps
VoiceDebugData._computeLossPercent = computeLossPercent
VoiceDebugData._deltaSince = deltaSince

return VoiceDebugData
