local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider

local PublishAvatarPromptFolder = script.Parent.Parent
local Reducer = require(PublishAvatarPromptFolder.Reducer)
local OpenPublishAvatarPrompt = require(PublishAvatarPromptFolder.Actions.OpenPublishAvatarPrompt)
local PromptType = require(PublishAvatarPromptFolder.PromptType)
local OpenValidationErrorModal = require(PublishAvatarPromptFolder.Actions.OpenValidationErrorModal)

describe("ValidationErrorModal", function()
	it("should create and destroy without errors", function()
		local PublishAvatarPrompt =
			require(PublishAvatarPromptFolder.Components.PublishAvatarPrompt.PublishAvatarPrompt)

		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})

		store:dispatch(
			OpenPublishAvatarPrompt(PromptType.PublishAvatar, "12345", { Enum.ExperienceAuthScope.CreatorAssetsCreate })
		)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			ThemeProvider = UnitTestHelpers.createStyleProvider({
				LocalizationProvider = Roact.createElement(LocalizationProvider, {
					localization = Localization.new("en-us"),
				}, {
					PublishAvatarPrompt = Roact.createElement(PublishAvatarPrompt, {
						screenSize = Vector2.new(1920, 1080),
					}),
				}),
			}),
		})
		store:dispatch(OpenValidationErrorModal("error"))

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
