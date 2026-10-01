local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)

local FTUX = RobloxGui.Modules.FTUX
local MockFTUXStyleAndLocalization = require(FTUX.Utility.MockFTUXStyleAndLocalizationComponent)
local PlatformEnum = require(FTUX.Enums.PlatformEnum)

describe("FTUXSlideshow platform scenarios", function()
	it("should create and destroy without errors for QuestVR", function()
		local FTUXSlideshow = require(FTUX.Components.FTUXSlideshow)

		local ftuxSlideshow = MockFTUXStyleAndLocalization({
			FTUXSlideshow = Roact.createElement(FTUXSlideshow, {
				platform = PlatformEnum.QuestVR,
			}, {}),
		})
		local instance = Roact.mount(ftuxSlideshow, CoreGui)
		Roact.unmount(instance)
	end)
end)
