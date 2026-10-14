local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local React = require(Packages.React)

local Link = require(Foundation.Components.Link)
local View = require(Foundation.Components.View)

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize
local LinkVariant = require(Foundation.Enums.LinkVariant)
type LinkVariant = LinkVariant.LinkVariant

local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local Section = StorySection.Section

local VARIANT_ORDER: { LinkVariant } = {
	LinkVariant.Standard,
	LinkVariant.Inverse,
}

local SIZE_ORDER: { InputSize } = {
	InputSize.Small,
	InputSize.Medium,
	InputSize.Large,
}

local VARIANT_SURFACE_TAG: { [LinkVariant]: string } = {
	[LinkVariant.Standard] = "bg-surface-0",
	[LinkVariant.Inverse] = "bg-system-contrast",
}

local function noop() end

type LabeledLinkProps = {
	label: string,
	variant: LinkVariant,
	size: InputSize?,
	hasUnderline: boolean?,
	LayoutOrder: number,
}

local function LabeledLink(props: LabeledLinkProps)
	return React.createElement(View, {
		tag = `col align-x-center gap-xsmall auto-xy padding-medium radius-medium {VARIANT_SURFACE_TAG[props.variant]}`,
		LayoutOrder = props.LayoutOrder,
	}, {
		Sample = React.createElement(Link, {
			text = props.label,
			variant = props.variant,
			size = props.size,
			hasUnderline = props.hasUnderline,
			onActivated = noop,
			LayoutOrder = 1,
		}),
	})
end

local function PlaygroundStory(props)
	return React.createElement(View, {
		tag = "align-x-center align-y-center size-full-full padding-large bg-surface-0",
	}, {
		Link = React.createElement(Link, {
			text = "Link",
			variant = props.controls.variant,
			size = props.controls.size,
			hasUnderline = props.controls.hasUnderline,
			onActivated = noop,
		}),
	})
end

local function VariantStory()
	local samples: { [string]: React.ReactNode } = {}
	for index, variant in VARIANT_ORDER do
		samples["Variant-" .. variant] = React.createElement(LabeledLink, {
			label = variant,
			variant = variant :: LinkVariant,
			LayoutOrder = index,
		})
	end

	return React.createElement(View, {
		tag = "col gap-large size-full-0 auto-y padding-large bg-surface-0",
	}, {
		Variants = React.createElement(Section, {
			name = "Variant",
			note = "Standard is neutral; Inverse is for inverted surfaces (a surface whose theme is flipped, e.g. a light tooltip in dark theme).",
			LayoutOrder = 1,
		}, samples),
	})
end

local function SizingStory()
	local samples: { [string]: React.ReactNode } = {}
	for index, size in SIZE_ORDER do
		samples["Size-" .. size] = React.createElement(LabeledLink, {
			label = size,
			variant = LinkVariant.Standard,
			size = size :: InputSize,
			LayoutOrder = index,
		})
	end

	return React.createElement(View, {
		tag = "col gap-large size-full-0 auto-y padding-large bg-surface-0",
	}, {
		Sizes = React.createElement(Section, {
			name = "Size",
			note = "Text scales with the body typography ramp.",
			LayoutOrder = 1,
		}, samples),
	})
end

local function UnderlineStory()
	return React.createElement(View, {
		tag = "col gap-large size-full-0 auto-y padding-large bg-surface-0",
	}, {
		Underline = React.createElement(Section, {
			name = "Underline",
			note = "Underline shows on hover/focus by default; set hasUnderline to keep it visible at rest.",
			LayoutOrder = 1,
		}, {
			Default = React.createElement(LabeledLink, {
				label = "hover/focus (default)",
				variant = LinkVariant.Standard,
				hasUnderline = false,
				LayoutOrder = 1,
			}),
			Persistent = React.createElement(LabeledLink, {
				label = "hasUnderline",
				variant = LinkVariant.Standard,
				hasUnderline = true,
				LayoutOrder = 2,
			}),
		}),
	})
end

return {
	summary = "Link is an interactive text control that navigates to another resource; it underlines on hover/focus and shows a focus ring while selected.",
	stories = {
		{
			name = "Playground",
			story = PlaygroundStory :: unknown,
		},
		{
			name = "Variant",
			story = VariantStory,
		},
		{
			name = "Sizing",
			story = SizingStory,
		},
		{
			name = "Underline",
			story = UnderlineStory,
		},
	},
	controls = {
		variant = VARIANT_ORDER,
		size = SIZE_ORDER,
		hasUnderline = false,
	},
}
