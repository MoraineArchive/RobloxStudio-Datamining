local Players = game:GetService("Players")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local Components = script.Parent.Parent

local PlayerList = Components.Parent
local Reducers = PlayerList.Reducers
local Reducer = require(Reducers.Reducer)
local Actions = PlayerList.Actions
local SetTenFootInterface = require(Actions.SetTenFootInterface)
local SetSmallTouchDevice = require(Actions.SetSmallTouchDevice)
local TestProviders = require(PlayerList.TestProviders)

local PlayerIcon = require(script.Parent.PlayerIcon)

it("should create and destroy without errors", function()
	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.FriendRequestReceived,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors for a subscription player", function()
	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors for a place owner", function()
	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = true,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors for a blocked player", function()
	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = true,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors for a following player", function()
	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = true,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors with foundation subscription icon layout values", function()
	local CreateLayoutValues = require(PlayerList.CreateLayoutValues)
	local Foundation = require(CorePackages.Packages.Foundation)
	local layoutValues = CreateLayoutValues(false)
	rawset(layoutValues, "SubscriptionIcon", {
		isFoundationIcon = true,
		name = Foundation.Enums.IconName.RobloxPlus,
	})

	local element = Roact.createElement(TestProviders, {
		layoutValues = layoutValues,
	}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors on the mobile path", function()
	local store = Rodux.Store.new(Reducer, nil, { Rodux.thunkMiddleware })
	store:dispatch(SetSmallTouchDevice(true))

	local element = Roact.createElement(TestProviders, { store = store }, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.FriendRequestReceived,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors for a blocked player on the mobile path", function()
	local store = Rodux.Store.new(Reducer, nil, { Rodux.thunkMiddleware })
	store:dispatch(SetSmallTouchDevice(true))

	local element = Roact.createElement(TestProviders, { store = store }, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = true,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors with foundation subscription icon layout values on mobile", function()
	local CreateLayoutValues = require(PlayerList.CreateLayoutValues)
	local Foundation = require(CorePackages.Packages.Foundation)
	local layoutValues = CreateLayoutValues(false)
	rawset(layoutValues, "SubscriptionIcon", {
		isFoundationIcon = true,
		name = Foundation.Enums.IconName.RobloxPlus,
	})

	local store = Rodux.Store.new(Reducer, nil, { Rodux.thunkMiddleware })
	store:dispatch(SetSmallTouchDevice(true))

	local element = Roact.createElement(TestProviders, {
		layoutValues = layoutValues,
		store = store,
	}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})
	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should create and destroy without errors tenfoot", function()
	local store = Rodux.Store.new(Reducer, nil, {
		Rodux.thunkMiddleware,
	})
	store:dispatch(SetTenFootInterface(true))

	local element = Roact.createElement(TestProviders, {}, {
		PlayerIcon = Roact.createElement(PlayerIcon, {
			player = Players.LocalPlayer,
			layoutOrder = 1,

			playerIconInfo = {
				isPlaceOwner = false,
				avatarIcon = nil,
				specialGroupIcon = nil,
			},

			playerRelationship = {
				isBlocked = false,
				friendStatus = Enum.FriendStatus.Unknown,
				isFollowing = false,
				isFollower = false,
			},
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)
