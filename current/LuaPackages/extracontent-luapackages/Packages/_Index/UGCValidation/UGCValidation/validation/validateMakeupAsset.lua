local root = script.Parent.Parent

local Types = require(root.util.Types)

local validateTags = require(root.validation.validateTags)
local validateSingleInstance = require(root.validation.validateSingleInstance)
local validateDependencies = require(root.validation.validateDependencies)

local FailureReasonsAccumulator = require(root.util.FailureReasonsAccumulator)
local getFFlagUGCValidateMakeupCategoryParity = require(root.flags.getFFlagUGCValidateMakeupCategoryParity)

local function validateMakeupAsset(validationContext: Types.ValidationContext): (boolean, { string }?)
	local instances = validationContext.instances :: { Instance }

	local success: boolean, reasons: any
	if not getFFlagUGCValidateMakeupCategoryParity() then
		success, reasons = validateSingleInstance(instances, validationContext)
		if not success then
			return false, reasons
		end
	end

	local instance = instances[1]

	do
		-- Skip flags collapse validateDependencies to a no-op once migration is on.
		local skipFlags = {
			skipExistenceCheck = true,
			skipOwnershipCheck = true,
		}
		success, reasons = validateDependencies(instance, validationContext, skipFlags)
		if not success then
			return false, reasons
		end
	end

	local reasonsAccumulator = FailureReasonsAccumulator.new()

	if not getFFlagUGCValidateMakeupCategoryParity() then
		reasonsAccumulator:updateReasons(validateTags(instance, validationContext))
	end

	return reasonsAccumulator:getFinalResults()
end

return validateMakeupAsset
