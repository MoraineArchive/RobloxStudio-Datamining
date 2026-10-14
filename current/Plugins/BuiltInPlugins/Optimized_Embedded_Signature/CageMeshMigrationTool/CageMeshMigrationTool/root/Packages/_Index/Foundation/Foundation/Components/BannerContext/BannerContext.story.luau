local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent
local BuilderIcons = require(Packages.BuilderIcons)
local React = require(Packages.React)

local Alert = require(Foundation.Components.Alert)
local AlertVariant = require(Foundation.Enums.AlertVariant)
local BannerContext = require(Foundation.Components.BannerContext)
local BannerContextPresentation = require(Foundation.Enums.BannerContextPresentation)
local BannerContextVariant = require(Foundation.Enums.BannerContextVariant)
local Breakpoint = require(Foundation.Enums.Breakpoint)
local BreakpointConfig = require(Foundation.Utility.Responsive.BreakpointConfig)
local Button = require(Foundation.Components.Button)
local ButtonVariant = require(Foundation.Enums.ButtonVariant)
local MatrixGridShared = require(Foundation.Utility.Stories.Shared.MatrixGrid)
local StoryIcons = require(Foundation.Utility.Stories.Shared.StoryIcons)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local Types = require(Foundation.Components.Types)
local View = require(Foundation.Components.View)

local IconName = BuilderIcons.Icon
local IconVariant = BuilderIcons.IconVariant
local enumHeaders = MatrixGridShared.enumHeaders
local matrixInfoLabel = MatrixGridShared.matrixInfoLabel
local matrixLabel = MatrixGridShared.matrixLabel
local LabeledCell = StorySection.LabeledCell
local MatrixSection = StorySection.MatrixSection
local Section = StorySection.Section
local StoryMatrixGrid = StorySection.StoryMatrixGrid

type AlertVariant = AlertVariant.AlertVariant
type BannerContextPresentation = BannerContextPresentation.BannerContextPresentation
type BannerContextVariant = BannerContextVariant.BannerContextVariant
type IconConfig = Types.IconConfig
type MatrixGridRow = MatrixGridShared.MatrixGridRow

local PAGE_TAG = `col {StorySection.STORY_PAGE_TAG}`
local PAGE_COL_TAG = StorySection.STORY_PAGE_COL_TAG
local HUG_PAGE_TAG = `col auto-xy {StorySection.STORY_FRAME_TAG}`
local FULL_WIDTH_CELL_TAG = "col align-x-left gap-small size-full-0 auto-y"
local WIDTH_PAIR_TAG = "row wrap align-y-top gap-xlarge auto-xy"
local STACKED_SECTION_TAG = "col gap-large size-full-0 auto-y"

local VARIANT_ORDER: { BannerContextVariant } = {
	BannerContextVariant.Standard,
	BannerContextVariant.Emphasis,
}

local PRESENTATION_ORDER: { BannerContextPresentation } = {
	BannerContextPresentation.Inline,
	BannerContextPresentation.Affixed,
}

local VARIANT_HEADERS: { string } = enumHeaders(VARIANT_ORDER)
local PRESENTATION_HEADERS: { string } = enumHeaders(PRESENTATION_ORDER)

local PLAYGROUND_ICON_OPTIONS = StoryIcons.buildIconControlOptions()

local INLINE_WIDTH = 720
local STACKED_WIDTH = BreakpointConfig.widths[Breakpoint.XSmall]
local ICON_CELL_WIDTH = BreakpointConfig.widths[Breakpoint.XSmall]
local OCCUPANCY_LABEL_COLUMN_WIDTH = 160
local ICON_TYPE_LABEL_COLUMN_WIDTH = 240
local EXAMPLE_ICON = IconName.RobloxPlus
local DEFAULT_TEXT = "Banner context text"
local LONG_TEXT = "This is a longer banner context that demonstrates how supporting text truncates in limited space."
local SHORT_LINK_TEXT = "Read schedule"
local LONG_LINK_TEXT = "Read the full announcement and what it means for your experience"

type OccupancyCase = {
	label: string,
	icon: string?,
	hasLink: boolean,
	hasClose: boolean,
}

local OCCUPANCY_CASES: { OccupancyCase } = {
	{ label = "Text", hasLink = false, hasClose = false },
	{ label = "Icon", icon = EXAMPLE_ICON, hasLink = false, hasClose = false },
	{ label = "Link", hasLink = true, hasClose = false },
	{ label = "Close", hasLink = false, hasClose = true },
	{ label = "Link + close", hasLink = true, hasClose = true },
	{ label = "Icon + link + close", icon = EXAMPLE_ICON, hasLink = true, hasClose = true },
}

local WIDTH_CASES = {
	{ key = "Stacked", width = STACKED_WIDTH, caption = `≤{STACKED_WIDTH}px — stacked` },
	{ key = "Inline", width = INLINE_WIDTH, caption = `{INLINE_WIDTH}px (after {STACKED_WIDTH}px) — inline` },
}

local SIBLING_HEADERS: { string } = { "Alert", "BannerContext" }
local SIBLING_TEXT = "Notice text"
-- Both columns have to fit on screen for the comparison to read, and both components stack their
-- trailing slot at or below the XSmall breakpoint, so this sits between the two.
local SIBLING_WIDTH = 420
local SIBLING_LABEL_COLUMN_WIDTH = 140

-- Pairs the containment treatments the two components share: a rounded stroked card, and a
-- full-bleed row with top and bottom edge borders.
type SiblingCase = {
	presentation: BannerContextPresentation,
	alertVariant: AlertVariant,
}

local SIBLING_CASES: { SiblingCase } = {
	{
		presentation = BannerContextPresentation.Inline,
		alertVariant = AlertVariant.Feedback,
	},
	{
		presentation = BannerContextPresentation.Affixed,
		alertVariant = AlertVariant.System,
	},
}

type WrappingConfig = {
	label: string,
	linkText: string,
}

local WRAPPING_CONFIGS: { WrappingConfig } = {
	{ label = "Short link + close", linkText = SHORT_LINK_TEXT },
	{
		label = "Link + close — the link stacks once it needs more than the message minimum leaves",
		linkText = LONG_LINK_TEXT,
	},
}

local function noop() end

local function BoundedBannerContext(props: {
	width: number,
	LayoutOrder: number,
	children: React.ReactNode,
})
	return React.createElement(View, {
		Size = UDim2.fromOffset(props.width, 0),
		tag = "auto-y",
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

local function LabeledExample(props: {
	label: string,
	width: number?,
	LayoutOrder: number,
	children: React.ReactNode,
})
	if props.width == nil then
		return React.createElement(LabeledCell, {
			LayoutOrder = props.LayoutOrder,
			label = props.label,
			tag = FULL_WIDTH_CELL_TAG,
			contentTag = "col size-full-0 auto-y",
		}, props.children)
	end

	return React.createElement(LabeledCell, {
		LayoutOrder = props.LayoutOrder,
		label = props.label,
	}, {
		Bounded = React.createElement(BoundedBannerContext, {
			width = props.width :: number,
			LayoutOrder = 1,
		}, props.children),
	})
end

local function WidthPair(props: {
	LayoutOrder: number,
	label: string,
	renderBanner: () -> React.ReactNode,
}): React.ReactNode
	local cells: { [string]: React.ReactNode } = {}
	for index, case in WIDTH_CASES do
		cells[case.key] = React.createElement(LabeledExample, {
			label = case.caption,
			width = case.width,
			LayoutOrder = index,
		}, {
			BannerContext = props.renderBanner(),
		})
	end

	return React.createElement(LabeledCell, {
		LayoutOrder = props.LayoutOrder,
		label = props.label,
		tag = FULL_WIDTH_CELL_TAG,
		contentTag = WIDTH_PAIR_TAG,
	}, cells)
end

local function PlaygroundStory(props: {
	controls: {
		variant: BannerContextVariant,
		presentation: BannerContextPresentation,
		text: string,
		icon: string,
		hasLink: boolean,
		isDismissable: boolean,
	},
})
	local controls = props.controls
	return React.createElement(View, {
		tag = PAGE_TAG,
	}, {
		BannerContext = React.createElement(BannerContext, {
			variant = controls.variant,
			presentation = controls.presentation,
			text = controls.text,
			icon = StoryIcons.parseIconControl(controls.icon),
			link = if controls.hasLink then { text = "Link", onActivated = noop } else nil,
			onClose = if controls.isDismissable then noop else nil,
			LayoutOrder = 1,
		}),
	})
end

local function VariantsStory()
	local rows: { MatrixGridRow } = {}
	for rowIndex, presentation in PRESENTATION_ORDER do
		local cells: { React.ReactNode } = {}
		for columnIndex, variant in VARIANT_ORDER do
			cells[columnIndex] = React.createElement(BoundedBannerContext, {
				width = INLINE_WIDTH,
				LayoutOrder = columnIndex,
			}, {
				BannerContext = React.createElement(BannerContext, {
					presentation = presentation :: BannerContextPresentation,
					variant = variant :: BannerContextVariant,
					text = DEFAULT_TEXT,
				}),
			})
		end
		rows[rowIndex] = {
			label = matrixLabel(presentation :: BannerContextPresentation),
			cells = cells,
		}
	end

	return React.createElement(View, {
		tag = HUG_PAGE_TAG,
	}, {
		Matrix = React.createElement(StoryMatrixGrid, {
			LayoutOrder = 1,
			columnHeaders = VARIANT_HEADERS,
			cellColumnWidth = INLINE_WIDTH,
			rowGap = "xxlarge",
			rows = rows,
		}),
	})
end

local function SizingStory()
	return React.createElement(View, {
		tag = PAGE_COL_TAG,
	}, {
		Width = React.createElement(Section, {
			name = "Width",
			LayoutOrder = 1,
			contentTag = STACKED_SECTION_TAG,
		}, {
			FullWidth = React.createElement(LabeledExample, {
				label = "Unconstrained — fills the parent",
				LayoutOrder = 1,
			}, {
				BannerContext = React.createElement(BannerContext, {
					text = DEFAULT_TEXT,
					link = { text = "Link", onActivated = noop },
				}),
			}),
			Inline = React.createElement(LabeledExample, {
				label = `{INLINE_WIDTH}px — inline`,
				width = INLINE_WIDTH,
				LayoutOrder = 2,
			}, {
				BannerContext = React.createElement(BannerContext, {
					text = DEFAULT_TEXT,
					link = { text = "Link", onActivated = noop },
				}),
			}),
			Stacked = React.createElement(LabeledExample, {
				label = `≤{STACKED_WIDTH}px — link stacks below the message`,
				width = STACKED_WIDTH,
				LayoutOrder = 3,
			}, {
				BannerContext = React.createElement(BannerContext, {
					text = DEFAULT_TEXT,
					link = { text = "Link", onActivated = noop },
				}),
			}),
		}),
	})
end

local function ControlledExample(props: {
	LayoutOrder: number,
})
	local isVisible, setIsVisible = React.useState(true)

	return React.createElement(LabeledExample, {
		label = "Dismissed by the close affordance",
		width = INLINE_WIDTH,
		LayoutOrder = props.LayoutOrder,
	}, {
		Content = if isVisible
			then React.createElement(BannerContext, {
				text = DEFAULT_TEXT,
				onClose = function()
					setIsVisible(false)
				end,
			})
			else React.createElement(Button, {
				text = "Show banner",
				variant = ButtonVariant.Standard,
				onActivated = function()
					setIsVisible(true)
				end,
			}),
	})
end

local function ControlledStory()
	return React.createElement(View, {
		tag = HUG_PAGE_TAG,
	}, {
		Example = React.createElement(ControlledExample, {
			LayoutOrder = 1,
		}),
	})
end

local function OccupancyBanner(props: {
	presentation: BannerContextPresentation,
	occupancyCase: OccupancyCase,
	LayoutOrder: number,
})
	local occupancyCase = props.occupancyCase
	return React.createElement(BoundedBannerContext, {
		width = INLINE_WIDTH,
		LayoutOrder = props.LayoutOrder,
	}, {
		BannerContext = React.createElement(BannerContext, {
			presentation = props.presentation,
			text = DEFAULT_TEXT,
			icon = occupancyCase.icon,
			link = if occupancyCase.hasLink then { text = "Link", onActivated = noop } else nil,
			onClose = if occupancyCase.hasClose then noop else nil,
		}),
	})
end

local function WrappingBanner(props: {
	presentation: BannerContextPresentation,
	linkText: string,
})
	return React.createElement(BannerContext, {
		presentation = props.presentation,
		text = LONG_TEXT,
		icon = EXAMPLE_ICON,
		link = { text = props.linkText, onActivated = noop },
		onClose = noop,
	})
end

local function buildWrappingExamples(presentation: BannerContextPresentation): { [string]: React.ReactNode }
	local children: { [string]: React.ReactNode } = {}

	for index, config in WRAPPING_CONFIGS do
		children[`Example-{index}`] = React.createElement(WidthPair, {
			LayoutOrder = index,
			label = config.label,
			renderBanner = function()
				return React.createElement(WrappingBanner, {
					presentation = presentation,
					linkText = config.linkText,
				})
			end,
		})
	end

	return children
end

local function IconBanner(props: {
	presentation: BannerContextPresentation,
	icon: IconConfig,
	LayoutOrder: number,
})
	return React.createElement(BoundedBannerContext, {
		width = ICON_CELL_WIDTH,
		LayoutOrder = props.LayoutOrder,
	}, {
		BannerContext = React.createElement(BannerContext, {
			presentation = props.presentation,
			text = DEFAULT_TEXT,
			icon = props.icon,
		}),
	})
end

local function iconPresentationCells(icon: IconConfig): { React.ReactNode }
	local cells: { React.ReactNode } = {}
	for columnIndex, presentation in PRESENTATION_ORDER do
		cells[columnIndex] = React.createElement(IconBanner, {
			presentation = presentation :: BannerContextPresentation,
			icon = icon,
			LayoutOrder = columnIndex,
		})
	end
	return cells
end

local function ContentStory()
	local occupancyRows: { MatrixGridRow } = {}
	for rowIndex, occupancyCase in OCCUPANCY_CASES do
		local cells: { React.ReactNode } = {}
		for columnIndex, presentation in PRESENTATION_ORDER do
			cells[columnIndex] = React.createElement(OccupancyBanner, {
				presentation = presentation :: BannerContextPresentation,
				occupancyCase = occupancyCase,
				LayoutOrder = columnIndex,
			})
		end
		occupancyRows[rowIndex] = {
			label = matrixLabel(occupancyCase.label),
			cells = cells,
		}
	end

	return React.createElement(View, {
		tag = PAGE_COL_TAG,
	}, {
		Occupancy = React.createElement(MatrixSection, {
			name = "Occupancy",
			note = "The first text line centers against the icon slot, and the banner keeps that height without an icon. Link and close are independent. Affixed sets the slots against its larger type and edge borders.",
			LayoutOrder = 1,
			labelColumnWidth = OCCUPANCY_LABEL_COLUMN_WIDTH,
			columnHeaders = PRESENTATION_HEADERS,
			cellColumnWidth = INLINE_WIDTH,
			rowGap = "xxlarge",
			rows = occupancyRows,
		}),
		IconByType = React.createElement(MatrixSection, {
			name = "Icon by type",
			LayoutOrder = 2,
			labelColumnWidth = ICON_TYPE_LABEL_COLUMN_WIDTH,
			columnHeaders = PRESENTATION_HEADERS,
			cellColumnWidth = ICON_CELL_WIDTH,
			rowGap = "xxlarge",
			rows = StoryIcons.buildIconTypeMatrixRows(function(iconExample)
				return iconPresentationCells(iconExample.name)
			end),
		}),
		IconByVariant = React.createElement(MatrixSection, {
			name = "Icon by variant",
			note = "A string icon is rendered as the Regular variant; the table arm is the only way to pass another.",
			LayoutOrder = 3,
			labelColumnWidth = ICON_TYPE_LABEL_COLUMN_WIDTH,
			columnHeaders = PRESENTATION_HEADERS,
			cellColumnWidth = ICON_CELL_WIDTH,
			rowGap = "xxlarge",
			rows = {
				{
					label = matrixLabel("icon = string"),
					cells = iconPresentationCells(EXAMPLE_ICON),
				},
				{
					label = matrixLabel("icon = { name, variant = Filled }"),
					cells = iconPresentationCells({ name = EXAMPLE_ICON, variant = IconVariant.Filled }),
				},
			},
		}),
		Overflow = React.createElement(Section, {
			name = "Overflow",
			note = "Stacks at the XSmall breakpoint, and above it whenever the link needs more than 30% of the row so the message keeps 70%. Copy only truncates when every ancestor resolves a width without measuring its children.",
			LayoutOrder = 4,
			contentTag = "col gap-xlarge size-full-0 auto-y",
		}, {
			Inline = React.createElement(Section, {
				name = BannerContextPresentation.Inline :: string,
				LayoutOrder = 1,
				contentTag = STACKED_SECTION_TAG,
			}, buildWrappingExamples(BannerContextPresentation.Inline)),
			Affixed = React.createElement(Section, {
				name = BannerContextPresentation.Affixed :: string,
				LayoutOrder = 2,
				contentTag = STACKED_SECTION_TAG,
			}, buildWrappingExamples(BannerContextPresentation.Affixed)),
		}),
	})
end

local function SiblingAlert(props: {
	variant: AlertVariant,
	LayoutOrder: number,
})
	return React.createElement(BoundedBannerContext, {
		width = SIBLING_WIDTH,
		LayoutOrder = props.LayoutOrder,
	}, {
		Alert = React.createElement(Alert, {
			variant = props.variant,
			text = SIBLING_TEXT,
			link = { text = "Link", onActivated = noop },
			onClose = noop,
		}),
	})
end

local function SiblingBannerContext(props: {
	presentation: BannerContextPresentation,
	LayoutOrder: number,
})
	return React.createElement(BoundedBannerContext, {
		width = SIBLING_WIDTH,
		LayoutOrder = props.LayoutOrder,
	}, {
		BannerContext = React.createElement(BannerContext, {
			presentation = props.presentation,
			text = SIBLING_TEXT,
			icon = EXAMPLE_ICON,
			link = { text = "Link", onActivated = noop },
			onClose = noop,
		}),
	})
end

local function InContextStory()
	local siblingRows: { MatrixGridRow } = {}
	for rowIndex, siblingCase in SIBLING_CASES do
		siblingRows[rowIndex] = {
			label = matrixInfoLabel(
				siblingCase.presentation :: string,
				`AlertVariant.{siblingCase.alertVariant :: string}`
			),
			cells = {
				React.createElement(SiblingAlert, {
					variant = siblingCase.alertVariant,
					LayoutOrder = 1,
				}),
				React.createElement(SiblingBannerContext, {
					presentation = siblingCase.presentation,
					LayoutOrder = 2,
				}),
			},
		}
	end

	return React.createElement(View, {
		tag = PAGE_COL_TAG,
	}, {
		Alert = React.createElement(MatrixSection, {
			name = "Alert",
			note = "Figma puts both at a 48px one-line height. Alert renders 8px taller because its padded close forces a 32px content row; once it adopts InternalNotice it picks up the unpadded close and the same 24px row as BannerContext.",
			LayoutOrder = 1,
			labelColumnWidth = SIBLING_LABEL_COLUMN_WIDTH,
			columnHeaders = SIBLING_HEADERS,
			cellColumnWidth = SIBLING_WIDTH,
			rowGap = "xxlarge",
			rowAlign = "top",
			rows = siblingRows,
		}),
	})
end

return {
	summary = "BannerContext surfaces contextual information or promotions inline with a page or affixed to its bounds.",
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
			name = "Controlled component",
			story = ControlledStory,
		},
		{
			name = "Content",
			story = ContentStory,
		},
		{
			name = "In context",
			story = InContextStory,
		},
	},
	controls = {
		variant = VARIANT_ORDER,
		presentation = PRESENTATION_ORDER,
		text = DEFAULT_TEXT,
		icon = PLAYGROUND_ICON_OPTIONS,
		hasLink = true,
		isDismissable = false,
	},
}
