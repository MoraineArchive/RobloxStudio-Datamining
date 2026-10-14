local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local BuilderIcons = require(Packages.BuilderIcons)
local Dash = require(Packages.Dash)
local React = require(Packages.React)

local Breadcrumb = require(Foundation.Components.Breadcrumb)
local InputSize = require(Foundation.Enums.InputSize)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)

local IconName = BuilderIcons.Icon

type InputSize = InputSize.InputSize
type BreadcrumbItem = Breadcrumb.BreadcrumbItem

type Controls = {
	size: InputSize,
	separator: string,
	maxItems: number,
	itemsBeforeCollapse: number,
	itemsAfterCollapse: number,
}

local SIZE_ORDER: { InputSize } = {
	InputSize.Small,
	InputSize.Medium,
	InputSize.Large,
}

local function noop() end

local DEFAULT_ITEMS: { BreadcrumbItem } = {
	{ text = "Home", onActivated = noop },
	{ text = "Games", onActivated = noop },
	{ text = "Tower Defense Simulator" },
}

local PLAYGROUND_ITEMS: { BreadcrumbItem } = {
	{ text = "Home", onActivated = noop },
	{ text = "Games", onActivated = noop },
	{ text = "Simulator", onActivated = noop },
	{ text = "Worlds", onActivated = noop },
	{ text = "Maps", onActivated = noop },
	{ text = "Tower Defense Simulator", onActivated = noop },
}

local ICON_ITEMS: { BreadcrumbItem } = {
	{ text = "Home", onActivated = noop, leading = IconName.House },
	{ text = "Games", onActivated = noop, leading = IconName.Controller },
	{ text = "Tower Defense Simulator", leading = IconName.Star },
}

local AVATAR_ITEMS: { BreadcrumbItem } = {
	{ text = "Builderman", onActivated = noop, leading = { type = "Avatar", userId = 156 } },
	{ text = "Games", onActivated = noop },
	{ text = "Tower Defense Simulator" },
}

local TRAILING_ITEMS: { BreadcrumbItem } = {
	{ text = "Home", onActivated = noop },
	{ text = "Games", onActivated = noop, trailing = IconName.ChevronLargeDown },
	{ text = "Tower Defense Simulator" },
}

local COLLAPSE_ITEMS: { BreadcrumbItem } = {
	{ text = "Home", onActivated = noop },
	{ text = "Games", onActivated = noop },
	{ text = "Tower Defense", onActivated = noop },
	{ text = "Maps", onActivated = noop },
	{ text = "Hardcore Mode" },
}

local function Section(props: {
	LayoutOrder: number,
	name: string,
	note: string?,
	contentTag: string?,
	children: React.ReactNode,
})
	return React.createElement(View, {
		tag = "col gap-medium size-full-0 auto-y",
		LayoutOrder = props.LayoutOrder,
	}, {
		Title = React.createElement(Text, {
			Text = props.name,
			tag = "auto-xy text-label-medium content-default",
			LayoutOrder = 1,
		}),
		Note = if props.note
			then React.createElement(Text, {
				Text = props.note,
				tag = "auto-xy text-caption-small text-wrap text-align-x-left content-muted",
				LayoutOrder = 2,
			})
			else nil,
		Content = React.createElement(View, {
			tag = props.contentTag or "col gap-large size-full-0 auto-y",
			LayoutOrder = 3,
		}, props.children),
	})
end

local function LabeledBreadcrumb(props: {
	label: string,
	LayoutOrder: number,
	size: InputSize?,
	items: { BreadcrumbItem },
})
	return React.createElement(View, {
		tag = "col gap-small auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = React.createElement(Text, {
			Text = props.label,
			tag = "auto-xy text-caption-small text-align-x-left content-default",
			LayoutOrder = 1,
		}),
		Breadcrumb = React.createElement(Breadcrumb, {
			size = props.size,
			items = props.items,
			LayoutOrder = 2,
		}),
	})
end

local function PlaygroundStory(props: { controls: Controls }): React.ReactNode
	local controls = props.controls

	return React.createElement(View, {
		tag = "col align-x-left gap-large size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Breadcrumb = React.createElement(Breadcrumb, {
			size = controls.size,
			separator = controls.separator,
			maxItems = controls.maxItems,
			itemsBeforeCollapse = controls.itemsBeforeCollapse,
			itemsAfterCollapse = controls.itemsAfterCollapse,
			items = PLAYGROUND_ITEMS,
			LayoutOrder = 1,
		}),
	})
end

local function CollapsedStory(): React.ReactNode
	return React.createElement(View, {
		tag = "col align-x-left gap-large size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Collapsed = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Collapsed",
			note = "When items exceed maxItems, the middle crumbs collapse into an overflow button; activating it reveals the full trail.",
			contentTag = "col gap-large align-x-left auto-xy",
		}, {
			Breadcrumb = React.createElement(Breadcrumb, {
				maxItems = 3,
				items = COLLAPSE_ITEMS,
				LayoutOrder = 1,
			}),
		}),
	})
end

local function SizingStory(): React.ReactNode
	return React.createElement(View, {
		tag = "col gap-xxlarge size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Size = React.createElement(
			Section,
			{
				LayoutOrder = 1,
				name = "Size",
				contentTag = "col gap-large align-x-left auto-xy",
			},
			Dash.map(SIZE_ORDER, function(size, index)
				return React.createElement(LabeledBreadcrumb, {
					label = size :: string,
					LayoutOrder = index,
					size = size,
					items = DEFAULT_ITEMS,
				})
			end)
		),
	})
end

local function ContentStory(): React.ReactNode
	return React.createElement(View, {
		tag = "col gap-xxlarge size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Accessories = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Accessories",
			note = 'Each item can carry a leading and/or trailing accessory — an icon (name), an avatar ({ type = "Avatar", userId }), or a media image (asset string). The last item is always the current page.',
			contentTag = "col gap-large align-x-left auto-xy",
		}, {
			LeadingIcon = React.createElement(LabeledBreadcrumb, {
				label = "Leading icon",
				LayoutOrder = 1,
				items = ICON_ITEMS,
			}),
			LeadingAvatar = React.createElement(LabeledBreadcrumb, {
				label = "Leading avatar",
				LayoutOrder = 2,
				items = AVATAR_ITEMS,
			}),
			Trailing = React.createElement(LabeledBreadcrumb, {
				label = "Trailing accessory",
				LayoutOrder = 3,
				items = TRAILING_ITEMS,
			}),
		}),
	})
end

return {
	summary = "A list of links that shows a page's place in a hierarchy and lets users navigate to any ancestor.",
	stories = {
		{
			name = "Playground",
			story = PlaygroundStory :: unknown,
		},
		{
			name = "Sizing",
			story = SizingStory,
		},
		{
			name = "Collapsed",
			story = CollapsedStory,
		},
		{
			name = "Content",
			story = ContentStory,
		},
	},
	controls = {
		size = SIZE_ORDER,
		separator = { "/", "›" },
		maxItems = { 8, 3, 4, 5 },
		itemsBeforeCollapse = { 1, 2 },
		itemsAfterCollapse = { 1, 2 },
	},
}
