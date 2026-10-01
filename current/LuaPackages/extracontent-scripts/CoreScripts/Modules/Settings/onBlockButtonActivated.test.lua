--!nonstrict

local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local jestExpect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeAll = JestGlobals.beforeAll

local onBlockButtonActivated = require(script.Parent.onBlockButtonActivated)
local Promise = require(CorePackages.Packages.Promise)

local c: any = {}

beforeAll(function()
	c.analyticsActionMock, c.analyticsAction = jest.fn()
	c.analytics = {
		action = c.analyticsAction,
	}

	c.promise = onBlockButtonActivated(
		{
			UserId = 10,
			Name = "Foo",
			DisplayName = "Bar",
		},
		c.analytics,
		"",
		{
			RobloxTranslator = {
				FormatByKey = function()
					return "string"
				end,
			},
		}
	)
end)

it("SHOULD return a Promise", function()
	jestExpect(c.promise).never.toBeNil()
	jestExpect(Promise.is(c.promise)).toBe(true)
end)

it("SHOULD call analytics with blockUserButtonClick event", function()
	jestExpect(c.analyticsActionMock).toHaveBeenCalledTimes(1)
	jestExpect(c.analyticsActionMock).toHaveBeenCalledWith(
		c.analytics,
		"SettingsHub",
		"blockUserButtonClick",
		{ blockeeUserId = 10, source = "" }
	)
end)
