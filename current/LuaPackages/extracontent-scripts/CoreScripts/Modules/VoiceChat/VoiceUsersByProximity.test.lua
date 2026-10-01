--!nonstrict

local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local jestExpect = JestGlobals.expect
local beforeAll = JestGlobals.beforeAll
local afterAll = JestGlobals.afterAll
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach

local waitForEvents = require(CorePackages.Workspace.Packages.TestUtils).DeferredLuaHelpers.waitForEvents

local VoiceUsersByProximity = require(script.Parent.VoiceUsersByProximity)
local getVoiceUsersByProximity = VoiceUsersByProximity.getSortedPlayers

local VoiceChatServiceManagerClass = require(script.Parent.VoiceChatServiceManager)
local VoiceChatServiceStub = require(CorePackages.Workspace.Packages.MockEngineServices).MockVoiceChatService
local makeMockUser = VoiceChatServiceStub.makeMockUser

local CoreVoiceManagerKlass = require(CorePackages.Workspace.Packages.VoiceChatCore).CoreVoiceManager
local GetFFlagFixGetPlayerByUserIdStringCast =
	require(CorePackages.Workspace.Packages.VoiceChatCore).Flags.GetFFlagFixGetPlayerByUserIdStringCast

local fflagClearUserFromRecentVoiceDataOnLeave
local fintVoiceUsersInteractionExpiryTimeSeconds

beforeAll(function()
	fflagClearUserFromRecentVoiceDataOnLeave = game:SetFastFlagForTesting("ClearUserFromRecentVoiceDataOnLeave", false)
	fintVoiceUsersInteractionExpiryTimeSeconds =
		game:SetFastIntForTesting("VoiceUsersInteractionExpiryTimeSeconds", 600)
end)

afterAll(function()
	game:SetFastFlagForTesting("ClearUserFromRecentVoiceDataOnLeave", fflagClearUserFromRecentVoiceDataOnLeave)
	game:SetFastIntForTesting("VoiceUsersInteractionExpiryTimeSeconds", fintVoiceUsersInteractionExpiryTimeSeconds)
end)

local c: any = {}

beforeEach(function()
	local BlockMock = Instance.new("BindableEvent")

	local coreVoiceManager = CoreVoiceManagerKlass.new(BlockMock.Event, nil, nil, VoiceChatServiceStub)

	local voiceChatServiceManager =
		VoiceChatServiceManagerClass.new(coreVoiceManager, VoiceChatServiceStub, nil, nil, BlockMock.Event)
	voiceChatServiceManager:SetupParticipantListeners()

	local mockPlayersService = {
		players = {},
	}

	function mockPlayersService:GetPlayerByUserId(userId)
		return mockPlayersService.players[userId]
	end

	function mockPlayersService:addMockPlayerAndCharacter(userId, position)
		local mockPlayer = {
			UserId = userId,
			Name = tostring(userId),
			Character = {
				PrimaryPart = {
					Position = position,
				},
			},
		}

		mockPlayersService.players[userId] = mockPlayer

		local mockUser = makeMockUser(tostring(userId))
		mockUser.isMuted = true
		VoiceChatServiceStub:addUsers({ mockUser })

		return mockPlayer
	end

	c = {
		CoreVoiceManager = coreVoiceManager,
		VoiceChatServiceManager = voiceChatServiceManager,
		mockPlayersService = mockPlayersService,
	}
end)

afterEach(function()
	c.VoiceChatServiceManager:Disconnect()
end)

describe("GetVoiceUsersByProximity", function()
	it("Should sort by proximity", function()
		c.mockPlayersService:addMockPlayerAndCharacter("001", Vector3.new(0, 0, 0))
		c.mockPlayersService:addMockPlayerAndCharacter("002", Vector3.new(0, 0, 5))
		c.mockPlayersService:addMockPlayerAndCharacter("003", Vector3.new(0, 0, 10))
		waitForEvents()

		local usersSortedByProximity =
			getVoiceUsersByProximity(c.mockPlayersService, c.VoiceChatServiceManager, Vector3.new(0, 0, 0))

		jestExpect(usersSortedByProximity[1]).toBe(c.mockPlayersService.players["001"])
		jestExpect(usersSortedByProximity[2]).toBe(c.mockPlayersService.players["002"])
		jestExpect(usersSortedByProximity[3]).toBe(c.mockPlayersService.players["003"])
	end)

	it("Should filter users further than max distance", function()
		c.mockPlayersService:addMockPlayerAndCharacter("001", Vector3.new(0, 0, 0))
		c.mockPlayersService:addMockPlayerAndCharacter("002", Vector3.new(0, 0, 5))
		c.mockPlayersService:addMockPlayerAndCharacter("003", Vector3.new(0, 0, 10))
		waitForEvents()

		local usersSortedByProximity =
			getVoiceUsersByProximity(c.mockPlayersService, c.VoiceChatServiceManager, Vector3.new(0, 0, 0), 5)

		jestExpect(#usersSortedByProximity).toBe(2)
	end)

	it("Should filter users who haven't interacted with local user", function()
		local currentFlagFixGetPlayerByUserId = GetFFlagFixGetPlayerByUserIdStringCast()
		game:SetFastFlagForTesting("FixGetPlayerByUserIdStringCast", true)
		c.mockPlayersService:addMockPlayerAndCharacter("001", Vector3.new(0, 0, 0))
		c.mockPlayersService:addMockPlayerAndCharacter("002", Vector3.new(0, 0, 5))
		c.mockPlayersService:addMockPlayerAndCharacter("003", Vector3.new(0, 0, 10))
		waitForEvents()

		c.mockPlayersService.LocalPlayer = c.mockPlayersService.players["001"]

		local newState = makeMockUser("002")
		newState.isMuted = false
		VoiceChatServiceStub:setUserStates({
			newState,
		})
		waitForEvents()

		local usersSortedByProximity =
			getVoiceUsersByProximity(c.mockPlayersService, c.VoiceChatServiceManager, Vector3.new(0, 0, 0), nil, true)

		jestExpect(#usersSortedByProximity).toBe(1)
		game:SetFastFlagForTesting("FixGetPlayerByUserIdStringCast", currentFlagFixGetPlayerByUserId)
	end)

	it.skip("Should exclude players", function()
		c.mockPlayersService:addMockPlayerAndCharacter("001", Vector3.new(0, 0, 0))
		c.mockPlayersService:addMockPlayerAndCharacter("002", Vector3.new(0, 0, 5))
		c.mockPlayersService:addMockPlayerAndCharacter("003", Vector3.new(0, 0, 10))
		waitForEvents()

		c.mockPlayersService.LocalPlayer = c.mockPlayersService.players["001"]

		local usersSortedByProximity = getVoiceUsersByProximity(
			c.mockPlayersService,
			c.VoiceChatServiceManager,
			Vector3.new(0, 0, 0),
			nil,
			nil,
			c.mockPlayersService.players["003"]
		)

		jestExpect(#usersSortedByProximity).toBe(2)
	end)
end)
