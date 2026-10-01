--[[
validate:
	check emote animations are set-up correctly
]]

local root = script.Parent.Parent

local util = root.util
local Types = require(util.Types)
local createEmoteSchema = require(util.createEmoteSchema)
local FailureReasonsAccumulator = require(util.FailureReasonsAccumulator)
local validation = root.validation
local validateSingleInstance = require(validation.validateSingleInstance)
local validateInstanceTree = require(validation.validateInstanceTree)
local validateTags = require(validation.validateTags)
local validateDependencies = require(validation.validateDependencies)
local ValidatePropertiesSensible = require(validation.ValidatePropertiesSensible)

local getEngineFeatureEngineUGCValidatePropertiesSensible =
	require(root.flags.getEngineFeatureEngineUGCValidatePropertiesSensible)

local ValidateEmoteAnimation = {}

function ValidateEmoteAnimation.validateStructure(
	validationContext: Types.ValidationContext
): (boolean, { string }?, Instance?)
	do
		local success, reasons = validateSingleInstance(validationContext.instances or {}, validationContext)
		if not success then
			return false, reasons
		end
	end

	local allInstances = validationContext.instances :: { Instance } -- validateSingleInstance() has checked this
	local instance = allInstances[1]
	do
		local success, reasons = validateInstanceTree(createEmoteSchema(), instance, validationContext)
		if not success then
			return false, reasons
		end
	end
	return true, nil, instance
end

function ValidateEmoteAnimation.validate(validationContext: Types.ValidationContext): (boolean, { string }?)
	local instance
	do
		local success, reasons, instOpt = ValidateEmoteAnimation.validateStructure(validationContext)
		if not success then
			return false, reasons
		end
		instance = instOpt :: Instance
	end

	if getEngineFeatureEngineUGCValidatePropertiesSensible() then
		local success, reasons = ValidatePropertiesSensible.validate(instance, validationContext)
		if not success then
			return false, reasons
		end
	end

	do
		local skipFlags = {
			skipExistenceCheck = true,
			skipOwnershipCheck = true,
		}
		local success, reasons = validateDependencies(instance, validationContext, skipFlags)
		if not success then
			return false, reasons
		end
	end

	local reasonsAccumulator = FailureReasonsAccumulator.new()
	reasonsAccumulator:updateReasons(validateTags(instance, validationContext))

	return reasonsAccumulator:getFinalResults()
end

return ValidateEmoteAnimation
