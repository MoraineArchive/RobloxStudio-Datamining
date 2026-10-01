local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

local getTranslator = require(script.Parent.getTranslator)
it("should return a valid Localization mock in unit tests", function()
	expect(getTranslator()).never.toBeNil()
	expect(getTranslator().FormatByKey).never.toBeNil()
end)
