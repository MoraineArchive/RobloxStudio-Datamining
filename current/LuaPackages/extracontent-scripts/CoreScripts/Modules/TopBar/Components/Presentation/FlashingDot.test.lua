local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local FlashingDot = require(script.Parent.FlashingDot)

it("should mount and unmount without errors", function()
	local element = Roact.createElement(FlashingDot)

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)
