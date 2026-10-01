local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local UIBlox = require(CorePackages.Packages.UIBlox)

local EmoteThumbnailView = require(script.Parent.EmoteThumbnailView)
local EmoteThumbnailParameters = require(script.Parent.EmoteThumbnailParameters)

describe("EmoteThumbnailView", function()
	it("should create and destroy without errors for KeyframeSequence", function()
		local animationClip = Instance.new("KeyframeSequence")
		local keyframe = Instance.new("Keyframe")
		keyframe.Parent = animationClip

		local element = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
			EmoteThumbnailView = Roact.createElement(EmoteThumbnailView, {
				animationClip = animationClip,
				thumbnailParameters = EmoteThumbnailParameters.defaultParameters,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for CurveAnimation", function()
		local animationClip = Instance.new("CurveAnimation")

		local element = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
			EmoteThumbnailView = Roact.createElement(EmoteThumbnailView, {
				animationClip = animationClip,
				thumbnailParameters = EmoteThumbnailParameters.defaultParameters,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
