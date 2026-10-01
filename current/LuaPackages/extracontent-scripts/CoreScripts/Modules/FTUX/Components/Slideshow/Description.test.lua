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

describe("FTUX Description for QuestVR", function()
	it("should create and destroy without errors for FTUX Slideshow Description Component", function()
		local Description = require(script.Parent.Description)

		local descriptionComponent = MockFTUXStyleAndLocalization({
			description = Roact.createElement(Description, {
				platform = PlatformEnum.QuestVR,
				currentIndex = 1,
			}, {}),
		})

		local description = Roact.mount(descriptionComponent, CoreGui, "Description")
		Roact.unmount(description)
	end)
end)
