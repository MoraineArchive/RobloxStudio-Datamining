local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local AvatarEditorPrompts = script.Parent.Parent.Parent
local Reducer = require(AvatarEditorPrompts.Reducer)
local PromptType = require(AvatarEditorPrompts.PromptType)
local OpenPrompt = require(AvatarEditorPrompts.Actions.OpenPrompt)

describe("SetFavoritePrompt", function()
	it("should create and destroy without errors", function()
		local SetFavoritePrompt = require(script.Parent.SetFavoritePrompt)

		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})

		store:dispatch(OpenPrompt(PromptType.SetFavorite, {
			itemId = 1337,
			itemType = Enum.AvatarItemType.Bundle,
			itemName = "Cool Bundle",
			shouldFavorite = true,
		}))

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			ThemeProvider = UnitTestHelpers.createStyleProvider({
				SetFavoritePrompt = Roact.createElement(SetFavoritePrompt),
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
