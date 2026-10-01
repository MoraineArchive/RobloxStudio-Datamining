local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

it("should require without errors", function()
	local AvatarEditorPrompts = require(script.Parent)
	expect(AvatarEditorPrompts).never.toBeNil()
end)
