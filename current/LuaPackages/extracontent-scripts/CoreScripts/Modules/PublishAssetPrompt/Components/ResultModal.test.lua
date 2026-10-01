--!nonstrict
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local PublishAssetPromptFolder = script.Parent.Parent
local Reducer = require(PublishAssetPromptFolder.Reducer)

local ResultModal = require(script.Parent.ResultModal)

local EngineFeatureEnableImagePublish = game:GetEngineFeature("EnableImagePublish")

-- Mirrors ResultModal: clients without EnableImagePublish only have the pre-rename enum.
local PromptResult = if EngineFeatureEnableImagePublish
	then Enum.PromptCreatePlatformContentResult
	else (Enum :: any).PromptPublishAssetResult

it("should show Publish succeeded", function()
	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = UnitTestHelpers.createStyleProvider({
			ResultModal = Roact.createElement(ResultModal, {
				resultModalType = PromptResult.Success,
				screenSize = Vector2.new(0, 0),
			}),
		}),
	})

	local folder = Instance.new("Folder")

	local instance = Roact.mount(element, folder)

	Roact.unmount(instance)
end)

it("should show publish failed ", function()
	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = UnitTestHelpers.createStyleProvider({
			ResultModal = Roact.createElement(ResultModal, {
				resultModalType = PromptResult.UploadFailed,
				screenSize = Vector2.new(0, 0),
			}),
		}),
	})

	local folder = Instance.new("Folder")

	local instance = Roact.mount(element, folder)

	Roact.unmount(instance)
end)
