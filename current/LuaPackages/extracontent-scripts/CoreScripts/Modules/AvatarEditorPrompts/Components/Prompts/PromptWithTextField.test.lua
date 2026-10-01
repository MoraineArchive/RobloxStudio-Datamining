local CorePackages = game:GetService("CorePackages")
local Modules = game:GetService("CoreGui").RobloxGui.Modules

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UIBlox = require(CorePackages.Packages.UIBlox)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local Rhodium = require(CorePackages.Packages.Dev.Rhodium)
local Element = Rhodium.Element
local XPath = Rhodium.XPath
local withServices = require(Modules.CoreScriptsRhodiumTest.Helpers.withServices)

local AvatarEditorPrompts = script.Parent.Parent.Parent
local Reducer = require(AvatarEditorPrompts.Reducer)

local ButtonType = UIBlox.App.Button.Enum.ButtonType

local buttonStackInfo = {
	buttons = {
		{
			props = {
				onActivated = function() end,
				text = "no",
			},
		},
		{
			buttonType = ButtonType.PrimarySystem,
			props = {
				isDisabled = true,
				onActivated = function() end,
				text = "okay",
			},
		},
	},
}

describe("PromptWithTextField", function()
	it("should create and destroy without errors", function()
		local PromptWithTextField = require(script.Parent.PromptWithTextField)

		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			ThemeProvider = UnitTestHelpers.createStyleProvider({
				PromptWithTextField = Roact.createElement(PromptWithTextField, {
					fieldText = "test",
					onFieldTextUpdated = function() end,

					-- Props passed to Alert
					title = "hello",
					bodyText = "world!",
					buttonStackInfo = buttonStackInfo,
				}),
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should call onFieldTextUpdated when text is sent", function()
		local PromptWithTextField = require(script.Parent.PromptWithTextField)

		local updatedText

		local wrappedComponent = function()
			return UnitTestHelpers.createStyleProvider({
				PromptWithTextField = Roact.createElement(PromptWithTextField, {
					fieldText = "Hello",
					onFieldTextUpdated = function(text)
						updatedText = text
					end,

					-- Props passed to Alert
					title = "hello",
					bodyText = "world!",
					buttonStackInfo = buttonStackInfo,
				}),
			})
		end

		local initalStoreState = {
			screenSize = Vector2.new(800, 800),
		}

		withServices(function(path)
			path = XPath.new(path)
			local baseWidget = Element.new(path)
			local rootInstance = baseWidget:waitForRbxInstance(1)
			expect(rootInstance).never.toBeNil()

			local textboxInstance = rootInstance:FindFirstChildWhichIsA("TextBox", true)
			expect(textboxInstance).never.toBeNil()
			expect(textboxInstance.Text).toBe("Hello")

			textboxInstance.Text = textboxInstance.Text .. " world!"

			wait()

			expect(updatedText).toBe("Hello world!")
		end, wrappedComponent, Reducer, initalStoreState, nil)
	end)
end)
