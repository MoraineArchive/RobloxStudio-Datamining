--!nonstrict
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local ReportActionSelection = require(script.Parent.ReportActionSelection)
local simpleMountFrame = require(CorePackages.Workspace.Packages.UnitTestHelpers).simpleMountFrame

describe("lifecycle", function()
	it("SHOULD mount and render without issue", function()
		local _, cleanup = simpleMountFrame(Roact.createElement(ReportActionSelection, {}))
		cleanup()
	end)
end)
