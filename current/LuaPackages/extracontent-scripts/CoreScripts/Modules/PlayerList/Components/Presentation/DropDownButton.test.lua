local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Components = script.Parent.Parent
local Connection = Components.Connection
local LayoutValues = require(Connection.LayoutValues)
local LayoutValuesProvider = LayoutValues.Provider

local PlayerList = Components.Parent
local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

local Reducers = PlayerList.Reducers
local Reducer = require(Reducers.Reducer)

local DropDownButton = require(script.Parent.DropDownButton)

local FFlagAllowDisplayingFoundationIconsForDropdown =
	require(PlayerList.Flags.FFlagAllowDisplayingFoundationIconsForDropdown)

describe("DropDownButton", function()
	it("should mount and unmount without errors", function()
		local layoutValues = CreateLayoutValues(false)
		local store = Rodux.Store.new(Reducer)

		local element = Roact.createElement(RoactRodux.StoreProvider, {
			store = store,
		}, {
			LayoutValuesProvider = Roact.createElement(LayoutValuesProvider, {
				layoutValues = layoutValues,
			}, {
				ThemeProvider = UnitTestHelpers.createStyleProvider({
					DropDownButton = Roact.createElement(DropDownButton, {
						text = "test",
						layoutOrder = 1,
						icon = if FFlagAllowDisplayingFoundationIconsForDropdown then "Flag" else "",
						lastButton = false,
						forceShowOptions = false,
						screenSizeX = 800,
						screenSizeY = 600,
					}),
				}),
			}),
		})
		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
