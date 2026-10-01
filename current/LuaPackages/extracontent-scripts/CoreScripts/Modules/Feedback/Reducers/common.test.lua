local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local FeedbackModule = script.Parent.Parent
local SetSourceLanguageName = require(FeedbackModule.Actions.SetSourceLanguageName)
local common = require(script.Parent.common)

describe("common reducer", function()
	it("defaults sourceLanguageName to an empty string", function()
		local state = common(nil, {})
		expect(state.sourceLanguageName).toBe("")
	end)

	it("stores the source language name from SetSourceLanguageName", function()
		local state = common(nil, SetSourceLanguageName("English"))
		expect(state.sourceLanguageName).toBe("English")
	end)

	it("preserves other common state when setting the source language name", function()
		local state = common(nil, SetSourceLanguageName("Spanish"))
		expect(state.showOnboardingModal).toBe(true)
		expect(state.showHelpModal).toBe(false)
	end)
end)
