local CorePackages = game:GetService("CorePackages")
local LocalizationService = game:GetService("LocalizationService")

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UIBlox = require(CorePackages.Packages.UIBlox)
local ReactSceneUnderstanding = require(CorePackages.Packages.ReactSceneUnderstanding)
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider
local RobloxAppEnums = require(CorePackages.Workspace.Packages.RobloxAppEnums)
local DesignTokenProvider = require(CorePackages.Workspace.Packages.Style).DesignTokenProvider
local MenuNavigationPromptTokenMapper = require(script.Parent.Parent.TokenMappers.MenuNavigationPromptTokenMapper)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local FFlagTopBarRefactor = require(CorePackages.Workspace.Packages.InExperienceTopBar).Flags.FFlagTopBarRefactor
if not FFlagTopBarRefactor then
	it = it.skip :: typeof(JestGlobals.it)
end

local defaultStyle = {
	themeName = "dark",
	fontName = "gotham",
	deviceType = RobloxAppEnums.DeviceType.Console,
}

local Reducer = require(script.Parent.Parent.Reducer)

describe("TopBarApp", function()
	it("should create and destroy without errors", function()
		local TopBarApp = require(script.Parent.TopBarApp)

		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			LocalizationProvider = Roact.createElement(LocalizationProvider, {
				localization = Localization.new(LocalizationService.RobloxLocaleId),
			}, {
				StyleProvider = Roact.createElement(UIBlox.App.Style.AppStyleProvider, {
					style = defaultStyle,
				}, {
					DesignTokenProvider = Roact.createElement(DesignTokenProvider, {
						tokenMappers = {
							MenuNavigationPrompt = MenuNavigationPromptTokenMapper,
						},
					}, {
						SceneAnalysisProvider = Roact.createElement(
							ReactSceneUnderstanding.SceneAnalysisProvider,
							{},
							{
								TopBarApp = Roact.createElement(TopBarApp),
							}
						),
					}),
				}),
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
