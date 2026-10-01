--[[
	SurfaceAppearancePresent checks that all MeshParts without a TextureID have a
	SurfaceAppearance child, and that MeshParts with a TextureID do not have a child
	SurfaceAppearance.
]]

local root = script.Parent.Parent.Parent

local Types = require(root.util.Types)
local ValidationEnums = require(root.validationSystem.ValidationEnums)
local ErrorSourceStrings = require(root.validationSystem.ErrorSourceStrings)

-- IEC consumers (in-experience). Read directly from `source` (always populated)
-- so the IEC alternate-content path works regardless of consumer surface.
local IEC_SOURCES = {
	InExpServer = true,
	InExpClient = true,
}

local SurfaceAppearancePresent = {}

SurfaceAppearancePresent.categories = {
	ValidationEnums.UploadCategory.TORSO_AND_LIMBS,
	ValidationEnums.UploadCategory.DYNAMIC_HEAD,
	ValidationEnums.UploadCategory.RIGID_ACCESSORY,
}

SurfaceAppearancePresent.requiredData = {}

SurfaceAppearancePresent.expectedFailures = {}

SurfaceAppearancePresent.run = function(reporter: Types.ValidationReporter, data: Types.SharedData)
	local rootInstance = data.rootInstance
	-- Lifecycle (honest origin): IEC-origin keeps the editable-instance allowance even when re-run on a VaaS backend.
	local allowEditableInstances = IEC_SOURCES[data.consumerConfig.source] == true

	local allDescendants: { Instance } = rootInstance:GetDescendants()
	table.insert(allDescendants, rootInstance)

	for _, descendant in allDescendants do
		if not descendant:IsA("MeshPart") then
			continue
		end

		local meshPartHasTexture = (descendant :: MeshPart).TextureID ~= ""
		if allowEditableInstances and not meshPartHasTexture then
			local textureContent = (descendant :: MeshPart).TextureContent
			meshPartHasTexture = (textureContent.Uri ~= nil and textureContent.Uri ~= "")
				or textureContent.Object ~= nil
		end
		local surfaceAppearance = descendant:FindFirstChildWhichIsA("SurfaceAppearance")

		if meshPartHasTexture then
			if surfaceAppearance then
				reporter:fail(ErrorSourceStrings.Keys.SurfaceAppearance_TextureAndSABothDefined, {
					MeshPartFullName = (descendant :: Instance):GetFullName(),
				}, descendant)
			end
		elseif not surfaceAppearance then
			reporter:fail(ErrorSourceStrings.Keys.SurfaceAppearance_MissingSA, {
				MeshPartFullName = (descendant :: Instance):GetFullName(),
			}, descendant)
		end
	end
end

return SurfaceAppearancePresent :: Types.ValidationModule
