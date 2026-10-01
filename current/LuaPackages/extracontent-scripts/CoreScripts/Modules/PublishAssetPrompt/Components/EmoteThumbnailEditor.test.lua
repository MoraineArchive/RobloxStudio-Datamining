local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local Roact = require(CorePackages.Packages.Roact)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local EmoteThumbnailEditor = require(script.Parent.EmoteThumbnailEditor)
local EmoteThumbnailParameters = require(script.Parent.EmoteThumbnailParameters)

local closePromptCallback = function() end
local updateThumbnailCallback = function(emoteParameters) end

describe("EmoteThumbnailView", function()
	it("should create and destroy without errors for KeyframeSequence", function()
		local animationClip = Instance.new("KeyframeSequence")
		local keyframe = Instance.new("Keyframe")
		keyframe.Parent = animationClip

		local element = UnitTestHelpers.createStyleProvider({
			EmoteThumbnailView = Roact.createElement(EmoteThumbnailEditor, {
				screenSize = Vector2.new(1080, 1920),

				animationClip = animationClip,
				initialThumbnailParameters = EmoteThumbnailParameters.defaultParameters,
				closePromptCallback = closePromptCallback,
				updateThumbnailCallback = updateThumbnailCallback,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should create and destroy without errors for CurveAnimation", function()
		local animationClip = Instance.new("CurveAnimation")

		local element = UnitTestHelpers.createStyleProvider({
			EmoteThumbnailView = Roact.createElement(EmoteThumbnailEditor, {
				screenSize = Vector2.new(1920, 300), --300 to test the landscape rendering

				animationClip = animationClip,
				initialThumbnailParameters = EmoteThumbnailParameters.defaultParameters,
				closePromptCallback = closePromptCallback,
				updateThumbnailCallback = updateThumbnailCallback,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)
end)
