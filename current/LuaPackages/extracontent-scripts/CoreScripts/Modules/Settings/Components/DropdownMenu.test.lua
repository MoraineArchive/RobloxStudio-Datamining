local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local UIBlox = require(CorePackages.Packages.UIBlox)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local DropdownMenu = require(script.Parent.DropdownMenu)

it("should mount and unmount without errors", function()
	local element = Roact.createElement(UIBlox.App.Style.AppStyleProvider, {}, {
		DropdownMenu = Roact.createElement(DropdownMenu, {
			buttonSize = UDim2.new(1, 0, 1, 0),
			dropdownList = {},
			selectedIndex = 1,
			onSelection = function() end,
			layoutOrder = 1,
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)
