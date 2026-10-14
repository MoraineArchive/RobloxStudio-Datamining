local Foundation = script:FindFirstAncestor("Foundation")

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local LinkVariant = require(Foundation.Enums.LinkVariant)
type LinkVariant = LinkVariant.LinkVariant

local Types = require(Foundation.Components.Types)
type ColorStyleValue = Types.ColorStyleValue

local composeStyleVariant = require(Foundation.Utility.composeStyleVariant)
type VariantProps = composeStyleVariant.VariantProps

local VariantsContext = require(Foundation.Providers.Style.VariantsContext)

local Tokens = require(Foundation.Providers.Style.Tokens)
type Tokens = Tokens.Tokens

type LinkVariantProps = {
	container: { tag: string },
	text: { tag: string },
	content: { style: ColorStyleValue },
}

local function variantsFactory(tokens: Tokens)
	local common = {
		container = {
			tag = "row align-y-center auto-xy",
		},
		text = {
			tag = "auto-xy",
		},
	}

	local variants: { [LinkVariant]: VariantProps } = {
		[LinkVariant.Standard] = {
			content = { style = tokens.Color.Content.Emphasis },
		},
		[LinkVariant.Inverse] = {
			content = { style = tokens.Inverse.Content.Default },
		},
	}

	local sizes: { [InputSize]: VariantProps } = {
		[InputSize.XSmall] = {
			text = { tag = "text-body-small" },
		},
		[InputSize.Small] = {
			text = { tag = "text-body-small" },
		},
		[InputSize.Medium] = {
			text = { tag = "text-body-medium" },
		},
		[InputSize.Large] = {
			text = { tag = "text-body-large" },
		},
	}

	return { common = common, variants = variants, sizes = sizes }
end

return function(tokens: Tokens, size: InputSize, variant: LinkVariant): LinkVariantProps
	local resolved = VariantsContext.useVariants("Link", variantsFactory, tokens)
	return composeStyleVariant(resolved.common, resolved.variants[variant], resolved.sizes[size])
end
