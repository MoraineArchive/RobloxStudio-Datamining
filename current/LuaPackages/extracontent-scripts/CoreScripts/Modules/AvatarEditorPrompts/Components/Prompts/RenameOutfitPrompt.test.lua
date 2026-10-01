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

local AvatarEditorPromptsPolicy = require(AvatarEditorPrompts.AvatarEditorPromptsPolicy)

describe("RenameOutfitPrompt", function()
	it("should create and destroy without errors", function()
		local RenameOutfitPrompt = require(script.Parent.RenameOutfitPrompt)

		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})

		store:dispatch(OpenPrompt(PromptType.RenameOutfit, {
			outfitId = 123,
			outfitName = "Outfit Name",
		}))

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			PolicyProvider = Roact.createElement(AvatarEditorPromptsPolicy.Provider, {
				policy = { AvatarEditorPromptsPolicy.Mapper },
			}, {
				ThemeProvider = UnitTestHelpers.createStyleProvider({
					RenameOutfitPrompt = Roact.createElement(RenameOutfitPrompt),
				}),
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
