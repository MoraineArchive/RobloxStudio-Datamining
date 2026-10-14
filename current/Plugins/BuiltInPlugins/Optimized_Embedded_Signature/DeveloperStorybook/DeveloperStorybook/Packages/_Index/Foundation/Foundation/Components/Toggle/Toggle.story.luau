local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local Dash = require(Packages.Dash)
local React = require(Packages.React)

local MatrixGridShared = require(Foundation.Utility.Stories.Shared.MatrixGrid)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local Toggle = require(Foundation.Components.Toggle)
local View = require(Foundation.Components.View)

local InputPlacement = require(Foundation.Enums.InputPlacement)
type InputPlacement = InputPlacement.InputPlacement
local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local matrixLabel = MatrixGridShared.matrixLabel
type MatrixGridRow = MatrixGridShared.MatrixGridRow

local Section = StorySection.Section
local LabeledCell = StorySection.LabeledCell
local StoryMatrixGrid = StorySection.StoryMatrixGrid

local STORY_FRAME_TAG = "padding-y-large bg-surface-0"

local SIZE_ORDER: { InputSize } = {
	InputSize.XSmall,
	InputSize.Small,
	InputSize.Medium,
	InputSize.Large,
}

local PLACEMENT_ORDER: { InputPlacement } = {
	InputPlacement.Start,
	InputPlacement.End,
}

local LABEL = "Label"
local HINT = "Hint text"
local LONG_LABEL = "This is a longer toggle label than the container fits on a single line"
local LONG_HINT = "A longer hint that also runs past the width its container gives it"

local LABEL_COLUMN_WIDTH = 150
local CELL_COLUMN_WIDTH = 170
local BOUNDED_WIDTH = 200

type StateFixture = {
	label: string,
	isChecked: boolean,
	hint: string?,
}

local STATE_ORDER: { StateFixture } = {
	{ label = "isChecked = false", isChecked = false },
	{ label = "isChecked = true", isChecked = true },
	{ label = "hint", isChecked = false, hint = HINT },
}

local SIZE_HEADERS = MatrixGridShared.enumHeaders(SIZE_ORDER)

local function noop(_value: boolean) end

local function BoundedFrame(props: {
	children: React.ReactNode,
})
	return React.createElement(View, {
		tag = "auto-y",
		Size = UDim2.fromOffset(BOUNDED_WIDTH, 0),
	}, props.children)
end

type PlaygroundControls = {
	label: string,
	hint: string?,
	size: InputSize,
	placement: InputPlacement,
	isChecked: boolean,
	isDisabled: boolean,
}

local function PlaygroundStory(props: { controls: PlaygroundControls })
	local controls = props.controls

	return React.createElement(View, {
		tag = `auto-xy {STORY_FRAME_TAG}`,
	}, {
		Toggle = React.createElement(Toggle, {
			label = controls.label,
			hint = if controls.hint ~= "" then controls.hint else nil,
			isChecked = controls.isChecked,
			isDisabled = controls.isDisabled,
			size = controls.size,
			placement = controls.placement,
			onActivated = noop,
		}),
	})
end

local function SizingStory()
	return React.createElement(View, {
		tag = `col auto-xy {STORY_FRAME_TAG}`,
	}, {
		Size = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Size",
			contentTag = "auto-xy",
		}, {
			Grid = React.createElement(StoryMatrixGrid, {
				LayoutOrder = 1,
				showLabelColumn = false,
				labelColumnWidth = LABEL_COLUMN_WIDTH,
				cellColumnWidth = CELL_COLUMN_WIDTH,
				columnHeaders = SIZE_HEADERS,
				rows = {
					{
						label = matrixLabel(""),
						cells = Dash.map(SIZE_ORDER, function(size)
							return React.createElement(Toggle, {
								label = LABEL,
								size = size,
								isChecked = false,
								onActivated = noop,
							})
						end),
					},
				},
			}),
		}),
	})
end

local function PlacementStory()
	return React.createElement(
		View,
		{
			tag = `row align-y-top gap-xxlarge auto-xy {STORY_FRAME_TAG}`,
		},
		Dash.map(PLACEMENT_ORDER, function(placement, index)
			return React.createElement(LabeledCell, {
				LayoutOrder = index,
				label = placement,
			}, {
				Toggle = React.createElement(Toggle, {
					label = LABEL,
					placement = placement,
					isChecked = false,
					onActivated = noop,
				}),
			})
		end)
	)
end

local function stateToggle(fixture: StateFixture, size: InputSize?, isDisabled: boolean?)
	return React.createElement(Toggle, {
		label = LABEL,
		hint = fixture.hint,
		isChecked = fixture.isChecked,
		isDisabled = isDisabled,
		size = size,
		onActivated = noop,
	})
end

local function StatesStory()
	local fixtures = table.clone(STATE_ORDER)

	return React.createElement(View, {
		tag = `col gap-xxlarge auto-xy {STORY_FRAME_TAG}`,
	}, {
		Grid = React.createElement(StoryMatrixGrid, {
			LayoutOrder = 1,
			labelColumnWidth = LABEL_COLUMN_WIDTH,
			cellColumnWidth = CELL_COLUMN_WIDTH,
			columnHeaders = SIZE_HEADERS,
			rows = Dash.map(fixtures, function(fixture): MatrixGridRow
				return {
					label = matrixLabel(fixture.label),
					cells = Dash.map(SIZE_ORDER, function(size)
						return stateToggle(fixture, size)
					end),
				}
			end),
		}),
		Disabled = React.createElement(
			Section,
			{
				LayoutOrder = 2,
				name = "Disabled",
			},
			Dash.map(fixtures, function(fixture, index)
				return React.createElement(LabeledCell, {
					LayoutOrder = index,
					label = fixture.label,
				}, {
					Toggle = stateToggle(fixture, nil, true),
				})
			end)
		),
	})
end

local function ControlledExample(props: {
	LayoutOrder: number,
})
	local isChecked, setIsChecked = React.useState(false)

	return React.createElement(Toggle, {
		label = LABEL,
		isChecked = isChecked,
		onActivated = setIsChecked,
		LayoutOrder = props.LayoutOrder,
	})
end

local function ControlledStory()
	return React.createElement(View, {
		tag = `auto-xy {STORY_FRAME_TAG}`,
	}, {
		Example = React.createElement(ControlledExample, { LayoutOrder = 1 }),
	})
end

local function wrappingCells(): { React.ReactNode }
	local hint = LONG_HINT
	return Dash.map(PLACEMENT_ORDER, function(placement, index)
		return React.createElement(LabeledCell, {
			LayoutOrder = index,
			label = placement,
		}, {
			Frame = React.createElement(BoundedFrame, {}, {
				Toggle = React.createElement(Toggle, {
					label = LONG_LABEL,
					hint = hint,
					placement = placement,
					isChecked = false,
					onActivated = noop,
				}),
			}),
		})
	end)
end

local function ContentStory()
	return React.createElement(View, {
		tag = `col gap-xxlarge auto-xy {STORY_FRAME_TAG}`,
	}, {
		Wrapping = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Wrapping",
		}, wrappingCells()),
	})
end

local controls: { [string]: unknown } = {
	label = LABEL,
	size = SIZE_ORDER,
	placement = PLACEMENT_ORDER,
	isChecked = false,
	isDisabled = false,
	hint = HINT,
}

return {
	summary = "Toggle turns a single boolean on or off, with an optional label and hint beside it.",
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
			name = "Placement",
			story = PlacementStory,
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
	controls = controls,
}
