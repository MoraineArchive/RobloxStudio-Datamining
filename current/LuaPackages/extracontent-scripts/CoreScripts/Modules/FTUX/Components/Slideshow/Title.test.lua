local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)

local FTUX = script.Parent.Parent.Parent
local MockFTUXStyleAndLocalization = require(FTUX.Utility.MockFTUXStyleAndLocalizationComponent)
local PlatformEnum = require(FTUX.Enums.PlatformEnum)
type Platform = PlatformEnum.Platform

describe("FTUX Title for QuestVR", function()
	it("should create and destroy without errors for FTUX Slideshow Title", function()
		local Title = require(script.Parent.Title)

		local titleComponent = MockFTUXStyleAndLocalization({
			title = Roact.createElement(Title, {
				platform = PlatformEnum.QuestVR,
				currentIndex = 1,
			}, {}),
		})

		local title = Roact.mount(titleComponent, CoreGui, "Title")
		Roact.unmount(title)
	end)
end)
