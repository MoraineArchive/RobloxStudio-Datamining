local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)

local GetFStringUGCValidateAnimationHeightTol = require(root.flags.GetFStringUGCValidateAnimationHeightTol)
local GetFStringUGCValidationMaxAnimationBounds = require(root.flags.GetFStringUGCValidationMaxAnimationBounds)
local getFIntUGCValidateMaxAnimationFPS = require(root.flags.getFIntUGCValidateMaxAnimationFPS)
local CurveAnimBoundsValid = {}

CurveAnimBoundsValid.categories =
	{ ValidationEnums.UploadCategory.EMOTE_ANIMATION, ValidationEnums.UploadCategory.ANIMATION }
CurveAnimBoundsValid.requiredData = {
	ValidationEnums.SharedDataMember.curveAnimations,
	ValidationEnums.SharedDataMember.curveAnimComputedFrames,
}
CurveAnimBoundsValid.expectedFailures = {}
CurveAnimBoundsValid.prereqTests = { ValidationEnums.ValidationModule.CurveAnimDataAvailable }

CurveAnimBoundsValid.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	local computed = data.curveAnimComputedFrames
	local animFrames = computed.animFrames
	local animLength = computed.animLength
	local frameDelta = 1.0 / getFIntUGCValidateMaxAnimationFPS()

	local heightTol = GetFStringUGCValidateAnimationHeightTol.asNumber()
	local boundsTol = GetFStringUGCValidationMaxAnimationBounds.asNumber()

	for frameNumberIdx, frame in animFrames do
		for bodyPartName, cframe in frame do
			if (cframe :: CFrame).Position.Y < heightTol then
				reporter:fail(ErrorSourceStrings.Keys.CurveAnim_PartTooLow, {
					time = string.format("%.2f", math.min(animLength, (frameNumberIdx - 1) * frameDelta)),
					bodyPart = bodyPartName :: string,
					height = string.format("%.2f", (cframe :: CFrame).Position.Y),
					minHeight = GetFStringUGCValidateAnimationHeightTol.asString(),
				})
				return
			end
			if (cframe :: CFrame).Position.Magnitude > boundsTol then
				reporter:fail(ErrorSourceStrings.Keys.CurveAnim_PartTooFar, {
					time = string.format("%.2f", math.min(animLength, (frameNumberIdx - 1) * frameDelta)),
					bodyPart = bodyPartName :: string,
					distance = string.format("%.2f", (cframe :: CFrame).Position.Magnitude),
					maxDistance = GetFStringUGCValidationMaxAnimationBounds.asString(),
				})
				return
			end
		end
	end
end

return CurveAnimBoundsValid :: Types.ValidationModule
