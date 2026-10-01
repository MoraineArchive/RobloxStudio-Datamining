local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local initializeShopMenuController = require(script.Parent.initializeShopMenuController)

local SHOP_MENU_KEY = "in_experience_shop"

type SetMenuCall = {
	menuIsOpen: boolean,
	menuKey: string,
}

-- Fakes for the Shop's open-state signal and the one engine service the controller
-- drives. `MappedSignal:connect` fires once on connect, which the fake mirrors.
local function createDependencies()
	local isOpenChanged: ((boolean) -> ())? = nil
	local setMenuCalls: { SetMenuCall } = {}

	local isShopOpen = {
		connect = function(_self, callback: (boolean) -> ())
			isOpenChanged = callback
			callback(false)
			return { disconnect = function() end }
		end,
	}

	local guiService = {
		SetMenuIsOpen = function(_self, menuIsOpen: boolean, menuKey: string)
			table.insert(setMenuCalls, { menuIsOpen = menuIsOpen, menuKey = menuKey })
		end,
	}

	return {
		guiService = guiService,
		isShopOpen = isShopOpen,
		setMenuCalls = setMenuCalls,
		setShopOpen = function(value: boolean)
			local callback = isOpenChanged :: any
			callback(value)
		end,
	}
end

local function initialize(dependencies)
	initializeShopMenuController(dependencies.guiService :: any, dependencies.isShopOpen)
end

describe("initializeShopMenuController", function()
	it("SHOULD hold the Shop menu open for the duration of the Shop window being open", function()
		local dependencies = createDependencies()
		initialize(dependencies)

		dependencies.setShopOpen(true)
		dependencies.setShopOpen(false)

		expect(dependencies.setMenuCalls).toEqual({
			{ menuIsOpen = false, menuKey = SHOP_MENU_KEY },
			{ menuIsOpen = true, menuKey = SHOP_MENU_KEY },
			{ menuIsOpen = false, menuKey = SHOP_MENU_KEY },
		})
	end)
end)
