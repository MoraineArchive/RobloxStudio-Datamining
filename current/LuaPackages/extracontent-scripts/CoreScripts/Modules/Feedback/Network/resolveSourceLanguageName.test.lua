local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local resolveSourceLanguageName = require(script.Parent.resolveSourceLanguageName)

local function makeLocalesData()
	return {
		{ locale = { locale = "en_us", language = { languageCode = "en", name = "English", id = 1 } } },
		{ locale = { locale = "es_es", language = { languageCode = "es", name = "Spanish", id = 2 } } },
		{ locale = { locale = "ja_jp", language = { languageCode = "ja", name = "Japanese", id = 3 } } },
	}
end

describe("resolveSourceLanguageName", function()
	it("returns the display name matching the source language code", function()
		expect(resolveSourceLanguageName(makeLocalesData(), "es")).toBe("Spanish")
	end)

	it("returns nil when no locale entry matches the source language code", function()
		expect(resolveSourceLanguageName(makeLocalesData(), "fr")).toBeNil()
	end)

	it("returns nil when locales data is missing", function()
		expect(resolveSourceLanguageName(nil, "en")).toBeNil()
	end)

	it("returns nil when the source language code is missing", function()
		expect(resolveSourceLanguageName(makeLocalesData(), nil)).toBeNil()
	end)
end)
