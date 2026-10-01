local SocialLibraries = script:FindFirstAncestor("SocialLibraries")
local dependencies = require(SocialLibraries.dependencies)
local Text = dependencies.Text

return function(text: string, font: Enum.Font, fontSize: number): number
	return Text.GetTextHeight(text, font, fontSize)
end
