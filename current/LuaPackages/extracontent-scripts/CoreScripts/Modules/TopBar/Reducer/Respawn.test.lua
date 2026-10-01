local TopBar = script.Parent.Parent

local FFlagTopBarDeprecateRespawnRodux = require(TopBar.Flags.FFlagTopBarDeprecateRespawnRodux)

local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

if FFlagTopBarDeprecateRespawnRodux then
	it = it.skip :: typeof(JestGlobals.it)
end

local Actions = TopBar.Actions
local SetRespawnBehaviour = require(Actions.SetRespawnBehaviour)

local Respawn = require(script.Parent.Respawn)

it("should have the correct default values", function()
	local defaultState = Respawn(nil, {})
	expect(defaultState).toMatchObject({ enabled = true })
	expect(defaultState.customCallback).toBeNil()
end)

describe("SetRespawnBehavior", function()
	it("should change the value of enabled", function()
		local oldState = Respawn(nil, {})
		local newState = Respawn(oldState, SetRespawnBehaviour(false))
		expect(oldState).never.toBe(newState)
		expect(newState.enabled).toBe(false)
	end)

	it("should change the value of customCallback", function()
		local Callback = Instance.new("BindableEvent")

		local oldState = Respawn(nil, {})
		local newState = Respawn(oldState, SetRespawnBehaviour(true, Callback))
		expect(oldState).never.toBe(newState)
		expect(newState.customCallback).toBe(Callback)
	end)
end)
