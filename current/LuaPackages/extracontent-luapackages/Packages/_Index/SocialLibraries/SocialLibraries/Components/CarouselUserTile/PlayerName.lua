--! DEPRECATED please use the version found in LuaApps SocialCommon
local SocialLibraries = script:FindFirstAncestor("SocialLibraries")
local dependencies = require(SocialLibraries.dependencies)
local Roact = dependencies.Roact
local llama = dependencies.llama

local UIBlox = dependencies.UIBlox
local StyledTextLabel = UIBlox.App.Text.StyledTextLabel
local Style = UIBlox.Style

local getTextHeight = require(script.Parent.getTextHeight)
local StyleTypes = require(script.Parent.StyleTypes)
local Constants = require(script.Parent.Constants)

local FFlagFoundationFontFaceMigration = dependencies.Foundation.Utility.Flags.FoundationFontFaceMigration

export type Props = {
	name: string,
	width: number,
	layoutOrder: number?,
}

local defaultProps = {
	width = Constants.TILE_SIZE,
}

local PlayerName = function(passedProps: Props)
	local props: Props = llama.Dictionary.join(defaultProps, passedProps)

	return Style.withStyle(function(style)
		local theme: StyleTypes.Theme = style.Theme
		local font: StyleTypes.FontStyle = style.Font
		local fontSize = font.BaseSize * font.CaptionHeader.RelativeSize
		local textHeight = if FFlagFoundationFontFaceMigration
			then fontSize
			else getTextHeight(props.name, font.CaptionHeader.Font :: Enum.Font, fontSize)

		return Roact.createElement(StyledTextLabel, {
			layoutOrder = props.layoutOrder,
			text = props.name,
			fontStyle = font.CaptionHeader,
			colorStyle = theme.TextEmphasis,
			size = UDim2.fromOffset(props.width, textHeight),
			textTruncate = Enum.TextTruncate.AtEnd,
			textXAlignment = Enum.TextXAlignment.Left,
			textYAlignment = Enum.TextYAlignment.Center,
			lineHeight = 1,
			fluidSizing = false,
			richText = false,
		})
	end)
end

return PlayerName
