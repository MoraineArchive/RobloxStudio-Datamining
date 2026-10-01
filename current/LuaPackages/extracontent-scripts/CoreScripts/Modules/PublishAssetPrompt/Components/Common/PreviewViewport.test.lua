local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local PreviewViewport = require(script.Parent.PreviewViewport)

local closePreviewView = function() end

describe("PreviewViewport", function()
	it("should create and destroy without errors for an AnimationClip", function()
		local animationClip = Instance.new("KeyframeSequence")
		local keyframe = Instance.new("Keyframe")
		keyframe.Parent = animationClip

		local element = UnitTestHelpers.createStyleProvider({
			PreviewViewport = Roact.createElement(PreviewViewport, {
				asset = animationClip,
				closePreviewView = closePreviewView,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for a Model", function()
		local model = Instance.new("Model")
		local part = Instance.new("Part")
		part.Parent = model

		local element = UnitTestHelpers.createStyleProvider({
			PreviewViewport = Roact.createElement(PreviewViewport, {
				asset = model,
				closePreviewView = closePreviewView,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
