--[[
	AccurateBoundingBoxRasterUtil re-exports the raster method bounding box validation
	logic for consumption by the folder-based system. The implementation lives in
	src/validation/validateAccurateBoundingBoxRasterMethod.lua but new modules in
	src/validationFolders/ cannot import from src/validation/ directly.
]]

local root = script.Parent.Parent

local validateAccurateBoundingBoxRasterMethod = require(root.validation.validateAccurateBoundingBoxRasterMethod)

local AccurateBoundingBoxRasterUtil = {}

function AccurateBoundingBoxRasterUtil.getBoundsViewsForAssetType(assetType: Enum.AssetType): { [string]: boolean }?
	return validateAccurateBoundingBoxRasterMethod.getBoundsViewsForAssetType(assetType)
end

function AccurateBoundingBoxRasterUtil.validate(
	inst: Instance,
	bodyAssetMasksWrapper: any,
	validationContext: any
): (boolean, { string }?)
	return validateAccurateBoundingBoxRasterMethod.validate(inst, bodyAssetMasksWrapper, validationContext)
end

return AccurateBoundingBoxRasterUtil
