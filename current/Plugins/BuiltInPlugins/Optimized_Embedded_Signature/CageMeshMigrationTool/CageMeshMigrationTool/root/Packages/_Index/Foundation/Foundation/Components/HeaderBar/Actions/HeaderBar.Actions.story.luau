local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local HeaderBar = require(Foundation.Components.HeaderBar)
local HeaderBarSlot = require(Foundation.Enums.HeaderBarSlot)
local HeaderBarStoryHelpers = require(Foundation.Components.HeaderBar.HeaderBarStoryHelpers)
local MatrixGridShared = require(Foundation.Utility.Stories.Shared.MatrixGrid)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local View = require(Foundation.Components.View)

local MatrixSection = StorySection.MatrixSection
local Section = StorySection.Section
local STORY_PAGE_TAG = StorySection.STORY_PAGE_COL_TAG
local matrixLabel = MatrixGridShared.matrixLabel

type HeaderBarAction = HeaderBar.HeaderBarAction
type HeaderBarSlot = HeaderBarSlot.HeaderBarSlot

type Controls = {
	parentSlot: HeaderBarSlot,
	actionCount: number,
}

local MOBILE_PARENT_WIDTH = HeaderBarStoryHelpers.MOBILE_PARENT_WIDTH

local LEADING_ACTIONS = HeaderBarStoryHelpers.LEADING_ACTIONS
local TRAILING_ACTIONS = HeaderBarStoryHelpers.TRAILING_ACTIONS

local LabeledShell = HeaderBarStoryHelpers.LabeledShell
local takeActions = HeaderBarStoryHelpers.takeActions

local function actionsForSlot(slot: HeaderBarSlot, count: number): { HeaderBarAction }
	local source = if slot == HeaderBarSlot.Leading then LEADING_ACTIONS else TRAILING_ACTIONS
	return takeActions(source, count)
end

local ACTION_SLOT_ORDER: { HeaderBarSlot } = {
	HeaderBarSlot.Leading,
	HeaderBarSlot.Trailing,
}

local ACTION_COUNTS = { 1, 2, 3 }
local MAX_ACTION_COUNT = ACTION_COUNTS[#ACTION_COUNTS]
local MAX_LEADING_ACTION_COUNT = 2

local ACTION_COUNT_LABEL_WIDTH = 120
local MATRIX_CELL_WIDTH = MOBILE_PARENT_WIDTH + 20

local function actionsSlot(slot: HeaderBarSlot, actions: { HeaderBarAction }): React.ReactNode
	local row = React.createElement(HeaderBar.Actions, {
		actions = actions,
	})

	if slot == HeaderBarSlot.Leading then
		return React.createElement(HeaderBar.Leading, nil, { Actions = row })
	end

	return React.createElement(HeaderBar.Trailing, nil, { Actions = row })
end

local function SlotCell(props: {
	LayoutOrder: number,
	label: string?,
	slot: HeaderBarSlot,
	actions: { HeaderBarAction },
	width: number?,
})
	local slotElement = actionsSlot(props.slot, props.actions)

	return React.createElement(LabeledShell, {
		LayoutOrder = props.LayoutOrder,
		label = props.label,
		width = props.width,
		leading = if props.slot == HeaderBarSlot.Leading then slotElement else nil,
		trailing = if props.slot == HeaderBarSlot.Trailing then slotElement else nil,
	})
end

local function PlaygroundStory(props: { controls: Controls }): React.ReactNode
	local controls = props.controls

	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Cell = React.createElement(SlotCell, {
			LayoutOrder = 1,
			label = `Slot: {controls.parentSlot}`,
			slot = controls.parentSlot,
			actions = actionsForSlot(controls.parentSlot, controls.actionCount),
		}),
	})
end

local function SlotStory(): React.ReactNode
	local cells: { [string]: React.ReactNode } = {}
	for index, slot: HeaderBarSlot in ACTION_SLOT_ORDER do
		cells[slot] = React.createElement(SlotCell, {
			LayoutOrder = index,
			label = `{slot}`,
			slot = slot,
			actions = actionsForSlot(slot, 1),
		})
	end

	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Slot = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Slot",
			note = "Actions has no slot prop; alignment comes from HeaderBar.Leading or HeaderBar.Trailing.",
		}, cells),
	})
end

local function actionCountRows(): { MatrixGridShared.MatrixGridRow }
	local rows: { MatrixGridShared.MatrixGridRow } = {}
	for index, actionCount in ACTION_COUNTS do
		local leadingCell: React.ReactNode = if actionCount <= MAX_LEADING_ACTION_COUNT
			then React.createElement(SlotCell, {
				LayoutOrder = 1,
				slot = HeaderBarSlot.Leading,
				actions = actionsForSlot(HeaderBarSlot.Leading, actionCount),
				width = MOBILE_PARENT_WIDTH,
			})
			else React.createElement(View, {
				tag = "auto-xy",
				LayoutOrder = 1,
			})

		rows[index] = {
			label = matrixLabel(`{actionCount} of {MAX_ACTION_COUNT} actions`),
			cells = {
				leadingCell,
				React.createElement(SlotCell, {
					LayoutOrder = 2,
					slot = HeaderBarSlot.Trailing,
					actions = actionsForSlot(HeaderBarSlot.Trailing, actionCount),
					width = MOBILE_PARENT_WIDTH,
				}),
			},
		}
	end
	return rows
end

local function ContentStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		ActionCount = React.createElement(MatrixSection, {
			LayoutOrder = 1,
			name = "Action count",
			note = `Leading is swept to {MAX_LEADING_ACTION_COUNT} actions, so the last row has a Trailing cell only.`,
			labelColumnWidth = ACTION_COUNT_LABEL_WIDTH,
			columnHeaders = { "Leading", "Trailing" },
			cellColumnWidth = MATRIX_CELL_WIDTH,
			rows = actionCountRows(),
		}),
	})
end

return {
	summary = "A row of icon buttons built from a declarative list of actions, placed in the Leading or Trailing slot of a HeaderBar and aligned to that slot's outer edge.",
	stories = {
		{
			name = "Playground",
			story = PlaygroundStory :: unknown,
		},
		{
			name = "Slot",
			story = SlotStory,
		},
		{
			name = "Content",
			story = ContentStory,
		},
	},
	controls = {
		parentSlot = ACTION_SLOT_ORDER,
		actionCount = ACTION_COUNTS,
	},
}
