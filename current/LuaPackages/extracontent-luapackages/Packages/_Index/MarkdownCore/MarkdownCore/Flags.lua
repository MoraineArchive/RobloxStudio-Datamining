local Packages = script:FindFirstAncestor("MarkdownCore").Parent

local SafeFlags = require(Packages.SafeFlags)

return {
	FFlagMarkdownAssistantParity = SafeFlags.createGetFFlag("MarkdownAssistantParity")(),
}
