export type ParsedIceCandidate = {
	candidateType: string?,
	protocol: string?,
	priority: string?,
	component: string?,
}

local EMPTY: ParsedIceCandidate = { candidateType = nil, protocol = nil, priority = nil, component = nil }

local function parseIceCandidate(candidate: string?): ParsedIceCandidate
	if candidate == nil or candidate == "" then
		return EMPTY
	end

	local tokens = {}
	for token in string.gmatch(candidate, "%S+") do
		table.insert(tokens, token)
	end

	local candidateType = nil
	for i, token in tokens do
		if token == "typ" then
			candidateType = tokens[i + 1]
			break
		end
	end

	if candidateType == nil then
		return EMPTY
	end

	return {
		candidateType = candidateType,
		protocol = tokens[3],
		priority = tokens[4],
		component = tokens[2],
	}
end

return parseIceCandidate
