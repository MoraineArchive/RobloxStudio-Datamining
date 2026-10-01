--! DEPRECATED please use the version found in LuaApps SocialCommon
local SocialLibraries = script:FindFirstAncestor("SocialLibraries")
local dependencies = require(SocialLibraries.dependencies)
local Constants = require(script.Parent.Constants)
local getTextHeight = require(script.Parent.getTextHeight)
local StyleTypes = require(script.Parent.StyleTypes)

local FFlagFoundationFontFaceMigration = dependencies.Foundation.Utility.Flags.FoundationFontFaceMigration

type Config = {
	font: StyleTypes.FontStyle,
	maxLinesNumber: number?,
	nameTopPadding: number?,
	contextualTopPadding: number?,
}

return if FFlagFoundationFontFaceMigration
	then function(config: Config)
		local nameTopPadding = config and config.nameTopPadding or Constants.NAME_TOP_PADDING
		local contextualTopPadding = config and config.contextualTopPadding or Constants.CONTEXTUAL_TOP_PADDING
		local numberOfLines = config and config.maxLinesNumber or Constants.LINES_MAX

		local font = config.font
		local displayName = font.BaseSize * font.CaptionHeader.RelativeSize
		local contextualInfoHeight = font.BaseSize * font.CaptionBody.RelativeSize * numberOfLines

		return nameTopPadding + displayName + contextualTopPadding + contextualInfoHeight
	end
	else function(config: Config)
		local nameTopPadding = config and config.nameTopPadding or Constants.NAME_TOP_PADDING
		local contextualTopPadding = config and config.contextualTopPadding or Constants.CONTEXTUAL_TOP_PADDING
		local numberOfLines = config and config.maxLinesNumber or Constants.LINES_MAX

		local font = config.font
		local displayName = getTextHeight(
			"",
			font.CaptionHeader.Font :: Enum.Font,
			font.BaseSize * font.CaptionHeader.RelativeSize
		)
		local contextualInfoHeight = getTextHeight(
			"",
			font.CaptionBody.Font :: Enum.Font,
			font.BaseSize * font.CaptionBody.RelativeSize
		) * numberOfLines

		return nameTopPadding + displayName + contextualTopPadding + contextualInfoHeight
	end
