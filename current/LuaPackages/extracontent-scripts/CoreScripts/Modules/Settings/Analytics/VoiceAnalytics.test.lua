--!nonstrict
local CorePackages = game:GetService("CorePackages")

local LuaSocialLibrariesDeps = require(CorePackages.Packages.LuaSocialLibrariesDeps)
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeAll = JestGlobals.beforeAll
local afterEach = JestGlobals.afterEach
local Mock = LuaSocialLibrariesDeps.Mock
local VoiceAnalytics = require(script.Parent.VoiceAnalytics)

local c: any = {}

beforeAll(function()
	c.Mock = Mock
	c.analytics = {
		EventStream = {
			setRBXEventStream = jest.fn(),
		},
	}
	c.voiceAnalytics = VoiceAnalytics.new(c.analytics.EventStream, "VoiceAnalytics.test")
end)

describe("VoiceAnalytics", function()
	afterEach(function()
		jest.clearAllMocks()
	end)

	describe("onMuteSelf", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onMuteSelf()

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onUnmuteSelf", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onUnmuteSelf()

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onMuteAll", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onMuteAll()

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onUnmuteAll", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onUnmuteAll()

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onMutePlayer", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onMutePlayer(123)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onUnmutePlayer", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onUnmutePlayer(123)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onToggleMuteAll", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onToggleMuteAll(true)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
		it("SHOULD fire when false", function()
			c.voiceAnalytics:onToggleMuteAll(false)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onToggleMuteSelf", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onToggleMuteSelf(true)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
		it("SHOULD fire when false", function()
			c.voiceAnalytics:onToggleMuteSelf(false)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)

	describe("onToggleMutePlayer", function()
		it("SHOULD fire", function()
			c.voiceAnalytics:onToggleMutePlayer(123, true)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
		it("SHOULD fire when false", function()
			c.voiceAnalytics:onToggleMutePlayer(234, false)

			expect(c.analytics.EventStream.setRBXEventStream).toHaveBeenCalledTimes(1)
		end)
	end)
end)
