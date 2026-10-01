local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Components = script.Parent.Parent
local PlayerList = Components.Parent
local TestProviders = require(PlayerList.TestProviders)

local DropDownButton = require(script.Parent.DropDownButton)

local FFlagAllowDisplayingFoundationIconsForDropdown =
	require(PlayerList.Flags.FFlagAllowDisplayingFoundationIconsForDropdown)

describe("DropDownButton", function()
	it("should mount and unmount without errors", function()
		local element = Roact.createElement(TestProviders, {}, {
			DropDownButton = Roact.createElement(DropDownButton, {
				contentVisible = true,
				buttonTransparency = 0,
				text = "test",
				layoutOrder = 1,
				icon = if FFlagAllowDisplayingFoundationIconsForDropdown then "Flag" else "",
				lastButton = false,
				forceShowOptions = false,
				screenSizeX = 800,
				screenSizeY = 600,
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
