local Foundation = script:FindFirstAncestor("Foundation")

local IconSize = require(Foundation.Enums.IconSize)
type IconSize = IconSize.IconSize

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local AvatarIconSize = require(Foundation.Enums.AvatarIconSize)
type AvatarIconSize = AvatarIconSize.AvatarIconSize

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

export type BreadcrumbVariantProps = {
	container: { tag: string },
	item: { tag: string },
	itemText: { tag: string },
	separator: { tag: string, textTag: string, style: ColorStyleValue },
	current: { tag: string, style: ColorStyleValue },
	label: { tag: string, style: ColorStyleValue },
	accessory: {
		iconSize: IconSize,
		avatarSize: AvatarIconSize,
		size: UDim2,
		cornerRadius: UDim,
		style: ColorStyleValue,
	},
	overflow: { size: InputSize },
}

local function variantsFactory(tokens: Tokens)
	local common = {
		container = {
			tag = "row align-y-center auto-xy padding-y-xsmall",
		},
		item = {
			tag = "row align-y-center gap-small auto-xy",
		},
		itemText = {
			tag = "row align-y-center gap-xsmall auto-xy",
		},
		separator = {
			tag = "row align-x-center align-y-center size-600-0 auto-y",
			style = tokens.Color.Content.Default,
		},
		current = { style = tokens.Color.Content.Emphasis },
		label = { style = tokens.Color.Content.Emphasis },
		accessory = { style = tokens.Color.Content.Emphasis },
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			separator = { textTag = "auto-xy text-body-small" },
			current = { tag = "auto-xy text-title-small" },
			label = { tag = "auto-xy text-body-small" },
			accessory = {
				iconSize = IconSize.XSmall,
				avatarSize = AvatarIconSize.Small,
				size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
				cornerRadius = UDim.new(0, tokens.Radius.Small),
			},
			overflow = { size = InputSize.XSmall },
		},
		[InputSize.Small] = {
			separator = { textTag = "auto-xy text-body-small" },
			current = { tag = "auto-xy text-title-small" },
			label = { tag = "auto-xy text-body-small" },
			accessory = {
				iconSize = IconSize.XSmall,
				avatarSize = AvatarIconSize.Small,
				size = UDim2.fromOffset(tokens.Size.Size_400, tokens.Size.Size_400),
				cornerRadius = UDim.new(0, tokens.Radius.Small),
			},
			overflow = { size = InputSize.XSmall },
		},
		[InputSize.Medium] = {
			separator = { textTag = "auto-xy text-body-medium" },
			current = { tag = "auto-xy text-title-medium" },
			label = { tag = "auto-xy text-body-medium" },
			accessory = {
				iconSize = IconSize.Small,
				avatarSize = AvatarIconSize.Medium,
				size = UDim2.fromOffset(tokens.Size.Size_500, tokens.Size.Size_500),
				cornerRadius = UDim.new(0, tokens.Radius.Small),
			},
			overflow = { size = InputSize.XSmall },
		},
		[InputSize.Large] = {
			separator = { textTag = "auto-xy text-body-large" },
			current = { tag = "auto-xy text-title-large" },
			label = { tag = "auto-xy text-body-large" },
			accessory = {
				iconSize = IconSize.Medium,
				avatarSize = AvatarIconSize.Large,
				size = UDim2.fromOffset(tokens.Size.Size_600, tokens.Size.Size_600),
				cornerRadius = UDim.new(0, tokens.Radius.Medium),
			},
			overflow = { size = InputSize.Small },
		},
	}

	return { common = common, sizes = sizes }
end

return function(tokens: Tokens, size: InputSize): BreadcrumbVariantProps
	local variants = VariantsContext.useVariants("Breadcrumb", variantsFactory, tokens)
	return composeStyleVariant(variants.common, variants.sizes[size])
end
