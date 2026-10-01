local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

local ContextMenuController = require(script.Parent.ContextMenuController)
local assembleMenuItems = ContextMenuController.assembleMenuItems
local getFriendLabelAndIcon = ContextMenuController.getFriendLabelAndIcon

local NOOP_ACTIONS = {
	onFriend = function() end,
	onDecline = function() end,
	onExamine = function() end,
	onBlock = function() end,
	onReport = function() end,
}

local function keysOf(items)
	local result = {}
	for _, item in ipairs(items) do
		table.insert(result, item.key)
	end
	return table.concat(result, ",")
end

local function iconNameFor(items, key)
	for _, item in ipairs(items) do
		if item.key == key then
			return item.icon and item.icon.name
		end
	end
	return nil
end

local function telemetryActionFor(items, key)
	for _, item in ipairs(items) do
		if item.key == key then
			return item.telemetryAction
		end
	end
	return nil
end

local function onceGroupFor(items, key)
	for _, item in ipairs(items) do
		if item.key == key then
			return item.onceGroup
		end
	end
	return nil
end

it("friend item for Friend status is marked requiresConfirm with a confirmLabel", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Friend,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	local friendItem
	for _, item in ipairs(items) do
		if item.key == "friend" then
			friendItem = item
			break
		end
	end
	expect(friendItem).never.toBeNil()
	expect(friendItem.requiresConfirm).toBe(true)
	expect(type(friendItem.confirmLabel)).toBe("string")
	expect(friendItem.confirmLabel).never.toBe("")
end)

it("friend item for non-Friend statuses does NOT require confirm", function()
	for _, status in ipairs({
		Enum.FriendStatus.Unknown,
		Enum.FriendStatus.NotFriend,
		Enum.FriendStatus.FriendRequestSent,
		Enum.FriendStatus.FriendRequestReceived,
	}) do
		local items = assembleMenuItems({
			isSelf = false,
			isBlocked = false,
			friendStatus = status,
			inspectMenuEnabled = true,
			actions = NOOP_ACTIONS,
		})
		for _, item in ipairs(items) do
			if item.key == "friend" then
				expect(item.requiresConfirm).never.toBe(true)
			end
		end
	end
end)

it("FriendRequestReceived adds a separate decline item (Accept + Decline)", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.FriendRequestReceived,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(keysOf(items)).toBe("friend,decline,examine,block,report")
end)

it("decline item is only present for FriendRequestReceived", function()
	for _, status in ipairs({
		Enum.FriendStatus.Unknown,
		Enum.FriendStatus.NotFriend,
		Enum.FriendStatus.Friend,
		Enum.FriendStatus.FriendRequestSent,
	}) do
		local items = assembleMenuItems({
			isSelf = false,
			isBlocked = false,
			friendStatus = status,
			inspectMenuEnabled = true,
			actions = NOOP_ACTIONS,
		})
		for _, item in ipairs(items) do
			expect(item.key).never.toBe("decline")
		end
	end
end)

it("decline item fires the injected onDecline action", function()
	local declineFired = false
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.FriendRequestReceived,
		inspectMenuEnabled = true,
		actions = {
			onFriend = function() end,
			onDecline = function()
				declineFired = true
			end,
			onExamine = function() end,
			onBlock = function() end,
			onReport = function() end,
		},
	})
	for _, item in ipairs(items) do
		if item.key == "decline" then
			item.onActivated()
		end
	end
	expect(declineFired).toBe(true)
end)

it("self menu shows only examine (no friend / block / report)", function()
	local items = assembleMenuItems({
		isSelf = true,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(keysOf(items)).toBe("examine")
end)

it("self menu with inspect disabled is empty", function()
	local items = assembleMenuItems({
		isSelf = true,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = false,
		actions = NOOP_ACTIONS,
	})
	expect(#items).toBe(0)
end)

it("other player (not blocked) shows friend -> examine -> block -> report in order", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Friend,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(keysOf(items)).toBe("friend,examine,block,report")
end)

it("blocked player hides the friend item", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = true,
		friendStatus = Enum.FriendStatus.Friend,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(keysOf(items)).toBe("examine,block,report")
end)

it("inspect disabled drops the examine item", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = false,
		actions = NOOP_ACTIONS,
	})
	expect(keysOf(items)).toBe("friend,block,report")
end)

it("items carry the correct builder icons", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Friend,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(iconNameFor(items, "examine")).toBe("magnifying-glass-plus")
	expect(iconNameFor(items, "block")).toBe("circle-slash")
	expect(iconNameFor(items, "report")).toBe("speech-bubble-exclamation")
	expect(iconNameFor(items, "friend")).toBe("person-trash-can")
end)

it("getFriendLabelAndIcon maps each status to the right icon", function()
	local _, friendIcon = getFriendLabelAndIcon(Enum.FriendStatus.Friend)
	expect(friendIcon.name).toBe("person-trash-can")
	local _, unknownIcon = getFriendLabelAndIcon(Enum.FriendStatus.Unknown)
	expect(unknownIcon.name).toBe("person-plus")
	local _, receivedIcon = getFriendLabelAndIcon(Enum.FriendStatus.FriendRequestReceived)
	expect(receivedIcon.name).toBe("person-plus")
	local label = getFriendLabelAndIcon(Enum.FriendStatus.Friend)
	expect(type(label)).toBe("string")
	expect(label).never.toBe("")
end)

it("each item invokes its injected action", function()
	local fired = {}
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = true,
		actions = {
			onFriend = function()
				fired.friend = true
			end,
			onExamine = function()
				fired.examine = true
			end,
			onBlock = function()
				fired.block = true
			end,
			onReport = function()
				fired.report = true
			end,
		},
	})
	for _, item in ipairs(items) do
		item.onActivated()
	end
	expect(fired.friend).toBe(true)
	expect(fired.examine).toBe(true)
	expect(fired.block).toBe(true)
	expect(fired.report).toBe(true)
end)

it("friend item telemetryAction reflects the friend status", function()
	local cases = {
		[Enum.FriendStatus.Friend] = "friend_remove",
		[Enum.FriendStatus.FriendRequestSent] = "friend_cancel",
		[Enum.FriendStatus.FriendRequestReceived] = "friend_accept",
		[Enum.FriendStatus.NotFriend] = "friend_send",
		[Enum.FriendStatus.Unknown] = "friend_send",
	}
	for status, expected in pairs(cases) do
		local items = assembleMenuItems({
			isSelf = false,
			isBlocked = false,
			friendStatus = status,
			inspectMenuEnabled = true,
			actions = NOOP_ACTIONS,
		})
		expect(telemetryActionFor(items, "friend")).toBe(expected)
	end
end)

it("decline / examine / report carry stable telemetry actions", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.FriendRequestReceived,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(telemetryActionFor(items, "decline")).toBe("friend_decline")
	expect(telemetryActionFor(items, "examine")).toBe("avatar_examine")
	expect(telemetryActionFor(items, "report")).toBe("user_report")
end)

it("friend and decline share a onceGroup; other items do not", function()
	local items = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.FriendRequestReceived,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(onceGroupFor(items, "friend")).toBe("friending")
	expect(onceGroupFor(items, "decline")).toBe("friending")
	expect(onceGroupFor(items, "examine")).toBeNil()
	expect(onceGroupFor(items, "block")).toBeNil()
	expect(onceGroupFor(items, "report")).toBeNil()
end)

it("block telemetryAction is 'block' when not blocked and 'unblock' when blocked", function()
	local notBlocked = assembleMenuItems({
		isSelf = false,
		isBlocked = false,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(telemetryActionFor(notBlocked, "block")).toBe("user_block")
	local blocked = assembleMenuItems({
		isSelf = false,
		isBlocked = true,
		friendStatus = Enum.FriendStatus.Unknown,
		inspectMenuEnabled = true,
		actions = NOOP_ACTIONS,
	})
	expect(telemetryActionFor(blocked, "block")).toBe("user_unblock")
end)
