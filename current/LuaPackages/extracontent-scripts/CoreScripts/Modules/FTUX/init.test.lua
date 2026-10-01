local CorePackages = game:GetService("CorePackages")
local FTUXMenu = require(script.Parent)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

it("should require without errors", function()
	expect(FTUXMenu).never.toBeNil()
end)
