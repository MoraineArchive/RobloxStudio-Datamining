--!nonstrict
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local Promise = require(CorePackages.Packages.Promise)
local ReactRoblox = require(CorePackages.Packages.ReactRoblox)
local act = ReactRoblox.act

local InviteToGamePrompt = require(script.Parent.InviteToGamePrompt)

-- Showing the prompt mounts FullModalShareGameComponent, whose ShareGameContainer
-- fetches friends on mount. Injecting a resolving stand-in via :withRequestImpl keeps
-- these specs off unmocked HTTP (which otherwise produces unhandled rejections).
local function createMockRequestImpl()
	local mock = { callCount = 0 }
	mock.requestImpl = function()
		mock.callCount += 1
		return Promise.resolve({
			responseBody = {
				data = {},
				userPresences = {},
			},
		})
	end
	return mock
end

describe("new", function()
	it("should return a new prompt", function()
		local prompt = InviteToGamePrompt.new()

		expect(prompt).toMatchObject({
			show = expect.anything(),
			hide = expect.anything(),
			isActive = false,
		})
	end)

	it("should accept mountTarget as a parameter", function()
		local folder = Instance.new("Folder")
		local prompt = InviteToGamePrompt.new(folder)

		expect(prompt).toMatchObject({
			show = expect.anything(),
			hide = expect.anything(),
			isActive = false,
			mountTarget = folder,
		})

		folder:Destroy()
	end)
end)

describe("withSocialServiceAndLocalPlayer", function()
	it("should accept passed socialService", function()
		local mockSocialService = {}
		local prompt = InviteToGamePrompt.new()
		local promptWithSocial = prompt:withSocialServiceAndLocalPlayer(mockSocialService)

		expect(promptWithSocial.socialService).toEqual(mockSocialService)
		expect(promptWithSocial).toBe(prompt)
	end)

	it("should accept passed localPlayer", function()
		local mockLocalPlayer = {}
		local prompt = InviteToGamePrompt.new()
		local promptWithPlayer = prompt:withSocialServiceAndLocalPlayer(nil, mockLocalPlayer)

		expect(promptWithPlayer.localPlayer).toEqual(mockLocalPlayer)
		expect(promptWithPlayer).toBe(prompt)
	end)
end)

describe("withAnalytics", function()
	it("should accept passed analytics", function()
		local mockAnalytics = {}
		local prompt = InviteToGamePrompt.new()
		local promptWithAnalytics = prompt:withAnalytics(mockAnalytics)

		expect(promptWithAnalytics.analytics).toEqual(mockAnalytics)
		expect(promptWithAnalytics).toBe(prompt)
	end)
end)

describe("show", function()
	it("should create an instance on the first show", function()
		local mock = createMockRequestImpl()
		local folder = Instance.new("Folder")
		local prompt = InviteToGamePrompt.new(folder):withRequestImpl(mock.requestImpl)

		expect(prompt.instance).toBeNil()

		act(function()
			prompt:show()
		end)

		expect(prompt.instance).never.toBeNil()
		expect(mock.callCount).toBeGreaterThan(0)

		InviteToGamePrompt:destruct()
		folder:Destroy()
	end)

	it("should make the prompt visible", function()
		local mock = createMockRequestImpl()
		local folder = Instance.new("Folder")
		local prompt = InviteToGamePrompt.new(folder):withRequestImpl(mock.requestImpl)

		act(function()
			prompt:show()
		end)

		local screenGui = folder:FindFirstChildOfClass("ScreenGui", true)
		expect(screenGui).toMatchInstance({ Enabled = true })

		InviteToGamePrompt:destruct()
		folder:Destroy()
	end)

	it("should do nothing if prompt is already visible", function()
		local mock = createMockRequestImpl()
		local folder = Instance.new("Folder")
		local prompt = InviteToGamePrompt.new(folder):withRequestImpl(mock.requestImpl)

		act(function()
			prompt:show()
		end)
		act(function()
			prompt:show()
		end)

		local screenGui = folder:FindFirstChildOfClass("ScreenGui", true)
		expect(screenGui).toMatchInstance({ Enabled = true })

		InviteToGamePrompt:destruct()
		folder:Destroy()
	end)
end)

describe("hide", function()
	it("should do nothing if prompt is already hidden", function()
		local folder = Instance.new("Folder")
		local prompt = InviteToGamePrompt.new(folder)

		act(function()
			prompt:hide()
		end)
		act(function()
			prompt:hide()
		end)

		expect(prompt.instance).toBeNil()

		InviteToGamePrompt:destruct()
		folder:Destroy()
	end)
end)

it("should hide the active prompt if it was shown", function()
	local mock = createMockRequestImpl()
	local folder = Instance.new("Folder")
	local prompt = InviteToGamePrompt.new(folder):withRequestImpl(mock.requestImpl)

	act(function()
		prompt:show()
	end)
	act(function()
		prompt:hide()
	end)

	expect(prompt.instance).never.toBeNil()
	local screenGui = folder:FindFirstChildOfClass("ScreenGui", true)
	expect(screenGui).toMatchInstance({ Enabled = false })

	InviteToGamePrompt:destruct()
	folder:Destroy()
end)

it("should invoke socialService's InvokeGameInvitePromptClosed after shown", function()
	local lastSentLocalPlayer
	local lastSentUserIds

	local mockSocialService = {
		InvokeGameInvitePromptClosed = function(self, localPlayer, sentUserIds)
			lastSentLocalPlayer = localPlayer
			lastSentUserIds = sentUserIds
		end,
	}
	local mockLocalPlayer = {}
	local mockSentUserIds = {}

	local mock = createMockRequestImpl()
	local folder = Instance.new("Folder")
	local prompt = InviteToGamePrompt.new(folder)
		:withSocialServiceAndLocalPlayer(mockSocialService, mockLocalPlayer)
		:withRequestImpl(mock.requestImpl)

	act(function()
		prompt:show()
	end)
	act(function()
		prompt:hide(mockSentUserIds)
	end)

	expect(lastSentLocalPlayer).toBe(mockLocalPlayer)
	-- lastSentUserIds should always be an empty array
	expect(#lastSentUserIds).toBe(0)

	InviteToGamePrompt:destruct()
	folder:Destroy()
end)

it("should not invoke socialService's InvokeGameInvitePromptClosed if never shown", function()
	local lastSentLocalPlayer
	local lastSentUserIds

	local mockSocialService = {
		InvokeGameInvitePromptClosed = function(self, localPlayer, sentUserIds)
			lastSentLocalPlayer = localPlayer
			lastSentUserIds = sentUserIds
		end,
	}
	local mockLocalPlayer = {}
	local mockSentUserIds = {}

	local folder = Instance.new("Folder")
	local prompt = InviteToGamePrompt.new(folder):withSocialServiceAndLocalPlayer(mockSocialService, mockLocalPlayer)

	-- intentionally do not show
	act(function()
		prompt:hide(mockSentUserIds)
	end)

	expect(lastSentLocalPlayer).toBeNil()
	expect(lastSentUserIds).toBeNil()

	InviteToGamePrompt:destruct()
	folder:Destroy()
end)
