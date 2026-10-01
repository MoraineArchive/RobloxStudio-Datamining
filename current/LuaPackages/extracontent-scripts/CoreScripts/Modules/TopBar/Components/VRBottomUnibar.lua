local CorePackages = game:GetService("CorePackages")

local Foundation = require(CorePackages.Packages.Foundation)
local React = require(CorePackages.Packages.React)
local VrSpatialUi = require(CorePackages.Workspace.Packages.VrSpatialUi)
local PanelType = VrSpatialUi.Constants.PanelType
local Panel3DInSpatialUI = VrSpatialUi.Panel3DInSpatialUI
local Modules = script.Parent.Parent.Parent
local Unibar = require(Modules.Chrome.ChromeShared.Unibar)
local MenuIcon = require(Modules.TopBar.Components.Presentation.MenuIcon)
local MenuIconV2 = require(Modules.TopBar.ComponentsV2.MenuIcon)
local useSelector = require(CorePackages.Workspace.Packages.RoactUtils).Hooks.RoactRodux.useSelector

local CoreGuiCommon = require(CorePackages.Workspace.Packages.CoreGuiCommon)
local FFlagTopBarSignalizeKeepOutAreas = CoreGuiCommon.Flags.FFlagTopBarSignalizeKeepOutAreas

local InExperienceTopBar = require(CorePackages.Workspace.Packages.InExperienceTopBar)
local ExperienceAgeRatingBadge = require(CorePackages.Workspace.Packages.InExperienceTopBar.ExperienceAgeRatingBadge)
local FFlagExperienceAgeRatingBadge = InExperienceTopBar.Flags.FFlagExperienceAgeRatingBadge
local FFlagShowGameAgeRating = require(CorePackages.Workspace.Packages.SharedFlags).FFlagShowGameAgeRating
local useAgeRatingLayout = FFlagExperienceAgeRatingBadge and FFlagShowGameAgeRating
local FFlagTopBarRefactor = InExperienceTopBar.Flags.FFlagTopBarRefactor

type Props = {
	showBadgeOver12: boolean?,
	voiceChatServiceManager: any?,
	voiceEnabled: boolean?,
	voiceState: any?,
}

local function MenuIconWrapper(props: any)
	local keepOutAreasStore 
	if FFlagTopBarSignalizeKeepOutAreas then 
		keepOutAreasStore = CoreGuiCommon.Stores.GetKeepOutAreasStore(false)
	end

	local menuOpen = useSelector(function(state)
		return if state and state.displayOptions then state.displayOptions.menuOpen else false
	end)
	local iconScale = if menuOpen then 1.5 else 1
	return if FFlagTopBarRefactor 
		then React.createElement(MenuIconV2, {
			showBadgeOver12 = props.showBadgeOver12,
		}) 
		else React.createElement(MenuIcon, {
			layout = props.layout,
			iconScale = iconScale,
			showBadgeOver12 = props.showBadgeOver12,
			onAreaChanged = if FFlagTopBarSignalizeKeepOutAreas then keepOutAreasStore.setKeepOutArea else nil,
		})
end

local function VRBottomUnibar(props: Props)
	local persistentAgeRating = useAgeRatingLayout and props.showBadgeOver12 == true
	local controlsVisible, setControlsVisible
	local onControlsTransparencyChanged
	if FFlagExperienceAgeRatingBadge and FFlagShowGameAgeRating then
		controlsVisible, setControlsVisible = React.useBinding(true)
		onControlsTransparencyChanged = React.useCallback(function(rbx: CanvasGroup)
			setControlsVisible(rbx.GroupTransparency < 1)
		end, { setControlsVisible })
	end
	if not Panel3DInSpatialUI then
		return nil :: React.ReactElement<any, any>?
	end
	return React.createElement(Panel3DInSpatialUI, {
		panelType = PanelType.BottomBar,
		keepVisibleWhenTopBarHidden = if useAgeRatingLayout then persistentAgeRating else nil,
		controlsVisible = if useAgeRatingLayout then controlsVisible else nil,
		renderFunction = function(panelSize: Vector2)
			local controls = React.createElement(if useAgeRatingLayout then "CanvasGroup" else "Frame", {
				Name = if useAgeRatingLayout then "AnimatablePanelManagedContent" else nil,
				Visible = if useAgeRatingLayout then controlsVisible else nil,
				[React.Change.GroupTransparency] = onControlsTransparencyChanged,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = if useAgeRatingLayout
					then UDim2.fromOffset(0, panelSize.Y)
					elseif FFlagTopBarRefactor then UDim2.new(1, 0, 0, 0)
					else UDim2.new(1, 0, 1, 0),
				AutomaticSize = if useAgeRatingLayout
					then Enum.AutomaticSize.X
					elseif FFlagTopBarRefactor then Enum.AutomaticSize.Y
					else nil,
			}, {
				ListLayout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 8),
				}),
				MenuIconFrame = if FFlagTopBarRefactor 
				then React.createElement(Foundation.View, {
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					aspectRatio = {
						AspectRatio = 1,
						AspectType = Enum.AspectType.ScaleWithParentSize,
						DominantAxis = Enum.DominantAxis.Height,
					},
				}, {
					MenuIcon = React.createElement(MenuIconWrapper, {
						layout = 1,
						showBadgeOver12 = props.showBadgeOver12 and not persistentAgeRating,
					}),
				}) 
				else React.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
				}, {
					MenuIcon = React.createElement(MenuIconWrapper, {
						layout = 1,
						showBadgeOver12 = props.showBadgeOver12 and not persistentAgeRating,
					}),
				}),
				UnibarFrame = React.createElement("Frame", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
				}, {
					Unibar = React.createElement(Unibar, {
						layoutOrder = 1,
						onAreaChanged = function() end,
						onMinWidthChanged = function() end,
					}),
				}),
			})
			if not useAgeRatingLayout then
				return controls
			end
			-- Only controls belong to the panel manager's fading group.
			return React.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
			}, {
				Layout = React.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 8),
				}),
				Controls = controls,
				AgeRating = if persistentAgeRating
					then React.createElement(ExperienceAgeRatingBadge, {
						universeId = tostring(game.GameId),
						layoutOrder = 1,
					})
					else nil,
			})
		end,
		requireCanvasGroup = not useAgeRatingLayout,
	})
end

return React.memo(VRBottomUnibar)
