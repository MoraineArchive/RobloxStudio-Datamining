local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Dash = require(Packages.Dash)
local React = require(Packages.React)

local SearchInput = require(Foundation.Components.SearchInput)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local View = require(Foundation.Components.View)

local Section = StorySection.Section
local LabeledCell = StorySection.LabeledCell

local InputSize = require(Foundation.Enums.InputSize)
local InputVariant = require(Foundation.Enums.InputVariant)
local SearchInputShape = require(Foundation.Enums.SearchInputShape)

type InputSize = InputSize.InputSize
type InputVariant = InputVariant.InputVariant
type SearchInputShape = SearchInputShape.SearchInputShape
type SearchInputElementProps = SearchInput.SearchInputProps & { key: string? }

local SIZE_ORDER: { InputSize } = {
	InputSize.XSmall,
	InputSize.Small,
	InputSize.Medium,
	InputSize.Large,
}

local VARIANT_ORDER: { InputVariant } = {
	InputVariant.Standard,
	InputVariant.Contrast,
	InputVariant.Utility,
}

local SHAPE_ORDER: { SearchInputShape } = {
	SearchInputShape.Rounded,
	SearchInputShape.Pill,
	SearchInputShape.Box,
}

local QUERY_TEXT = "Query"
local PLACEHOLDER_TEXT = "Placeholder"

local STORY_PAGE_TAG = StorySection.STORY_PAGE_COL_TAG
local SWEEP_TAG = "col gap-xlarge size-full-0 auto-y"
local SWEEP_ROW_TAG = "row wrap align-y-top gap-large size-full-0 auto-y"
local SWEEP_ROW_PAGE_TAG = "row wrap align-y-top gap-large size-full-0 auto-y padding-y-large bg-surface-0"
local WIDTH_FRAME_WIDTH = 600
local SWEEP_CELL_WIDTH = 240

local WIDTH_EXAMPLES: { { label: string, width: UDim } } = {
	{ label = "Fixed", width = UDim.new(0, 240) },
	{ label = "Fill", width = UDim.new(1, 0) },
}

local function noop() end

type StaticSearchInputProps = {
	text: string,
	placeholder: string?,
	size: InputSize?,
	variant: InputVariant?,
	shape: SearchInputShape?,
	width: UDim?,
	hasClearButton: boolean?,
	hasError: boolean?,
	isDisabled: boolean?,
	LayoutOrder: number?,
}

-- Snaps the cell back to its seeded props once a reviewer types into it, so a static
-- matrix keeps documenting the props it was authored with.
local function StaticSearchInput(props: StaticSearchInputProps): React.ReactNode
	local remountKey, setRemountKey = React.useState(0)

	return React.createElement(
		SearchInput,
		Dash.join(props, {
			key = tostring(remountKey),
			onChanged = function()
				setRemountKey(function(key)
					return key + 1
				end)
			end,
		}) :: SearchInputElementProps
	)
end

local function WidthFrame(props: { children: React.ReactNode? })
	return React.createElement(View, {
		tag = "col size-full-0 auto-y padding-medium radius-medium bg-surface-100",
		Size = UDim2.fromOffset(WIDTH_FRAME_WIDTH, 0),
	}, props.children)
end

type PlaygroundControls = {
	text: string,
	placeholder: string,
	size: InputSize,
	variant: InputVariant,
	shape: SearchInputShape,
	widthOffset: number,
	hasClearButton: boolean,
	hasError: boolean,
	isDisabled: boolean,
}

local function PlaygroundStory(props: { controls: PlaygroundControls }): React.ReactNode
	local controls = props.controls

	return React.createElement(View, {
		tag = "col gap-large size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Input = React.createElement(SearchInput, {
			LayoutOrder = 1,
			text = controls.text,
			onChanged = noop,
			placeholder = if controls.placeholder == "" then nil else controls.placeholder,
			size = controls.size,
			variant = controls.variant,
			shape = controls.shape,
			width = if controls.widthOffset == 0 then nil else UDim.new(0, controls.widthOffset),
			hasClearButton = controls.hasClearButton,
			hasError = controls.hasError,
			isDisabled = controls.isDisabled,
		}),
	})
end

local function VariantsStory(): React.ReactNode
	return React.createElement(
		View,
		{
			tag = SWEEP_ROW_PAGE_TAG,
		},
		Dash.map(VARIANT_ORDER, function(variant, index)
			return React.createElement(
				LabeledCell,
				{ LayoutOrder = index, label = variant },
				React.createElement(StaticSearchInput, {
					text = QUERY_TEXT,
					variant = variant,
					width = UDim.new(0, SWEEP_CELL_WIDTH),
				})
			)
		end)
	)
end

local function SizingStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Size = React.createElement(
			Section,
			{
				LayoutOrder = 1,
				name = "Size",
				note = "Cells share one width so only the scaling differs.",
				contentTag = SWEEP_ROW_TAG,
			},
			Dash.map(SIZE_ORDER, function(size, index)
				return React.createElement(
					LabeledCell,
					{ LayoutOrder = index, label = size },
					React.createElement(StaticSearchInput, {
						text = QUERY_TEXT,
						size = size,
						width = UDim.new(0, SWEEP_CELL_WIDTH),
					})
				)
			end)
		),
		Width = React.createElement(
			Section,
			{
				LayoutOrder = 2,
				name = "Width",
				note = "Omitting width falls back to a 400px footprint scaled for the platform. Cells sit in a 600px frame so Fill has a parent to fill.",
				contentTag = SWEEP_TAG,
			},
			Dash.map(WIDTH_EXAMPLES, function(example, index)
				return React.createElement(
					LabeledCell,
					{ LayoutOrder = index, label = example.label },
					React.createElement(
						WidthFrame,
						{},
						React.createElement(StaticSearchInput, {
							text = QUERY_TEXT,
							width = example.width,
							LayoutOrder = 1,
						})
					)
				)
			end)
		),
	})
end

local function ShapeStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Shape = React.createElement(
			Section,
			{
				LayoutOrder = 1,
				name = "Shape",
				note = "Rounded has no entry in the shape-to-radius map, so it uses the size's default radius.",
				contentTag = SWEEP_ROW_TAG,
			},
			Dash.map(SHAPE_ORDER, function(shape, index)
				return React.createElement(
					LabeledCell,
					{
						LayoutOrder = index,
						label = if shape == SearchInputShape.Pill then `{shape} (default)` else shape,
					},
					React.createElement(StaticSearchInput, {
						text = QUERY_TEXT,
						shape = shape,
						width = UDim.new(0, SWEEP_CELL_WIDTH),
					})
				)
			end)
		),
	})
end

local function StatesStory(): React.ReactNode
	return React.createElement(View, {
		tag = SWEEP_ROW_PAGE_TAG,
	}, {
		Disabled = React.createElement(
			LabeledCell,
			{ LayoutOrder = 1, label = "isDisabled" },
			React.createElement(StaticSearchInput, {
				text = QUERY_TEXT,
				isDisabled = true,
				width = UDim.new(0, SWEEP_CELL_WIDTH),
			})
		),
		Error = React.createElement(
			LabeledCell,
			{ LayoutOrder = 2, label = "hasError" },
			React.createElement(StaticSearchInput, {
				text = QUERY_TEXT,
				hasError = true,
				width = UDim.new(0, SWEEP_CELL_WIDTH),
			})
		),
	})
end

local function ControlledStory(): React.ReactNode
	local text, setText = React.useState("")

	local function onChanged(newText: string)
		setText(newText)
	end

	return React.createElement(View, {
		tag = "col size-full-0 auto-y padding-y-large bg-surface-0",
	}, {
		Input = React.createElement(SearchInput, {
			LayoutOrder = 1,
			text = text,
			onChanged = onChanged,
			placeholder = PLACEHOLDER_TEXT,
			hasClearButton = true,
		}),
	})
end

local function ContentStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		ClearButton = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Clear button",
			note = "The clear affordance is only rendered while the field holds text, so the cells are seeded. Clearing is in Controlled component. hasClearButton defaults to true.",
			contentTag = SWEEP_ROW_TAG,
		}, {
			Present = React.createElement(
				LabeledCell,
				{ LayoutOrder = 1, label = "hasClearButton = true" },
				React.createElement(StaticSearchInput, {
					text = QUERY_TEXT,
					hasClearButton = true,
				})
			),
			Absent = React.createElement(
				LabeledCell,
				{ LayoutOrder = 2, label = "hasClearButton = false" },
				React.createElement(StaticSearchInput, {
					text = QUERY_TEXT,
					hasClearButton = false,
				})
			),
		}),
		Placeholder = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Placeholder",
			note = "Without a placeholder the component falls back to a localized Search string.",
			contentTag = SWEEP_ROW_TAG,
		}, {
			Default = React.createElement(
				LabeledCell,
				{ LayoutOrder = 1, label = "default" },
				React.createElement(StaticSearchInput, {
					text = "",
				})
			),
			Custom = React.createElement(
				LabeledCell,
				{
					LayoutOrder = 2,
					label = `placeholder = "{PLACEHOLDER_TEXT}"`,
				},
				React.createElement(StaticSearchInput, {
					text = "",
					placeholder = PLACEHOLDER_TEXT,
				})
			),
		}),
	})
end

return {
	summary = "Search field with a leading search icon, an optional clear affordance, and a shape axis.",
	stories = {
		{
			name = "Playground",
			story = PlaygroundStory :: unknown,
		},
		{
			name = "Variants",
			story = VariantsStory,
		},
		{
			name = "Sizing",
			story = SizingStory,
		},
		{
			name = "Shape",
			story = ShapeStory,
		},
		{
			name = "States",
			story = StatesStory,
		},
		{
			name = "Controlled component",
			story = ControlledStory,
		},
		{
			name = "Content",
			story = ContentStory,
		},
	},
	controls = {
		text = QUERY_TEXT,
		placeholder = "",
		size = SIZE_ORDER,
		variant = VARIANT_ORDER,
		shape = SHAPE_ORDER,
		widthOffset = 0,
		hasClearButton = true,
		hasError = false,
		isDisabled = false,
	},
}
