-- Remove with FFlagTopBarDeprecateGameInfoRodux
local TopBar = script.Parent.Parent
local Actions = TopBar.Actions
local SetGameName = require(Actions.SetGameName)

local FFlagTopBarDeprecateGameInfoRodux = require(TopBar.Flags.FFlagTopBarDeprecateGameInfoRodux)

if FFlagTopBarDeprecateGameInfoRodux then
	return
end

local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local GameInfo = require(script.Parent.GameInfo)

it("should have the correct default values", function()
	local defaultState = GameInfo(nil, {})
	expect(defaultState).toMatchObject({ name = "Experience" })
end)

describe("SetGameName", function()
	it("should change the value of name", function()
		local oldState = GameInfo(nil, {})
		local newState = GameInfo(oldState, SetGameName("Test"))
		expect(oldState).never.toBe(newState)
		expect(newState.name).toBe("Test")
	end)
end)
