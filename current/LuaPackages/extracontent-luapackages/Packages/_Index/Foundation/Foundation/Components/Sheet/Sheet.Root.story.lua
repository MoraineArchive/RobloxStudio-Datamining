local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local Dash = require(Packages.Dash)
local React = require(Packages.React)

local Button = require(Foundation.Components.Button)
local ButtonVariant = require(Foundation.Enums.ButtonVariant)
local DialogSize = require(Foundation.Enums.DialogSize)
local FillBehavior = require(Foundation.Enums.FillBehavior)
local MatrixGridShared = require(Foundation.Utility.Stories.Shared.MatrixGrid)
local Sheet = require(Foundation.Components.Sheet)
local SheetStoryHelpers = require(script.Parent.SheetStoryHelpers)
local Text = require(Foundation.Components.Text)
local TextInput = require(Foundation.Components.TextInput)
local View = require(Foundation.Components.View)

local LabeledSheetTrigger = SheetStoryHelpers.LabeledSheetTrigger
local Section = SheetStoryHelpers.Section
local SheetMatrix = SheetStoryHelpers.SheetMatrix
local columnLabels = SheetStoryHelpers.columnLabels
local makeSheetChildren = SheetStoryHelpers.makeSheetChildren
local placeholderText = SheetStoryHelpers.placeholderText
local prefersCenter = SheetStoryHelpers.prefersCenter
local variantRows = SheetStoryHelpers.variantRows
local variantTrigger = SheetStoryHelpers.variantTrigger

type DialogSize = DialogSize.DialogSize
type SheetVariant = SheetStoryHelpers.SheetVariant

type ControlledExampleProps = {
	LayoutOrder: number?,
}

type BehaviorExampleProps = {
	LayoutOrder: number,
}

type AutomaticSizingExampleProps = {
	LayoutOrder: number,
	label: string,
	initialRowCount: number,
}

local VARIANT_ORDER: { SheetVariant } = SheetStoryHelpers.VARIANT_ORDER
local VARIANT_HEADERS = SheetStoryHelpers.VARIANT_HEADERS
local SIZE_ORDER: { DialogSize } = SheetStoryHelpers.SIZE_ORDER
local PLAYGROUND_SIZE_OPTIONS: { DialogSize } = {
	SheetStoryHelpers.DEFAULT_SIZE,
	DialogSize.Small,
	DialogSize.Large,
}
local WIDE_CELL_WIDTH = SheetStoryHelpers.WIDE_CELL_WIDTH
local OVERFLOW_LIST_LENGTH = SheetStoryHelpers.OVERFLOW_LIST_LENGTH
local SNAP_POINTS_FIXTURE = { 0.5, 0.9 }
local FULL_BLEED_ASPECT_RATIO = 16 / 9
local AUTO_SIZE_ROW_HEIGHT = 56
local AUTO_SIZE_ROW_COUNTS = { 1, 4, 16 }
local HUG_COLUMNS: { { label: string, rowCount: number } } = Dash.map(AUTO_SIZE_ROW_COUNTS, function(count)
	return {
		label = if count == 1 then "1 row" else `{count} rows`,
		rowCount = count,
	}
end)
local SUBPART_ORDER: { SheetStoryHelpers.SheetSlot } = { "Header", "Content", "Actions" }
local SNAP_POINT_PRESETS = {
	Default = nil :: { number }?,
	["Half and tall"] = { 0.5, 0.9 },
}
local SNAP_POINT_COLUMNS: { { label: string, snapPoints: { number }? } } = {
	{ label = "nil (hug content)" },
	{ label = "0.5 (half screen)", snapPoints = { 0.5 } },
	{ label = "0.75 (three quarters)", snapPoints = { 0.75 } },
	{ label = "1 (fill screen)", snapPoints = { 1 } },
}
local CENTER_HEIGHT_COLUMNS: { { label: string, height: number? } } = {
	{ label = "nil (hug content)" },
	{ label = "0.5 (half max height)", height = 0.5 },
	{ label = "1 (full max height)", height = 1 },
}

type Controls = {
	sheetTypePreset: SheetVariant,
	size: DialogSize,
	centerSheetHeightPreset: string,
	snapPointsPreset: string,
	defaultSnapPointIndex: number,
	showHeader: boolean,
	showContent: boolean,
	showActions: boolean,
	showFullBleed: boolean,
}

type StoryProps = {
	controls: Controls,
}

local function sizeForVariant(variant: SheetVariant, size: DialogSize): DialogSize?
	if not prefersCenter(variant) and size == DialogSize.Small then
		return nil
	end
	return if size == SheetStoryHelpers.DEFAULT_SIZE then nil else size
end

local function centerHeightFromLabel(label: string): number?
	for _, column in CENTER_HEIGHT_COLUMNS do
		if column.label == label then
			return column.height
		end
	end
	return nil
end

local function AutoSizeRow(props: { label: string, LayoutOrder: number })
	return React.createElement(View, {
		tag = "row align-x-center align-y-center size-full-0 radius-medium bg-shift-200",
		Size = UDim2.new(1, 0, 0, AUTO_SIZE_ROW_HEIGHT),
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = React.createElement(Text, {
			Text = props.label,
			tag = "auto-xy text-label-medium content-muted",
			LayoutOrder = 1,
		}),
	})
end

local function makeHugSheetChildren(rowCount: number): { [string]: React.ReactNode }
	local rows: { [string]: React.ReactNode } = {}
	for index = 1, rowCount do
		rows[`Row{index}`] = React.createElement(AutoSizeRow, {
			label = `Row {index}`,
			LayoutOrder = index,
		})
	end

	return {
		Header = React.createElement(Sheet.Header, nil, {
			Title = placeholderText("Header", 1),
		}),
		Content = React.createElement(Sheet.Content, nil, rows),
		Actions = React.createElement(Sheet.Actions, nil, {
			Label = placeholderText("Actions", 1),
		}),
	}
end

local function PlaygroundStory(props: StoryProps)
	local controls = props.controls

	return React.createElement(View, {
		tag = SheetStoryHelpers.PLAYGROUND_TAG,
	}, {
		Trigger = React.createElement(LabeledSheetTrigger, {
			size = sizeForVariant(controls.sheetTypePreset, controls.size),
			preferCenterSheet = prefersCenter(controls.sheetTypePreset),
			centerSheetHeight = centerHeightFromLabel(controls.centerSheetHeightPreset),
			snapPoints = SNAP_POINT_PRESETS[controls.snapPointsPreset],
			defaultSnapPointIndex = controls.defaultSnapPointIndex,
			childrenOptions = {
				showHeader = controls.showHeader,
				showContent = controls.showContent,
				showActions = controls.showActions,
				showFullBleed = controls.showFullBleed,
			},
		}),
	})
end

local function PreferCenterSheetStory()
	return React.createElement(View, {
		tag = SheetStoryHelpers.PLAYGROUND_TAG,
	}, {
		Grid = React.createElement(SheetMatrix, {
			showLabelColumn = false,
			columnHeaders = VARIANT_HEADERS,
			rows = {
				{
					cells = Dash.map(VARIANT_ORDER, function(variant)
						return React.createElement(LabeledSheetTrigger, {
							preferCenterSheet = prefersCenter(variant),
						})
					end),
				},
			},
		}),
	})
end

local function SizingStory()
	return React.createElement(View, {
		tag = SheetStoryHelpers.PAGE_TAG,
	}, {
		Size = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Size",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				columnHeaders = MatrixGridShared.enumHeaders(SIZE_ORDER),
				rows = variantRows(function(variant)
					return Dash.map(SIZE_ORDER, function(size)
						if not prefersCenter(variant) and size == DialogSize.Small then
							return React.createElement(Text, {
								Text = "—",
								tag = "auto-xy text-caption-small content-muted",
							})
						end
						return variantTrigger(variant, {
							size = if size == SheetStoryHelpers.DEFAULT_SIZE then nil else size,
						})
					end)
				end),
			}),
		}),
		Height = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Height",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				showLabelColumn = false,
				columnHeaders = columnLabels(CENTER_HEIGHT_COLUMNS),
				cellColumnWidth = WIDE_CELL_WIDTH,
				rows = {
					{
						cells = Dash.map(CENTER_HEIGHT_COLUMNS, function(column)
							return React.createElement(LabeledSheetTrigger, {
								preferCenterSheet = true,
								centerSheetHeight = column.height,
							})
						end),
					},
				},
			}),
		}),
		SnapPoints = React.createElement(Section, {
			LayoutOrder = 3,
			name = "snapPoints",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				showLabelColumn = false,
				columnHeaders = columnLabels(SNAP_POINT_COLUMNS),
				cellColumnWidth = WIDE_CELL_WIDTH,
				rows = {
					{
						cells = Dash.map(SNAP_POINT_COLUMNS, function(column)
							return React.createElement(LabeledSheetTrigger, {
								snapPoints = column.snapPoints,
							})
						end),
					},
				},
			}),
		}),
		Hug = React.createElement(Section, {
			LayoutOrder = 4,
			name = "Hug",
			note = "`snapPoints` omitted: height follows payload. Sixteen rows is past available height, so the sheet clamps and content scrolls.",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				showLabelColumn = false,
				columnHeaders = columnLabels(HUG_COLUMNS),
				cellColumnWidth = WIDE_CELL_WIDTH,
				rows = {
					{
						cells = Dash.map(HUG_COLUMNS, function(column)
							return React.createElement(LabeledSheetTrigger, {
								children = makeHugSheetChildren(column.rowCount),
							})
						end),
					},
				},
			}),
		}),
	})
end

local function SnapPointScrollExample(props: BehaviorExampleProps)
	local isOpen, setIsOpen = React.useState(false)
	local snapPoint, setSnapPoint = React.useState(SNAP_POINTS_FIXTURE[1])

	return React.createElement(View, {
		tag = "col gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		SnapPoint = React.createElement(Text, {
			Text = `snapPoint: {snapPoint}`,
			tag = "auto-xy text-body-medium content-default",
			LayoutOrder = 1,
		}),
		Open = React.createElement(Button, {
			text = "Open",
			onActivated = function()
				setIsOpen(true)
			end,
			variant = ButtonVariant.Emphasis,
			LayoutOrder = 2,
		}),
		SheetRoot = if isOpen
			then React.createElement(
				Sheet.Root,
				{
					isOpen = true,
					snapPoints = SNAP_POINTS_FIXTURE,
					onSnapPointChanged = function(value: number)
						setSnapPoint(value)
					end,
					onClose = function()
						setIsOpen(false)
					end,
				},
				makeSheetChildren({
					showHeader = false,
					showFullBleed = true,
					fullBleedAspectRatio = FULL_BLEED_ASPECT_RATIO,
					contentListLength = OVERFLOW_LIST_LENGTH,
					actionCount = 1,
				})
			)
			else nil,
	})
end

local function ScrollFocusExample(props: BehaviorExampleProps)
	local isOpen, setIsOpen = React.useState(false)
	local text, setText = React.useState("")

	return React.createElement(View, {
		tag = "col gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Open = React.createElement(Button, {
			text = "Open",
			onActivated = function()
				setIsOpen(true)
			end,
			variant = ButtonVariant.Emphasis,
			LayoutOrder = 1,
		}),
		SheetRoot = if isOpen
			then React.createElement(Sheet.Root, {
				isOpen = true,
				snapPoints = SNAP_POINTS_FIXTURE,
				onClose = function()
					setIsOpen(false)
				end,
			}, {
				Header = React.createElement(Sheet.Header, nil, {
					Title = placeholderText("Header", 1),
				}),
				Content = React.createElement(Sheet.Content, nil, {
					Field = React.createElement(TextInput, {
						label = "Label",
						text = text,
						width = UDim.new(1, 0),
						onChanged = function(value: string)
							setText(value)
						end,
						LayoutOrder = 1,
					}),
				}),
				Actions = React.createElement(Sheet.Actions, nil, {
					Primary = React.createElement(Button, {
						text = "Primary",
						variant = ButtonVariant.Emphasis,
						fillBehavior = FillBehavior.Fill,
						onActivated = function()
							setIsOpen(false)
						end,
						LayoutOrder = 1,
					}),
				}),
			})
			else nil,
	})
end

local function AutomaticSizingExample(props: AutomaticSizingExampleProps)
	local isOpen, setIsOpen = React.useState(false)
	local rowCount, setRowCount = React.useState(props.initialRowCount)

	return React.createElement(View, {
		tag = "col gap-small auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Label = React.createElement(Text, {
			Text = props.label,
			tag = "auto-xy text-caption-small text-align-x-left content-default",
			LayoutOrder = 1,
		}),
		Open = React.createElement(Button, {
			text = "Open",
			onActivated = function()
				setIsOpen(true)
			end,
			variant = ButtonVariant.Emphasis,
			LayoutOrder = 2,
		}),
		SheetRoot = if isOpen
			then React.createElement(
				Sheet.Root,
				{
					isOpen = true,
					onClose = function()
						setIsOpen(false)
					end,
				},
				Dash.join(makeHugSheetChildren(rowCount), {
					Actions = React.createElement(Sheet.Actions, nil, {
						Add = React.createElement(Button, {
							text = "Add row",
							variant = ButtonVariant.Emphasis,
							fillBehavior = FillBehavior.Fill,
							onActivated = function()
								setRowCount(function(count)
									return count + 1
								end)
							end,
							LayoutOrder = 1,
						}),
						Remove = React.createElement(Button, {
							text = "Remove row",
							fillBehavior = FillBehavior.Fill,
							onActivated = function()
								setRowCount(function(count)
									return math.max(1, count - 1)
								end)
							end,
							LayoutOrder = 2,
						}),
					}),
				})
			)
			else nil,
	})
end

local function SnappingAndScrollingStory()
	return React.createElement(View, {
		tag = SheetStoryHelpers.PAGE_TAG,
	}, {
		SnapPoints = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Snap points",
			note = "Bottom sheet only (Small display size, portrait): tap the gripper to cycle snap points, and content scrolls only once the sheet is at its tallest one.",
			contentTag = "auto-xy",
		}, {
			Example = React.createElement(SnapPointScrollExample, {
				LayoutOrder = 1,
			}),
		}),
		Focus = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Focus",
			note = "The drag surface must not swallow the press that focuses the field.",
			contentTag = "auto-xy",
		}, {
			Example = React.createElement(ScrollFocusExample, {
				LayoutOrder = 1,
			}),
		}),
	})
end

local function AutomaticSizingStory()
	local examples: { [string]: React.ReactNode } = {}
	for index, column in HUG_COLUMNS do
		examples[`Rows{column.rowCount}`] = React.createElement(AutomaticSizingExample, {
			label = column.label,
			initialRowCount = column.rowCount,
			LayoutOrder = index,
		})
	end

	return React.createElement(View, {
		tag = SheetStoryHelpers.PAGE_TAG,
	}, {
		ContentChanges = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Content changes",
			note = "With `snapPoints` omitted the sheet hugs its content and re-measures as rows are added or removed; past the available height it clamps and the content scrolls instead.",
			contentTag = "row gap-large align-y-top auto-xy",
		}, examples),
	})
end

local function IsOpenDrivenExample(props: ControlledExampleProps)
	local isOpen, setIsOpen = React.useState(false)

	return React.createElement(View, {
		tag = "col gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Status = React.createElement(Text, {
			Text = if isOpen then "Open" else "Closed",
			tag = "auto-xy text-body-medium content-default",
			LayoutOrder = 1,
		}),
		Toggle = React.createElement(Button, {
			text = if isOpen then "Close" else "Open",
			onActivated = function()
				setIsOpen(not isOpen)
			end,
			variant = if isOpen then ButtonVariant.Standard else ButtonVariant.Emphasis,
			LayoutOrder = 2,
		}),
		SheetRoot = React.createElement(Sheet.Root, {
			isOpen = isOpen,
			onClose = function()
				setIsOpen(false)
			end,
		}, makeSheetChildren()),
	})
end

local function ControlledStory()
	return React.createElement(View, {
		tag = SheetStoryHelpers.PAGE_TAG,
	}, {
		IsOpen = React.createElement(Section, {
			LayoutOrder = 1,
			name = "isOpen",
			contentTag = "auto-xy",
		}, {
			Example = React.createElement(IsOpenDrivenExample, {
				LayoutOrder = 1,
			}),
		}),
	})
end

local function ContentStory()
	return React.createElement(View, {
		tag = SheetStoryHelpers.PAGE_TAG,
	}, {
		Subparts = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Subparts",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				columnHeaders = MatrixGridShared.enumHeaders(SUBPART_ORDER),
				rows = variantRows(function(variant)
					return Dash.map(SUBPART_ORDER, function(slot)
						return variantTrigger(variant, {
							childrenOptions = {
								highlightedSlot = slot,
							},
						})
					end)
				end),
			}),
		}),
		CloseAffordance = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Close affordance",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				columnHeaders = { "Header", "No header" },
				rows = variantRows(function(variant)
					return {
						variantTrigger(variant),
						variantTrigger(variant, {
							childrenOptions = { showHeader = false },
						}),
					}
				end),
			}),
		}),
		Overflow = React.createElement(Section, {
			LayoutOrder = 3,
			name = "Overflow",
			contentTag = SheetStoryHelpers.MATRIX_SECTION_TAG,
		}, {
			Grid = React.createElement(SheetMatrix, {
				showLabelColumn = false,
				columnHeaders = VARIANT_HEADERS,
				rows = {
					{
						cells = Dash.map(VARIANT_ORDER, function(variant)
							return variantTrigger(variant, {
								centerSheetHeight = 0.5,
								childrenOptions = {
									contentListLength = OVERFLOW_LIST_LENGTH,
								},
							})
						end),
					},
				},
			}),
		}),
	})
end

return {
	summary = "A contextual overlay that switches among bottom, side, and center placement from viewport, orientation, and `preferCenterSheet`.",
	stories = {
		{ name = "Playground", story = PlaygroundStory :: unknown },
		{ name = "preferCenterSheet", story = PreferCenterSheetStory },
		{ name = "Sizing", story = SizingStory },
		{ name = "Snapping and scrolling", story = SnappingAndScrollingStory },
		{ name = "Automatic sizing", story = AutomaticSizingStory },
		{ name = "Controlled component", story = ControlledStory },
		{ name = "Content", story = ContentStory },
	},
	controls = {
		sheetTypePreset = VARIANT_ORDER,
		size = PLAYGROUND_SIZE_OPTIONS,
		centerSheetHeightPreset = columnLabels(CENTER_HEIGHT_COLUMNS),
		snapPointsPreset = { "Default", "Half and tall" },
		defaultSnapPointIndex = 1,
		showHeader = true,
		showContent = true,
		showActions = true,
		showFullBleed = false,
	},
}
