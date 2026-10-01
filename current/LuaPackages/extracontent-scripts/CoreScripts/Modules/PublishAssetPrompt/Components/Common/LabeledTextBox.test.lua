local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local UIBlox = require(CorePackages.Packages.UIBlox)

local LabeledTextBox = require(script.Parent.LabeledTextBox)

describe("LabeledTextBox", function()
	it("should create and destroy without errors", function()
		local element = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
			LabeledTextBox = Roact.createElement(LabeledTextBox, {
				labelText = "Test",
				onTextUpdated = function() end,
				textBoxRef = Roact.createRef(),
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
