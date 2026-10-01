local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)

local GetFStringUGCValidateCurveAnimationMinLength = require(root.flags.GetFStringUGCValidateCurveAnimationMinLength)
local GetFStringUGCValidationMaxAnimationLength = require(root.flags.GetFStringUGCValidationMaxAnimationLength)
local getEngineFeatureEngineUGCValidateEmoteAnimationExport =
	require(root.flags.getEngineFeatureEngineUGCValidateEmoteAnimationExport)
local getFFlagUGCValidateAQEmoteDuration = require(root.flags.getFFlagUGCValidateAQEmoteDuration)

local CurveAnimLengthBounded = {}

-- AQ's Measure_Animation_Duration owns the length check for EMOTE_ANIMATION once its
-- flags are on, so drop that category here. ANIMATION-pack uploads are NOT covered by
-- AQ, so they must keep this check.
local emoteAqOwnsLength = getEngineFeatureEngineUGCValidateEmoteAnimationExport()
	and getFFlagUGCValidateAQEmoteDuration()

CurveAnimLengthBounded.categories = {}
if not emoteAqOwnsLength then
	table.insert(CurveAnimLengthBounded.categories, ValidationEnums.UploadCategory.EMOTE_ANIMATION)
end
table.insert(CurveAnimLengthBounded.categories, ValidationEnums.UploadCategory.ANIMATION)
CurveAnimLengthBounded.requiredData = {
	ValidationEnums.SharedDataMember.curveAnimations,
	ValidationEnums.SharedDataMember.curveAnimComputedFrames,
}
CurveAnimLengthBounded.expectedFailures = {}
CurveAnimLengthBounded.prereqTests = { ValidationEnums.ValidationModule.CurveAnimDataAvailable }

CurveAnimLengthBounded.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	local computed = data.curveAnimComputedFrames
	local length = computed.animLength

	local minLength = GetFStringUGCValidateCurveAnimationMinLength.asNumber()

	if length <= minLength or length > GetFStringUGCValidationMaxAnimationLength.asNumber() then
		reporter:fail(ErrorSourceStrings.Keys.CurveAnim_InvalidLength, {
			minLength = tostring(minLength),
			maxLength = GetFStringUGCValidationMaxAnimationLength.asString(),
		})
	end
end

return CurveAnimLengthBounded :: Types.ValidationModule
