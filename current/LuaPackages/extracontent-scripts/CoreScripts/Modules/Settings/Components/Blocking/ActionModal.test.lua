--!nonstrict
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local ActionModal = require(script.Parent.ActionModal)
local simpleMountFrame = require(CorePackages.Workspace.Packages.UnitTestHelpers).simpleMountFrame

local noOpt = function() end
describe("lifecycle", function()
	it("SHOULD mount and render without issue", function()
		local _, cleanup = simpleMountFrame(Roact.createElement(ActionModal, {
			title = "remove someone",
			body = "block now",
			cancel = noOpt,
			cancelText = "Cancel",
			block = noOpt,
			blockText = "blockText",
			blockAndReport = noOpt,
			blockAndReportText = "blockAndReportText",
		}))

		cleanup()
	end)
end)
