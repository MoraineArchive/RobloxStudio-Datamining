local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)
local CurveAnimationHierarchyUtils = require(root.util.CurveAnimationHierarchyUtils)

local CurveAnimJointsManipulated = {}

CurveAnimJointsManipulated.categories =
	{ ValidationEnums.UploadCategory.EMOTE_ANIMATION, ValidationEnums.UploadCategory.ANIMATION }
CurveAnimJointsManipulated.requiredData = {
	ValidationEnums.SharedDataMember.curveAnimations,
}
CurveAnimJointsManipulated.expectedFailures = {}
CurveAnimJointsManipulated.prereqTests = { ValidationEnums.ValidationModule.CurveAnimDataAvailable }

CurveAnimJointsManipulated.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	for _, inst in data.curveAnimations do
		local curveAnim = inst :: CurveAnimation
		local bodyPartFolderRootOpt = CurveAnimationHierarchyUtils.getBodyPartFolderRoot(curveAnim)
		if not bodyPartFolderRootOpt then
			reporter:fail(ErrorSourceStrings.Keys.CurveAnim_NoJointManipulation)
			return
		end
		local bodyPartFolderRoot = bodyPartFolderRootOpt :: Folder

		local instancesToCheck = bodyPartFolderRoot:GetDescendants()
		table.insert(instancesToCheck, bodyPartFolderRoot)
		local found = false
		for _, desc in instancesToCheck do
			if desc:IsA("Folder") then
				if CurveAnimationHierarchyUtils.getBodyPartToParentMap()[desc.Name] then
					local pos = desc:FindFirstChild("Position")
					local rot = desc:FindFirstChild("Rotation")
					if pos and pos:IsA("Vector3Curve") and rot and rot:IsA("EulerRotationCurve") then
						found = true
						break
					end
				end
			end
		end
		if not found then
			reporter:fail(ErrorSourceStrings.Keys.CurveAnim_NoJointManipulation)
			return
		end
	end
end

return CurveAnimJointsManipulated :: Types.ValidationModule
