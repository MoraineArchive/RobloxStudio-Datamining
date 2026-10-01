local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)

local CurveAnimNoScripts = {}

CurveAnimNoScripts.categories =
	{ ValidationEnums.UploadCategory.EMOTE_ANIMATION, ValidationEnums.UploadCategory.ANIMATION }
CurveAnimNoScripts.requiredData = {
	ValidationEnums.SharedDataMember.curveAnimations,
}
CurveAnimNoScripts.expectedFailures = {}
CurveAnimNoScripts.prereqTests = { ValidationEnums.ValidationModule.CurveAnimDataAvailable }

CurveAnimNoScripts.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	for _, inst in data.curveAnimations do
		local curveAnim = inst :: CurveAnimation
		for _, child in curveAnim:GetDescendants() do
			if child:IsA("Script") or child:IsA("ModuleScript") then
				reporter:fail(ErrorSourceStrings.Keys.CurveAnim_ContainsScripts)
				return
			end
		end
	end
end

return CurveAnimNoScripts :: Types.ValidationModule
