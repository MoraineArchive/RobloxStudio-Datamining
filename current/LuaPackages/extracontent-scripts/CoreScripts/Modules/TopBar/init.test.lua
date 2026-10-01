local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

it("should require without errors", function()
	local TopBarApp = require(script.Parent)

	expect(TopBarApp).never.toBeNil()
end)
