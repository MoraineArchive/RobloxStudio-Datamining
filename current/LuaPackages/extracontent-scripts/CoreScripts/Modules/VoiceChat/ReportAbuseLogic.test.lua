--!nonstrict

local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local jestExpect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local beforeAll = JestGlobals.beforeAll
local afterAll = JestGlobals.afterAll

local stub = function(val)
	return function()
		return val
	end
end

local CoreVoiceManagerKlass = require(CorePackages.Workspace.Packages.VoiceChatCore).CoreVoiceManager
local GetFFlagFixGetPlayerByUserIdStringCast =
	require(CorePackages.Workspace.Packages.VoiceChatCore).Flags.GetFFlagFixGetPlayerByUserIdStringCast

local ReportAbuseLogic = require(script.Parent.ReportAbuseLogic)
local MethodsOfAbuse = ReportAbuseLogic.MethodsOfAbuse
local GetDefaultMethodOfAbuse = ReportAbuseLogic.GetDefaultMethodOfAbuse
local VoiceChatServiceManagerKlass = require(script.Parent.VoiceChatServiceManager)
local VoiceChatServiceStub = require(CorePackages.Workspace.Packages.MockEngineServices).MockVoiceChatService
local makeMockUser = VoiceChatServiceStub.makeMockUser

local CoreVoiceManager
local VoiceChatServiceManager
beforeEach(function()
	VoiceChatServiceStub:resetMocks()
	local BlockMock = Instance.new("BindableEvent")
	CoreVoiceManager = CoreVoiceManagerKlass.new(BlockMock.Event, nil, nil, VoiceChatServiceStub)
	VoiceChatServiceManager =
		VoiceChatServiceManagerKlass.new(CoreVoiceManager, VoiceChatServiceStub, nil, nil, BlockMock.Event)
	VoiceChatServiceManager:SetupParticipantListeners()
end)

describe("VoiceChatServiceManager Recent Users Interaction", function()
	local fflagClearUserFromRecentVoiceDataOnLeave

	beforeAll(function()
		fflagClearUserFromRecentVoiceDataOnLeave =
			game:SetFastFlagForTesting("ClearUserFromRecentVoiceDataOnLeave", false)
	end)

	afterAll(function()
		game:SetFastFlagForTesting("ClearUserFromRecentVoiceDataOnLeave", fflagClearUserFromRecentVoiceDataOnLeave)
	end)

	it("GetDefaultMethodOfAbuse returns voice if player local muted anyone", function()
		jestExpect(VoiceChatServiceManager).never.toBeNil()
		VoiceChatServiceStub:addUsers({ makeMockUser("001"), makeMockUser("002") })
		jestExpect(GetDefaultMethodOfAbuse(nil, VoiceChatServiceManager)).toBe(MethodsOfAbuse.text)

		VoiceChatServiceStub.IsSubscribePausedCB = stub(false)
		VoiceChatServiceManager:ToggleMutePlayer("002")
		jestExpect(VoiceChatServiceManager:GetMutedAnyone()).toBe(true)
		jestExpect(GetDefaultMethodOfAbuse(nil, VoiceChatServiceManager)).toBe(MethodsOfAbuse.voice)
	end)

	it("GetDefaultMethodOfAbuse returns voice if player local mutedall", function()
		jestExpect(VoiceChatServiceManager).never.toBeNil()
		VoiceChatServiceStub:addUsers({ makeMockUser("001"), makeMockUser("002") })
		jestExpect(GetDefaultMethodOfAbuse(nil, VoiceChatServiceManager)).toBe(MethodsOfAbuse.text)

		VoiceChatServiceStub.IsSubscribePausedCB = stub(false)
		VoiceChatServiceManager:MuteAll(true)
		jestExpect(VoiceChatServiceManager:GetMutedAnyone()).toBe(true)
		jestExpect(GetDefaultMethodOfAbuse(nil, VoiceChatServiceManager)).toBe(MethodsOfAbuse.voice)
	end)

	it("GetDefaultMethodOfAbuse returns text if otherPlayer is not voice enabled", function()
		jestExpect(VoiceChatServiceManager).never.toBeNil()
		local otherPlayer = makeMockUser("001")

		jestExpect(GetDefaultMethodOfAbuse(otherPlayer, VoiceChatServiceManager)).toBe(MethodsOfAbuse.text)
	end)

	it("GetDefaultMethodOfAbuse returns voice if otherPlayer has talked and text if they haven't", function()
		local currentFlagFixGetPlayerByUserId = GetFFlagFixGetPlayerByUserIdStringCast()
		game:SetFastFlagForTesting("FixGetPlayerByUserIdStringCast", true)
		jestExpect(VoiceChatServiceManager).never.toBeNil()
		local otherPlayer = makeMockUser("001")
		otherPlayer.isMuted = true
		VoiceChatServiceStub:addUsers({ otherPlayer })

		jestExpect(GetDefaultMethodOfAbuse(nil, VoiceChatServiceManager)).toBe(MethodsOfAbuse.text)
		jestExpect(GetDefaultMethodOfAbuse(otherPlayer, VoiceChatServiceManager)).toBe(MethodsOfAbuse.text)

		otherPlayer.isMuted = false
		VoiceChatServiceStub:setUserStates({ otherPlayer })
		jestExpect(GetDefaultMethodOfAbuse(otherPlayer, VoiceChatServiceManager)).toBe(MethodsOfAbuse.voice)
		game:SetFastFlagForTesting("FixGetPlayerByUserIdStringCast", currentFlagFixGetPlayerByUserId)
	end)
end)
