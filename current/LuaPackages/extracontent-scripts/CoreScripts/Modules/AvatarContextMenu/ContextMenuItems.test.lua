--!nonstrict
local RobloxReplicatedStorage = game:GetService("RobloxReplicatedStorage")
local ContextMenuItems = require(script.Parent.ContextMenuItems)

local CoreGuiService = game:GetService("CoreGui")
local RobloxGui = CoreGuiService:WaitForChild("RobloxGui")
local CoreGuiModules = RobloxGui:WaitForChild("Modules")

local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local FFlagAvatarContextMenuItemsChatButtonRefactor =
	require(CoreGuiModules.Flags.FFlagAvatarContextMenuItemsChatButtonRefactor)

if not FFlagAvatarContextMenuItemsChatButtonRefactor then
	describe = describe.skip
end

-- Returns a frame with context menu items as children.
local function makeContextMenuItemsFrame(props, config)
	local parentFrame = Instance.new("Frame")
	local contextMenuItems = ContextMenuItems.new(parentFrame, config)

	if not RobloxReplicatedStorage:FindFirstChild("SetPlayerBlockList") then
		local mockEvent = Instance.new("RemoteEvent")
		mockEvent.Name = "SetPlayerBlockList"
		mockEvent.Parent = RobloxReplicatedStorage
	end

	local mockPlayer = {
		UserId = 0,
	}

	contextMenuItems:BuildContextMenuItems(mockPlayer, props)
	return parentFrame
end

local function makeContextMenuButtons(props)
	if props == nil then
		props = {
			localPlayerChatEnabled = true,
			localPlayerCanChatWithSelectedPlayer = true,
		}
	end
	local menuItemsFrame = makeContextMenuItemsFrame(props)
	local buttons = menuItemsFrame:GetChildren()
	return buttons
end

local function testForCorrectButtonNames(buttonNames, textChatService)
	local props = {
		localPlayerChatEnabled = true,
		localPlayerCanChatWithSelectedPlayer = true,
	}
	local menuItemsFrame = makeContextMenuItemsFrame(props, { TextChatService = textChatService })
	local buttons = menuItemsFrame:GetChildren()
	expect(#buttons).toBe(#buttonNames)

	for _, name in ipairs(buttonNames) do
		expect(menuItemsFrame:FindFirstChild(name)).never.toBeNil()
	end
end

describe("Avatar Context Menu Buttons Appearance", function()
	it("should have the same font for all buttons with center alignment", function()
		local buttons = makeContextMenuButtons()
		local font = nil
		for _, button in ipairs(buttons) do
			local buttonLabel = button:FindFirstChildWhichIsA("TextLabel")
			expect(buttonLabel).never.toBeNil()
			expect(buttonLabel.Font).never.toBeNil()
			if font == nil then
				font = buttonLabel.Font
			else
				expect(font).never.toBeNil()
				expect(buttonLabel.Font).toBe(font)
				expect(buttonLabel.TextXAlignment).toBe(Enum.TextXAlignment.Center)
				expect(buttonLabel.TextYAlignment).toBe(Enum.TextYAlignment.Center)
			end
		end
	end)

	it("all buttons should have white text color", function()
		local buttons = makeContextMenuButtons()
		local whiteColor = Color3.fromRGB(255, 255, 255)

		for _, button in ipairs(buttons) do
			local buttonLabel = button:FindFirstChildWhichIsA("TextLabel")
			expect(buttonLabel).never.toBeNil()
			expect(buttonLabel.TextColor3).toBe(whiteColor)
		end
	end)

	describe("GIVEN the EnableExperienceChat Flag", function()
		describe("WHEN EnableExperienceChat Flag is true", function()
			describe("WHEN TextChatService.ChatVersion is Legacy Chat", function()
				it("SHOULD have 4 default buttons: Friend, Chat, Wave, View.", function()
					local textChatService = {
						ChatVersion = Enum.ChatVersion.LegacyChatService,
					}
					testForCorrectButtonNames({ "Wave", "ChatStatus", "FriendStatus", "View" }, textChatService)
				end)
			end)

			describe("WHEN TextChatService.ChatVersion is new TextChatService", function()
				it("SHOULD have 4 default buttons: Friend, Chat, Wave, View.", function()
					local textChatService = {
						ChatVersion = Enum.ChatVersion.TextChatService,
					}
					testForCorrectButtonNames({ "Wave", "ChatStatus", "FriendStatus", "View" }, textChatService)
				end)
			end)
		end)
	end)
end)
