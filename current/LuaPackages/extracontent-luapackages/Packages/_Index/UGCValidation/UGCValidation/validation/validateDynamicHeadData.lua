--!nocheck

--nocheck is temporary as UGCValidationService:GetDynamicHeadMeshInactiveControls() is a new function

--[[
	validateDynamicHeadData.lua checks the head mesh for FACS data and controls
]]

local UGCValidationService = game:GetService("UGCValidationService")

local root = script.Parent.Parent

local Analytics = require(root.Analytics)
local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)

local UGCValidateFacialBoundsScale = game:DefineFastInt("UGCValidateFacialBoundsScale", 120) / 100
local getExpectedPartSize = require(root.util.getExpectedPartSize)
local Types = require(root.util.Types)
local pcallDeferred = require(root.util.pcallDeferred)
local getEditableMeshFromContext = require(root.util.getEditableMeshFromContext)

local getEngineFeatureEngineUGCValidateMinMaxMeshSizeAcrossAllFacs =
	require(root.flags.getEngineFeatureEngineUGCValidateMinMaxMeshSizeAcrossAllFacs)

local MESH_DATA_LOAD_FAILED_STRING: string =
	"Failed to load mesh data for '%s'. Make sure the mesh exists and try again."
local function validateFacialBounds(
	meshPartHead: MeshPart,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local isServer = validationContext.isServer

	local success, result = pcallDeferred(function()
		local partSize = getExpectedPartSize(meshPartHead, validationContext)

		local getEditableMeshSuccess, editableMesh =
			getEditableMeshFromContext(meshPartHead, "MeshId", validationContext)
		if not getEditableMeshSuccess then
			error("Failed to retrieve MeshContent")
		end
		return UGCValidationService:ValidateEditableMeshFacialBounds(
			editableMesh,
			UGCValidateFacialBoundsScale,
			partSize
		)
	end, validationContext)

	if not success then
		local errorMessage = string.format(MESH_DATA_LOAD_FAILED_STRING, meshPartHead:GetFullName())
		if nil ~= isServer and isServer then
			error(errorMessage)
		end
		return false, { errorMessage }
	elseif not result then
		return false,
			{
				string.format(
					"DynamicHead (%s) when emoting surpasses the expected bounding box",
					meshPartHead:GetFullName()
				),
			}
	end

	return true
end

local function validateDynamicHeadData(
	meshPartHead: MeshPart,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local startTime = tick()

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	if not getEngineFeatureEngineUGCValidateMinMaxMeshSizeAcrossAllFacs() then
		-- moved to new system
		reasonsAccumulator:updateReasons(validateFacialBounds(meshPartHead, validationContext))
	end

	Analytics.recordScriptTime(script.Name, startTime, validationContext)
	return reasonsAccumulator:getFinalResults()
end

return validateDynamicHeadData
