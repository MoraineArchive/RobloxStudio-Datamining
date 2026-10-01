local UtilityRoot = script.Parent
local UIBlox = UtilityRoot.Parent
local Packages = UIBlox.Parent
local Foundation = require(Packages.Foundation)
local FFlagFoundationFontFaceMigration = Foundation.Utility.Flags.FoundationFontFaceMigration
local getTextSizeOffset = Foundation.Utility.getTextSizeOffset
local TextService = game:GetService("TextService")

return function(font: Font | Enum.Font)
	if FFlagFoundationFontFaceMigration then
		local offset = getTextSizeOffset()
		return offset ~= nil, offset
	else
		local success, newTextSizeOffset = pcall(function()
			return TextService:GetTextSize("", 0, font :: Enum.Font, Vector2.new(math.huge, math.huge)).Y
		end)
		return success, newTextSizeOffset
	end
end
