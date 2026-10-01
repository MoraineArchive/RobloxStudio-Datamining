local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local Signals = require(CorePackages.Packages.Signals)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect
local afterEach = JestGlobals.afterEach

local PlayerList = script.Parent.Parent.Parent
local TestProviders = require(PlayerList.TestProviders)
local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

local PlayerListPackage = require(CorePackages.Workspace.Packages.PlayerList)
local FFlagPlayerListTwoTabsOnLegacy = PlayerListPackage.Flags.FFlagPlayerListTwoTabsOnLegacy
local PlatformLeaderboardStoreContext = PlayerListPackage.Common.PlatformLeaderboardStoreContext
local PlayerListVisibilityStore = PlayerListPackage.Common.PlayerListVisibilityStore

local PlayerListDisplayView = require(script.Parent.PlayerListDisplayView)

local function makeProps(overrides: { [string]: any }?)
	local base = {
		entrySizeX = 220,
		screenSizeY = 768,
		teamList = {
			iterateData = function() end,
			getCount = function()
				return 0
			end,
		},
		teamListCount = 0,
		gameStatsCount = 0,
		playerIconInfo = {},
		playerRelationship = {},
		isVisible = true,
		isMinimized = false,
		dismissPlayerList = function() end,
		dropDownVisible = false,
		dropDownPlayer = nil,
		isSmallTouchDevice = false,
		isDirectionalPreferred = false,
		isUsingGamepad = false,
	}
	if overrides then
		for k, v in pairs(overrides) do
			base[k] = v
		end
	end
	return base
end

local function makeStore(hasActive)
	local getter, setter = Signals.createSignal(hasActive)
	return {
		getHasActiveLeaderboard = getter,
		setHasActiveLeaderboard = setter,
	}
end

-- Foundation's tab strip also renders a "ScrollingFrame", so scope the lookup to the
-- player list's own clipping frame.
local function findServerScrollingFrame(container: Instance)
	local clippingFrame = container:FindFirstChild("ScrollingFrameClippingFrame", true)
	return clippingFrame and clippingFrame:FindFirstChild("ScrollingFrame")
end

local function mountWith(props: any, platformStore: any?, layoutValues: any?)
	local container = Instance.new("Frame")
	local viewElement = Roact.createElement(PlayerListDisplayView, props)
	local contentElement: any
	if platformStore ~= nil then
		contentElement = Roact.createElement(PlatformLeaderboardStoreContext.Provider, {
			value = platformStore,
		}, { View = viewElement })
	else
		contentElement = viewElement
	end
	local inner = Roact.createElement(TestProviders, {
		layoutValues = layoutValues,
	}, { View = contentElement })
	local instance = Roact.mount(inner, container, "Root")
	return instance, container
end

afterEach(function()
	PlayerListVisibilityStore.reset()
end)

it("mounts and unmounts without errors", function()
	local instance, container = mountWith(makeProps())
	Roact.unmount(instance)
	container:Destroy()
end)

if FFlagPlayerListTwoTabsOnLegacy then
	it("tab strip absent when no platform store in context", function()
		local instance, container = mountWith(makeProps())
		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeNil()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("tab strip renders when store reports active leaderboard", function()
		local instance, container = mountWith(makeProps(), makeStore(true))
		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeDefined()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("tab strip absent when store reports no active leaderboard", function()
		local instance, container = mountWith(makeProps(), makeStore(false))
		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeNil()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("mounts the tabs when a platform leaderboard becomes active", function()
		local store = makeStore(false)
		local instance, container = mountWith(makeProps(), store)
		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeNil()

		Roact.act(function()
			store.setHasActiveLeaderboard(true)
		end)

		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeDefined()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("keeps the server list mounted when a platform leaderboard becomes active", function()
		local store = makeStore(false)
		local instance, container = mountWith(makeProps(), store)
		local scrollingFrameBefore = findServerScrollingFrame(container)
		expect(scrollingFrameBefore).toBeDefined()

		Roact.act(function()
			store.setHasActiveLeaderboard(true)
		end)

		expect(findServerScrollingFrame(container)).toBe(scrollingFrameBefore)
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("ScrollingFrame in tree for default server tab with active store", function()
		local instance, container = mountWith(makeProps(), makeStore(true))
		expect(findServerScrollingFrame(container)).toBeDefined()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("ScrollingFrame in tree when isVisible is false with active store", function()
		local instance, container = mountWith(makeProps({ isVisible = false }), makeStore(true))
		expect(findServerScrollingFrame(container)).toBeDefined()
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("desktop panel keeps scroll list width when flag is on", function()
		local instance, container = mountWith(makeProps())
		local outerFrame = container:FindFirstChild("View", true)
		expect(outerFrame).toBeDefined()
		if outerFrame and outerFrame:IsA("Frame") then
			expect(outerFrame.Size.X.Scale).toEqual(1)
			expect(outerFrame.Size.X.Offset).toEqual(-1)
		end
		Roact.unmount(instance)
		container:Destroy()
	end)

	it("mounts on tenfoot layout without error", function()
		local instance, container =
			mountWith(makeProps({ isDirectionalPreferred = true }), makeStore(true), CreateLayoutValues(true))
		expect(container:FindFirstChild("LeaderboardTabs", true)).toBeDefined()
		Roact.unmount(instance)
		container:Destroy()
	end)
end
