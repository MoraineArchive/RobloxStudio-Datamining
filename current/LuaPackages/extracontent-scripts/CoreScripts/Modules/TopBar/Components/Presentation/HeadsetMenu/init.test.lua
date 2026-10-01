--!nonstrict
local CorePackages = game:GetService("CorePackages")
local VRService = game:GetService("VRService")

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local Cryo = require(CorePackages.Packages.Cryo)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local jestExpect = JestGlobals.expect

local waitForEvents = require(CorePackages.Workspace.Packages.TestUtils).DeferredLuaHelpers.waitForEvents

local Modules = game:GetService("CoreGui").RobloxGui.Modules
local act = Roact.act

local MockVRService = require(Modules.TestHelpers.MockVRService)
local MockGuiService = require(Modules.TestHelpers.MockGuiService)

local CoreGuiCommon = require(CorePackages.Workspace.Packages.CoreGuiCommon)
local FFlagTopBarSignalizeScreenSize = CoreGuiCommon.Flags.FFlagTopBarSignalizeScreenSize

local Reducer = require(Modules.TopBar.Reducer)

local HeadsetMenu = require(script.Parent)

local function getMountableTreeAndStore(props)
	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ThemeProvider = UnitTestHelpers.createStyleProvider({
			HeadsetMenu = Roact.createElement(HeadsetMenu, props or {}),
		}),
	})

	return element, store
end

local requiredProps = {
	screenSize = if FFlagTopBarSignalizeScreenSize then nil else Vector2.new(800, 600),
}

it("should mount and unmount with required props", function()
	-- VRDeviceAvailable was introduced from v501, so test would fail on older version
	-- because VRService prop is optional.
	local success, _ = pcall(function()
		return VRService.VRDeviceAvailable
	end)

	if not success then
		return
	end

	local element = getMountableTreeAndStore(requiredProps)

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should mount and unmount with all props", function()
	local element = getMountableTreeAndStore(Cryo.Dictionary.join(requiredProps, {
		vrService = MockVRService.new(),
		guiService = MockGuiService.new(),
	}))

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should set InGameMenu open for HeadsetDisconnectedDialog when headset device got disconnected", function()
	local mockVRService = MockVRService.new()
	local mockGuiService = MockGuiService.new()

	local fullProps = Cryo.Dictionary.join(requiredProps, {
		vrService = mockVRService,
		guiService = mockGuiService,
	})

	local element = getMountableTreeAndStore(fullProps)
	local instance = Roact.mount(element)

	jestExpect(mockVRService.VRDeviceAvailable).toBe(true)
	jestExpect(mockGuiService.MenuIsOpen).toBe(false)

	act(function()
		mockVRService:toggleHeadsetConnectionState()
		Roact.update(instance, getMountableTreeAndStore(fullProps))
	end)
	waitForEvents.act()

	jestExpect(mockVRService.VRDeviceAvailable).toBe(false)
	jestExpect(mockGuiService.MenuIsOpen).toBe(true)

	Roact.unmount(instance)
end)
