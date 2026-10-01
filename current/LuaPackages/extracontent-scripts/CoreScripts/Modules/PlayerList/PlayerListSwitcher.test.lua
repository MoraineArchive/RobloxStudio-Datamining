local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local UIBlox = require(CorePackages.Packages.UIBlox)
local Foundation = require(CorePackages.Packages.Foundation)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach

local PlayerList = script.Parent
local Reducer = require(PlayerList.Reducers.Reducer)
local TestProviders = require(PlayerList.TestProviders)
local PlayerListInitialVisibleState = require(PlayerList.PlayerListInitialVisibleState)

local SetSmallTouchDevice = require(PlayerList.Actions.SetSmallTouchDevice)
local SetPlayerListVisibility = require(PlayerList.Actions.SetPlayerListVisibility)

local FFlagPlayerListKeepModalHiddenOnRemount = require(PlayerList.Flags.FFlagPlayerListKeepModalHiddenOnRemount)
local FFlagPlayerListPersistVisibility = require(PlayerList.Flags.FFlagPlayerListPersistVisibility)

local PlayerListSwitcher = require(PlayerList.PlayerListSwitcher)

local appStyleForUiModeStyleProvider = {
	themeName = Foundation.Enums.ColorMode.Dark,
	fontName = UIBlox.App.Style.Constants.FontName.Gotham,
}

-- Mounts the switcher the way PlayerListController does, then tears it down so the
-- assertion reads the visibility the mount lifecycle committed to the store.
local function mountSwitcherWith(store)
	local element = Roact.createElement(TestProviders, {
		store = store,
	}, {
		Switcher = Roact.createElement(PlayerListSwitcher, {
			appStyleForUiModeStyleProvider = appStyleForUiModeStyleProvider,
			setLayerCollectorEnabled = function() end,
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end

local function makeStore(isSmallTouchDevice, setVisible)
	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})
	store:dispatch(SetSmallTouchDevice(isSmallTouchDevice))
	store:dispatch(SetPlayerListVisibility(setVisible))
	return store
end

describe("PlayerListSwitcher", function()
	-- The non-modal reducer path persists visibility into GameSettings, which is
	-- process-wide state shared with every other spec in the run.
	local originalPlayerListVisible = nil

	beforeEach(function()
		if FFlagPlayerListPersistVisibility then
			originalPlayerListVisible = UserSettings().GameSettings.PlayerListVisible
		end
	end)

	afterEach(function()
		if FFlagPlayerListPersistVisibility then
			UserSettings().GameSettings.PlayerListVisible = originalPlayerListVisible
		end
	end)

	if FFlagPlayerListKeepModalHiddenOnRemount then
		it("keeps the modal leaderboard hidden when a CoreGui re-enable remounts it", function()
			local store = makeStore(true, true)

			mountSwitcherWith(store)

			expect(store:getState().displayOptions.setVisible).toBe(false)
			expect(store:getState().displayOptions.isVisible).toBe(false)
		end)
	end

	it("defers to the shared initial visible state on the non-modal layout", function()
		local store = makeStore(false, false)

		mountSwitcherWith(store)

		expect(store:getState().displayOptions.setVisible).toBe(PlayerListInitialVisibleState())
	end)
end)
