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

describe("FTUX Stepper for QuestVR", function()
	it("should create and destroy without errors for FTUX Slideshow Stepper Component", function()
		local Stepper = require(script.Parent.Stepper)
		local slideshowData = require(FTUX.Resources.FTUXSlideshowData)

		local questVRData = slideshowData[PlatformEnum.QuestVR]
		local stepperComponent = MockFTUXStyleAndLocalization({
			stepper = Roact.createElement(Stepper, {
				layoutOrder = 1,
				numberOfSteps = #questVRData,
				numberActivated = 2,
			}, {}),
		})

		local stepper = Roact.mount(stepperComponent, CoreGui, "Stepper")
		Roact.unmount(stepper)
	end)
end)
