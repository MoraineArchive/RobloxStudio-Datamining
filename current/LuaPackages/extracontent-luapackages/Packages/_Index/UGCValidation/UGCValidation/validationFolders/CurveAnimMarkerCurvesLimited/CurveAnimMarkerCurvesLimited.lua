local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)

local getFIntUGCValidateMaxTotalMarkerCurves = require(root.flags.getFIntUGCValidateMaxTotalMarkerCurves)
local CurveAnimMarkerCurvesLimited = {}

CurveAnimMarkerCurvesLimited.categories =
	{ ValidationEnums.UploadCategory.EMOTE_ANIMATION, ValidationEnums.UploadCategory.ANIMATION }
CurveAnimMarkerCurvesLimited.requiredData = {
	ValidationEnums.SharedDataMember.curveAnimations,
}
CurveAnimMarkerCurvesLimited.expectedFailures = {}
CurveAnimMarkerCurvesLimited.prereqTests = { ValidationEnums.ValidationModule.CurveAnimDataAvailable }

CurveAnimMarkerCurvesLimited.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	local maxTotalMarkerCurves = getFIntUGCValidateMaxTotalMarkerCurves()

	for _, inst in data.curveAnimations do
		local curveAnim = inst :: CurveAnimation
		local numMarkerCurves = 0
		for _, desc in curveAnim:GetDescendants() do
			if desc:IsA("MarkerCurve") then
				numMarkerCurves += 1
				if numMarkerCurves > maxTotalMarkerCurves then
					reporter:fail(ErrorSourceStrings.Keys.CurveAnim_TooManyMarkerCurves, {
						maxAllowed = tostring(maxTotalMarkerCurves),
					})
					return
				end
			end
		end
	end
end

return CurveAnimMarkerCurvesLimited :: Types.ValidationModule
