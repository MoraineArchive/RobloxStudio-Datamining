--[[
	validateMeshPartBodyPart.lua exposes common tests for MeshPart Dynamic heads and body parts
]]

local root = script.Parent.Parent

local Analytics = require(root.Analytics)

local validateDependencies = require(root.validation.validateDependencies)
local validateDescendantMeshMetrics = require(root.validation.validateDescendantMeshMetrics)
local validateTags = require(root.validation.validateTags)
local ValidatePropertiesSensible = require(root.validation.ValidatePropertiesSensible)

local validateWithSchema = require(root.util.validateWithSchema)
local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)
local ValidateMeshPartOnlySkinnedToR15 = require(root.validation.ValidateMeshPartOnlySkinnedToR15)
local getEngineFeatureEngineUGCValidatePropertiesSensible =
	require(root.flags.getEngineFeatureEngineUGCValidatePropertiesSensible)
local getFFlagUGCValidationEnableR15plusSkinning = require(root.flags.getFFlagUGCValidationEnableR15plusSkinning)

local resetPhysicsData = require(root.util.resetPhysicsData)
local Types = require(root.util.Types)

local function validateMeshPartBodyPart(
	inst: Instance,
	schema: any,
	validationContext: Types.ValidationContext
): (boolean, { string }?)
	local assetTypeEnum = validationContext.assetTypeEnum :: Enum.AssetType

	local validationResult = validateWithSchema(schema, inst, validationContext)
	if not validationResult.success then
		Analytics.reportFailure(Analytics.ErrorType.validateMeshPartBodyPart_ValidateWithSchema, nil, validationContext)
		return false,
			{
				string.format("Body part '%s' does not follow R15 schema. The specific issues are: ", inst.Name),
				validationResult.message,
			}
	end

	do
		local skipFlags = {
			skipExistenceCheck = true,
			skipOwnershipCheck = true,
		}
		local result, failureReasons = validateDependencies(inst, validationContext, skipFlags)
		if not result then
			return result, failureReasons
		end
	end

	--[[
		call resetPhysicsData() after checks above which are making sure mesh ids exist (as resetPhysicsData() uses meshIds) but before any checks
		for mesh size happen, as this removes physics data to ensure those size checks return accurate results
	]]
	local success, errorMessage = resetPhysicsData({ inst }, validationContext)
	if not success then
		return false, { errorMessage :: string }
	end

	if getEngineFeatureEngineUGCValidatePropertiesSensible() then
		local sensibleSuccess, sensibleErrorMessages = ValidatePropertiesSensible.validate(inst, validationContext)
		if not sensibleSuccess then
			return false, sensibleErrorMessages
		end
	end

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	reasonsAccumulator:updateReasons(validateDescendantMeshMetrics(inst, validationContext))

	reasonsAccumulator:updateReasons(validateTags(inst, validationContext))

	if not getFFlagUGCValidationEnableR15plusSkinning() then
		if assetTypeEnum ~= Enum.AssetType.DynamicHead then
			reasonsAccumulator:updateReasons(
				ValidateMeshPartOnlySkinnedToR15.validateBodyParts(inst, validationContext)
			)
		end
	end

	return reasonsAccumulator:getFinalResults()
end

return validateMeshPartBodyPart
