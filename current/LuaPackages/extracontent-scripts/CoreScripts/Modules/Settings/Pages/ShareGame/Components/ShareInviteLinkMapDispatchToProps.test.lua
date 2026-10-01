--!nonstrict
local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local jestExpect = JestGlobals.expect
local beforeAll = JestGlobals.beforeAll

local c: any = {}

beforeAll(function()
	c.mapDispatchToProps = require(script.Parent.ShareInviteLinkMapDispatchToProps)
end)

it("SHOULD return a function", function()
	jestExpect(c.mapDispatchToProps).toEqual(jestExpect.any("function"))
end)

describe("WHEN called", function()
	it("SHOULD return a dictionary without throwing", function()
		jestExpect(c.mapDispatchToProps()).toEqual({
			fetchShareInviteLink = jestExpect.any("function"),
		})
	end)
end)
