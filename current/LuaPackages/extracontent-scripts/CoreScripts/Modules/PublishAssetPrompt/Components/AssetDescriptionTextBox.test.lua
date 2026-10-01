--!nonstrict
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect
local jest = JestGlobals.jest

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)
local waitForEvents = require(CorePackages.Workspace.Packages.TestUtils).DeferredLuaHelpers.waitForEvents

local PublishAssetPromptFolder = script.Parent.Parent
local Reducer = require(PublishAssetPromptFolder.Reducer)

local AssetDescriptionTextBox = require(script.Parent.AssetDescriptionTextBox)

it("should create and destroy without errors", function()
	local ref = Roact.createRef()

	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = UnitTestHelpers.createStyleProvider({
			AssetDescriptionTextBox = Roact.createElement(AssetDescriptionTextBox, {
				onAssetDescriptionUpdated = function() end,
				descriptionTextBoxRef = ref,
			}),
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should call onAssetDescriptionUpdated when the user enters text", function()
	local textChangedMock, textChangedFn = jest.fn()
	local ref = Roact.createRef()

	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = UnitTestHelpers.createStyleProvider({
			TextEntryField = Roact.createElement(AssetDescriptionTextBox, {
				onAssetDescriptionUpdated = textChangedFn,
				descriptionTextBoxRef = ref,
			}),
		}),
	})

	local folder = Instance.new("Folder")

	local instance = Roact.mount(element, folder)

	local textBox = folder:FindFirstChildWhichIsA("TextBox", true)
	textBox.Text = "Hello world"

	waitForEvents.act()
	expect(textChangedMock).toHaveBeenCalled()

	Roact.unmount(instance)
end)
