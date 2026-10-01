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

describe("FTUX EndItem for QuestVR", function()
	it("should create and destroy without errors for the End Item Footer Text", function()
		local EndItem = require(script.Parent.EndItem)
		local slideshowData = require(FTUX.Resources.FTUXSlideshowData)

		local questVRData = slideshowData[PlatformEnum.QuestVR]

		local function mockIncreaseCurrentIndex(currentIndex: number)
			currentIndex += 1
			return
		end

		local endItemComponent = MockFTUXStyleAndLocalization({
			EndItem = Roact.createElement(EndItem, {
				platform = PlatformEnum.QuestVR,
				currentIndex = #questVRData,
				increaseCurrentIndex = mockIncreaseCurrentIndex,
			}, {}),
		})

		local EndItemMounted = Roact.mount(endItemComponent, CoreGui, "EndItem")
		Roact.unmount(EndItemMounted)
	end)
end)
