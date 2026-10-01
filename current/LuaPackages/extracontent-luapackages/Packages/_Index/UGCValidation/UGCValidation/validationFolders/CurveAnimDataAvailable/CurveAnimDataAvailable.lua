local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)
local FetchAllDesiredData = require(root.validationSystem.dataFetchModules.FetchAllDesiredData)

local CurveAnimDataAvailable = {}

CurveAnimDataAvailable.categories =
	{ ValidationEnums.UploadCategory.EMOTE_ANIMATION, ValidationEnums.UploadCategory.ANIMATION }
CurveAnimDataAvailable.requiredData = {}
CurveAnimDataAvailable.expectedFailures = {}

CurveAnimDataAvailable.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	local curveAnimations = data.curveAnimations
	if not curveAnimations or curveAnimations == FetchAllDesiredData.DATA_FETCH_FAILURE then
		reporter:fail(ErrorSourceStrings.Keys.CurveAnim_FetchFailed)
		return
	end

	if #curveAnimations == 0 then
		reporter:fail(ErrorSourceStrings.Keys.CurveAnim_NotCurveAnimation)
		return
	end

	local computedFrames = data.curveAnimComputedFrames
	if not computedFrames or computedFrames == FetchAllDesiredData.DATA_FETCH_FAILURE then
		reporter:fail(ErrorSourceStrings.Keys.CurveAnim_FetchFailed)
		return
	end
end

return CurveAnimDataAvailable :: Types.ValidationModule
