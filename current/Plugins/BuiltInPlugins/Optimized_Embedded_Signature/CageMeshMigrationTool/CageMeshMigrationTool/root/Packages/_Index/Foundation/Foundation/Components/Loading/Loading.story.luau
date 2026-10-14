local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Dash = require(Packages.Dash)
local React = require(Packages.React)

local IconSize = require(Foundation.Enums.IconSize)
local Loading = require(Foundation.Components.Loading)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)

local Section = StorySection.Section

type IconSize = IconSize.IconSize

local SIZE_ORDER: { IconSize } = {
	IconSize.XSmall,
	IconSize.Small,
	IconSize.Medium,
	IconSize.Large,
	IconSize.XLarge,
	IconSize.XXLarge,
}

local PLAYGROUND_SIZE_OPTIONS: { IconSize } = {
	IconSize.Large,
	IconSize.XSmall,
	IconSize.Small,
	IconSize.Medium,
	IconSize.XLarge,
	IconSize.XXLarge,
}

local function SizeColumn(props: {
	LayoutOrder: number,
	size: IconSize,
}): React.ReactNode
	return React.createElement(View, {
		tag = "col align-x-center gap-small auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = React.createElement(Text, {
			Text = props.size :: string,
			tag = "auto-xy text-caption-small content-muted",
			LayoutOrder = 1,
		}),
		Spinner = React.createElement(Loading, {
			size = props.size,
			LayoutOrder = 2,
		}),
	})
end

local function PlaygroundStory(props: {
	controls: {
		size: IconSize,
	},
}): React.ReactNode
	return React.createElement(View, {
		tag = "row align-y-center auto-xy padding-y-large bg-surface-0",
	}, {
		Loading = React.createElement(Loading, {
			size = props.controls.size,
		}),
	})
end

local function SizingStory(): React.ReactNode
	return React.createElement(View, {
		tag = StorySection.STORY_PAGE_COL_TAG,
	}, {
		Size = React.createElement(
			Section,
			{
				LayoutOrder = 1,
				name = "Size",
			},
			Dash.map(SIZE_ORDER, function(size, index)
				return React.createElement(SizeColumn, {
					LayoutOrder = index,
					size = size,
				})
			end)
		),
	})
end

return {
	summary = "Loading is a spinning icon that indicates in-progress work.",
	stories = {
		{ name = "Playground", story = PlaygroundStory :: unknown },
		{ name = "Sizing", story = SizingStory },
	},
	controls = {
		size = PLAYGROUND_SIZE_OPTIONS,
	},
}
