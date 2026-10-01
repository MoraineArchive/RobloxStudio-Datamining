local CorePackages = game:GetService("CorePackages")
local GuiService = game:GetService("GuiService")

local React = require(CorePackages.Packages.React)

--[[
	Resolves the in-experience menu's close button and reports whether it currently holds
	selection.

	The report renders inside an isolated FocusRoot, so directional input cannot leave it.
	The close button belongs to the menu's header, above the report, so reaching it takes
	both of these: a target for the root's upward escape, and a signal telling the root to
	stop auto-focusing itself while the button is selected.
]]
local function useSettingsHubCloseButton(
	getSettingsHubRef: (() -> any)?,
	isReportTabVisible: boolean
): (GuiObject?, boolean)
	local closeButton, setCloseButton = React.useState(nil :: GuiObject?)
	local isSelected, setIsSelected = React.useState(false)

	-- Re-read on open instead of once on mount: this page is built while the hub is still
	-- assembling its header, so the button does not exist yet when the report first mounts.
	React.useEffect(function()
		local hub = if getSettingsHubRef then getSettingsHubRef() else nil
		setCloseButton(if hub then hub.PageTitleCloseButton else nil)
	end, { getSettingsHubRef, isReportTabVisible } :: { unknown })

	React.useEffect(function(): (() -> ())?
		if not closeButton then
			setIsSelected(false)
			return nil
		end

		local function updateIsSelected()
			setIsSelected(GuiService.SelectedCoreObject == closeButton)
		end

		updateIsSelected()
		local connection = GuiService:GetPropertyChangedSignal("SelectedCoreObject"):Connect(updateIsSelected)

		return function()
			connection:Disconnect()
		end
	end, { closeButton })

	return closeButton, isSelected
end

return useSettingsHubCloseButton
