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
type Platform = PlatformEnum.Platform

describe("FTUXPanel", function()
	it("should create and destroy without errors for QuestVR", function()
		local FTUXPanel = require(FTUX.Components.FTUXPanel)

		local ftuxTree = MockFTUXStyleAndLocalization({
			FtuxPanel = Roact.createElement(FTUXPanel, {
				platform = PlatformEnum.QuestVR,
			}, {}),
		})

		local instance = Roact.mount(ftuxTree, CoreGui, "FTUXMenu")
		Roact.unmount(instance)
	end)
end)
