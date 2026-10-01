local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local UIBlox = require(CorePackages.Packages.UIBlox)

local InteractionFrame = require(script.Parent.InteractionFrame)

describe("InteractionFrame", function()
	it("should create and destroy without errors", function()
		local element = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
			SharedInteractionFrame = Roact.createElement(InteractionFrame, {
				panByPixels = function() end,
				rotateByPixels = function() end,
				setAngularVelocityByPixels = function() end,
				zoomToPoint = function() end,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
