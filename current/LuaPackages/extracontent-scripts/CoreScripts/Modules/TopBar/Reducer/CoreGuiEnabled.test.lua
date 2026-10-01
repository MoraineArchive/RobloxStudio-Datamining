-- Remove with FFlagTopBarDeprecateCoreGuiRodux
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local TopBar = script.Parent.Parent
local Actions = TopBar.Actions
local UpdateCoreGuiEnabled = require(Actions.UpdateCoreGuiEnabled)
local CoreGuiEnabled = require(script.Parent.CoreGuiEnabled)
local CorePackages = game:GetService("CorePackages")
local FFlagMountCoreGuiBackpack = require(RobloxGui.Modules.Flags.FFlagMountCoreGuiBackpack)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local FFlagTopBarDeprecateCoreGuiRodux = require(TopBar.Flags.FFlagTopBarDeprecateCoreGuiRodux)

if FFlagTopBarDeprecateCoreGuiRodux then
	it = it.skip :: typeof(JestGlobals.it)
end

it("everything should be enabled by default", function()
	local defaultState = CoreGuiEnabled(nil, {})
	local expectedStates = nil
	if FFlagMountCoreGuiBackpack then
		expectedStates = {
			[Enum.CoreGuiType.PlayerList] = true,
			[Enum.CoreGuiType.Health] = true,
			[Enum.CoreGuiType.Chat] = true,
			[Enum.CoreGuiType.EmotesMenu] = true,
		}
	else
		expectedStates = {
			[Enum.CoreGuiType.PlayerList] = true,
			[Enum.CoreGuiType.Health] = true,
			[Enum.CoreGuiType.Backpack] = true,
			[Enum.CoreGuiType.Chat] = true,
			[Enum.CoreGuiType.EmotesMenu] = true,
		}
	end
	expect(defaultState).toMatchObject(expectedStates)
end)

describe("UpdateCoreGuiEnabled", function()
	it("should change the value of of the given coregui type", function()
		local oldState = CoreGuiEnabled(nil, {})
		local newState = CoreGuiEnabled(oldState, UpdateCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false))
		expect(oldState).never.toBe(newState)
		expect(newState[Enum.CoreGuiType.PlayerList]).toBe(false)
	end)

	it("should update all values when passed Enum.CoreGuiType.All", function()
		local oldState = CoreGuiEnabled(nil, {})
		local newState = CoreGuiEnabled(oldState, UpdateCoreGuiEnabled(Enum.CoreGuiType.All, false))

		expect(newState[Enum.CoreGuiType.PlayerList]).toBe(false)
		expect(newState[Enum.CoreGuiType.Health]).toBe(false)
		if not FFlagMountCoreGuiBackpack then
			expect(newState[Enum.CoreGuiType.Backpack]).toBe(false)
		end
		expect(newState[Enum.CoreGuiType.Chat]).toBe(false)
		expect(newState[Enum.CoreGuiType.EmotesMenu]).toBe(false)
	end)
end)
