local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

it("should require without errors", function()
	local PublishAssetPrompt = require(script.Parent)
	expect(PublishAssetPrompt).never.toBeNil()
end)
