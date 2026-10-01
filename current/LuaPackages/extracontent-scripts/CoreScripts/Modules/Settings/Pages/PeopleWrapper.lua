--[[
Wraps old People.lua page and its new refactored version that uses the
Settings Framework.
Flag flip will determine whether the old or new page is attached.
]]

local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local LocalizationService = game:GetService("LocalizationService")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Modules = RobloxGui.Modules

-- React
local React = require(CorePackages.Packages.React)
local ReactRoblox = require(CorePackages.Packages.ReactRoblox)

-- Flags
local FFlagRefactorPeoplePage = require(Modules.Settings.Flags.FFlagRefactorPeoplePage)
local FFlagRelocateMobileMenuButtons = require(Modules.Settings.Flags.FFlagRelocateMobileMenuButtons)
local FIntRelocateMobileMenuButtonsVariant = require(Modules.Settings.Flags.FIntRelocateMobileMenuButtonsVariant)

-- Chrome check
local Chrome = RobloxGui.Modules.Chrome
local ChromeEnabled = require(CorePackages.Workspace.Packages.Chrome).Enabled()
local LocalStore = if ChromeEnabled then require(Chrome.ChromeShared.Service.LocalStore) else nil

-- Modules
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider
local Signals = require(CorePackages.Packages.Signals)
local SignalsReact = require(CorePackages.Packages.SignalsReact)
local SettingsPageFactory = require(Modules.Settings.SettingsPageFactory)
local SettingsShowSignal = require(CorePackages.Workspace.Packages.CoreScriptsCommon).SettingsShowSignal
local locales = Localization.new(LocalizationService.RobloxLocaleId)
local BuilderIcons = require(CorePackages.Packages.BuilderIcons)
local BlockingModalScreen = require(Modules.Settings.Components.Blocking.BlockingModalScreen)
local migrationLookup = BuilderIcons.Migration["uiblox"]
local PeopleService = require(CorePackages.Workspace.Packages.PeopleService)
local InExperienceSideSheet = require(CorePackages.Workspace.Packages.InExperienceSideSheet)
local FFlagSideSheetOpenPeoplePage = InExperienceSideSheet.Flags.FFlagSideSheetOpenPeoplePage

-- Focus Navigation
local FocusNavigationUtils = require(CorePackages.Workspace.Packages.FocusNavigationUtils)
local FocusRoot = FocusNavigationUtils.FocusRoot
local FocusNavigableSurfaceIdentifierEnum = FocusNavigationUtils.FocusNavigableSurfaceIdentifierEnum
local CoreScriptsRootProvider = require(CorePackages.Workspace.Packages.CoreScriptsRoactCommon).CoreScriptsRootProvider

local Constants
if FFlagRefactorPeoplePage() then
	Constants = require(CorePackages.Workspace.Packages.PeopleReactView).Constants
end

-- Flags
local PeopleFlags = PeopleService.getService("Flags")
local GetFFlagAddPeoplePageCardLayout = PeopleFlags.GetFFlagAddPeoplePageCardLayout
local GetFFlagPeoplePageLazyRenderCards = PeopleFlags.GetFFlagPeoplePageLazyRenderCards
local FFlagEnablePeopleListLazyRender = PeopleFlags.FFlagEnablePeopleListLazyRender
local FFlagPeopleCardsEnableVirtualizedGrid = PeopleFlags.FFlagPeopleCardsEnableVirtualizedGrid
local FFlagPeoplePageDismissVolumePopoverOnScrollOutOfView =
	PeopleFlags.FFlagPeoplePageDismissVolumePopoverOnScrollOutOfView
local FFlagPeoplePageFlipVolumePopoverToFitViewport =
	PeopleFlags.FFlagPeoplePageFlipVolumePopoverToFitViewport
local FFlagPeoplePageDismissCardMenuOnScrollOutOfView =
	PeopleFlags.FFlagPeoplePageDismissCardMenuOnScrollOutOfView

local tree: ReactRoblox.RootType? = nil
local getDisplayed, setDisplayed = Signals.createSignal(false)

local function PeopleFocusRoot(props)
	return React.createElement(FocusRoot, {
		surfaceIdentifier = FocusNavigableSurfaceIdentifierEnum.RouterView,
		isAutoFocusRoot = false ,
	}, props.children)
end

-- Returns GameSettings Page with Settings Framework
local function createPeoplePage()
	local PeopleReactViewPackage = require(CorePackages.Workspace.Packages.PeopleReactView)
	local PeopleReactView = PeopleReactViewPackage.PeopleReactView
	local SideSheetFocusContext = PeopleReactViewPackage.SideSheetFocusContext
	local PeopleService = require(CorePackages.Workspace.Packages.PeopleService)
	local PeoplePage = SettingsPageFactory:CreateNewPage()

	------ TAB CUSTOMIZATION -------
	PeoplePage.TabHeader.Name = Constants.PEOPLEPAGE.TAB_HEADER.NAME
	PeoplePage.Page.Name = Constants.PEOPLEPAGE.PAGE_ID
	local icon = migrationLookup[Constants.PEOPLEPAGE.TAB_HEADER.ICON]
	PeoplePage.TabHeader.TabLabel.Icon.Text = icon.name
	PeoplePage.TabHeader.TabLabel.Icon.FontFace = BuilderIcons.Font[icon.variant]
	PeoplePage.TabHeader.TabLabel.Title.Text = locales:Format(Constants.PEOPLEPAGE.TAB_HEADER.TEXT)

	-- Register the SettingsHub instance with the PeopleService
	local SettingsHubService = PeopleService.getService("SettingsHubService")
	SettingsHubService.register(PeoplePage)

	function PeoplePage:CreateMenuButtonsContainer()
		SettingsHubService.setShowMenuButtonsContainer(true)
	end

	if FFlagRelocateMobileMenuButtons and FIntRelocateMobileMenuButtonsVariant == 2 then
		function PeoplePage:UnmountMenuButtonsContainer()
			SettingsHubService.setShowMenuButtonsContainer(false)
		end
	end

	------ PAGE CUSTOMIZATION -------
	local function createReactTree()
		if tree then
			return
		end

		local scrollingFrame = if GetFFlagPeoplePageLazyRenderCards()
				or FFlagEnablePeopleListLazyRender
				or FFlagPeopleCardsEnableVirtualizedGrid
				or FFlagPeoplePageDismissVolumePopoverOnScrollOutOfView
				or FFlagPeoplePageFlipVolumePopoverToFitViewport
				or FFlagPeoplePageDismissCardMenuOnScrollOutOfView
			then PeoplePage.Page:FindFirstAncestorWhichIsA("ScrollingFrame")
			else nil

		-- Closes over the page-scoped locals built above, so hoisting it would mean threading all of
		-- them through props. Pre-existing on master; only surfaced here because this PR edits lines
		-- inside the component.
		-- lute-lint-ignore(noNestedReactDefinitions)
		local function PeopleConditionalView()
			-- lute-lint-ignore(rulesOfHooks)
			local displayed = SignalsReact.useSignalState(getDisplayed)
			-- lute-lint-ignore(rulesOfHooks)
			local isSideSheetVisible = if FFlagSideSheetOpenPeoplePage
				then SignalsReact.useSignalState(InExperienceSideSheet.getSideSheetVisibility)
				else false
			-- lute-lint-ignore(rulesOfHooks)
			local didSideSheetOpenWithPeoplePage = if FFlagSideSheetOpenPeoplePage
				then SignalsReact.useSignalState(InExperienceSideSheet.getDidSideSheetOpenWithPeoplePage)
				else false

			local People: React.ReactElement<any, any>? = if displayed
				then React.createElement(CoreScriptsRootProvider, {}, {
					LocalizationProvider = React.createElement(LocalizationProvider, {
						localization = locales,
					}, {
						FocusRoot = React.createElement(PeopleFocusRoot, {}, {
							PeopleReactView = React.createElement(PeopleReactView, {
								blockingModalScreen = BlockingModalScreen,
								blockingFlags = {},
								scrollingFrame = if GetFFlagPeoplePageLazyRenderCards()
										or FFlagEnablePeopleListLazyRender
										or FFlagPeopleCardsEnableVirtualizedGrid
										or FFlagPeoplePageDismissVolumePopoverOnScrollOutOfView
										or FFlagPeoplePageFlipVolumePopoverToFitViewport
										or FFlagPeoplePageDismissCardMenuOnScrollOutOfView
									then scrollingFrame
									else nil,
								chromeEnabled = ChromeEnabled,
								getUniversesExposedTo = if GetFFlagAddPeoplePageCardLayout() and LocalStore
									then LocalStore.getUniversesExposedTo
									else nil,
								addUniverseToExposureList = if GetFFlagAddPeoplePageCardLayout() and LocalStore
									then LocalStore.addUniverseToExposureList
									else nil,
								minimumCardWidth = if FFlagSideSheetOpenPeoplePage
										and isSideSheetVisible
										and didSideSheetOpenWithPeoplePage
									then Constants.PEOPLEPAGE.PEOPLE_CARDS.SIDE_SHEET_MINIMUM_CARD_WIDTH
									else nil,
							}),
						}),
					}),
				})
				else nil

			if FFlagSideSheetOpenPeoplePage and People then
				-- There is only a sheet to hand focus back to when the page came up beside it, which a
				-- screen with no room for the pairing never does.
				People = React.createElement(SideSheetFocusContext.Provider, {
					value = isSideSheetVisible and didSideSheetOpenWithPeoplePage,
				}, {
					People = People,
				})
			end

			return People
		end

		tree = ReactRoblox.createRoot(PeoplePage.Page)
		if tree then
			tree:render(React.createElement(PeopleConditionalView))
		end
	end

	PeoplePage.Displayed.Event:Connect(function()
		if not getDisplayed(false) then
			createReactTree()
			setDisplayed(true)
		end
			local menuContainer = PeoplePage.Page:FindFirstAncestor("MenuContainer")
			if menuContainer then
				local bottomFrame = menuContainer:FindFirstChild("BottomButtonFrame", true)
				if bottomFrame then
					bottomFrame.SelectionBehaviorUp = Enum.SelectionBehavior.Escape
				end
			end
	end)
	SettingsShowSignal:connect(function(isOpen)
		if not isOpen then
			setDisplayed(false)
		end
	end)

	PeoplePage.Page.Size = UDim2.new(1, 0, 0, 0)
	PeoplePage.Page.AutomaticSize = Enum.AutomaticSize.Y

	return PeoplePage
end

-- FFlag switch for the new people page
if FFlagRefactorPeoplePage() then
	return createPeoplePage()
end
return require(Modules.Settings.Pages.Players)
