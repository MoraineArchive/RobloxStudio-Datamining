local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local Signals = require(CorePackages.Packages.Signals)
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local PlayerList = script.Parent.Parent.Parent
local Reducers = PlayerList.Reducers
local Reducer = require(Reducers.Reducer)
local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

local Actions = PlayerList.Actions
local SetTenFootInterface = require(Actions.SetTenFootInterface)
local SetScreenSize = require(Actions.SetScreenSize)

local TestProviders = require(PlayerList.TestProviders)

local PlayerListPackage = require(CorePackages.Workspace.Packages.PlayerList)
local Constants = PlayerListPackage.Common.Constants
local PlatformLeaderboardStoreContext = PlayerListPackage.Common.PlatformLeaderboardStoreContext
local FFlagPlayerListFixPlatformLeaderboardSizing = PlayerListPackage.Flags.FFlagPlayerListFixPlatformLeaderboardSizing
local FFlagPlayerListTwoTabsOnLegacy = PlayerListPackage.Flags.FFlagPlayerListTwoTabsOnLegacy

local PlayerListApp = require(script.Parent.PlayerListApp)

it("should create and destroy without errors", function()
	local element = Roact.createElement(TestProviders, {
		store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		}),
	}, {
		PlayerListApp = Roact.createElement(PlayerListApp, {
			setLayerCollectorEnabled = function() end,
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

if FFlagPlayerListFixPlatformLeaderboardSizing and FFlagPlayerListTwoTabsOnLegacy then
	it("uses the platform leaderboard minimum size without leaderstats", function()
		local getHasActiveLeaderboard = Signals.createSignal(true)
		local element = Roact.createElement(TestProviders, {
			store = Rodux.Store.new(Reducer, nil, {
				Rodux.thunkMiddleware,
			}),
		}, {
			PlatformLeaderboardProvider = Roact.createElement(PlatformLeaderboardStoreContext.Provider, {
				value = {
					getHasActiveLeaderboard = getHasActiveLeaderboard,
				},
			}, {
				PlayerListApp = Roact.createElement(PlayerListApp, {
					setLayerCollectorEnabled = function() end,
				}),
			}),
		})
		local container = Instance.new("Frame")
		local instance = Roact.mount(element, container)

		local sizeConstraint = container:FindFirstChildWhichIsA("UISizeConstraint", true)
		expect(sizeConstraint).toBeDefined()
		expect((sizeConstraint :: UISizeConstraint).MinSize).toEqual(
			Vector2.new(Constants.PLATFORM_PANEL_WIDTH, Constants.LEGACY_PLATFORM_PANEL_MIN_HEIGHT)
		)

		-- The container has to reach the platform width on its own, otherwise the rows inside it
		-- stay at their leaderstat-derived width while the constraint stretches the background.
		local root = (sizeConstraint :: UISizeConstraint).Parent :: Frame
		expect(root.Size.X.Offset).toEqual(Constants.PLATFORM_PANEL_WIDTH)

		Roact.unmount(instance)
		container:Destroy()
	end)

	it("keeps the platform minimum width in sync with the rows on narrow viewports", function()
		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})
		-- Narrow enough that the screen-fit clamp shrinks the rows below the platform width.
		store:dispatch(SetScreenSize(500, 1000))

		local getHasActiveLeaderboard = Signals.createSignal(true)
		local element = Roact.createElement(TestProviders, {
			store = store,
		}, {
			PlatformLeaderboardProvider = Roact.createElement(PlatformLeaderboardStoreContext.Provider, {
				value = {
					getHasActiveLeaderboard = getHasActiveLeaderboard,
				},
			}, {
				PlayerListApp = Roact.createElement(PlayerListApp, {
					setLayerCollectorEnabled = function() end,
				}),
			}),
		})
		local container = Instance.new("Frame")
		local instance = Roact.mount(element, container)

		local sizeConstraint = container:FindFirstChildWhichIsA("UISizeConstraint", true)
		expect(sizeConstraint).toBeDefined()
		local root = (sizeConstraint :: UISizeConstraint).Parent :: Frame
		expect(root.Size.X.Offset < Constants.PLATFORM_PANEL_WIDTH).toEqual(true)
		expect((sizeConstraint :: UISizeConstraint).MinSize.X).toEqual(root.Size.X.Offset)

		Roact.unmount(instance)
		container:Destroy()
	end)
end

describe("PlayerListTenFoot", function()
	it("should create and destroy without errors tenfoot", function()
		local store = Rodux.Store.new(Reducer, nil, {
			Rodux.thunkMiddleware,
		})
		store:dispatch(SetTenFootInterface(true))

		local element = Roact.createElement(TestProviders, {
			store = store,
			layoutValues = CreateLayoutValues(true),
		}, {
			PlayerListApp = Roact.createElement(PlayerListApp, {
				setLayerCollectorEnabled = function() end,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
