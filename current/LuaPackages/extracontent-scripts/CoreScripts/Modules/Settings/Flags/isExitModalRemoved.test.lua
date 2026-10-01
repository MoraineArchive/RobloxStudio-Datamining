local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local isPioneerLaunch = require(CorePackages.Workspace.Packages.PioneerUtils).isPioneerLaunch
local isExitModalRemoved = require(script.Parent.isExitModalRemoved)
local FFlagRemoveExitModal = game:GetFastFlag("RemoveExitModal")

describe("isExitModalRemoved", function()
	if isPioneerLaunch() then
		it("SHOULD be true for Pioneer", function()
			expect(isExitModalRemoved).toBe(true)
		end)
	end

	if FFlagRemoveExitModal then
		it("SHOULD be true when RemoveExitModal is enabled", function()
			expect(isExitModalRemoved).toBe(true)
		end)
	end

	if not isPioneerLaunch() and not FFlagRemoveExitModal then
		it("SHOULD remain disabled by default outside Pioneer", function()
			expect(isExitModalRemoved).toBe(false)
		end)
	end
end)
