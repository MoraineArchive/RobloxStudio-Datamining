local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

local StatsUtils = require(script.Parent.StatsUtils)

it("should format NetworkPing correctly", function()
	expect(StatsUtils.FormatTypedValue(2.0, StatsUtils.StatType_Ping)).toBe("2 ms")
	expect(StatsUtils.FormatTypedValue(2.42, StatsUtils.StatType_Ping)).toBe("2 ms")
end)
