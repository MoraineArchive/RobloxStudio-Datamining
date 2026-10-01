local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local HeaderBarStoryHelpers = require(Foundation.Components.HeaderBar.HeaderBarStoryHelpers)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local View = require(Foundation.Components.View)

local Section = StorySection.Section
local STORY_PAGE_TAG = StorySection.STORY_PAGE_COL_TAG

type ViewportPreset = HeaderBarStoryHelpers.ViewportPreset

type Controls = {
	hasBackground: boolean,
	hasLeading: boolean,
	hasContent: boolean,
	hasTrailing: boolean,
	viewport: ViewportPreset,
}

local HEIGHT_TIERS = HeaderBarStoryHelpers.HEIGHT_TIERS
local WIDTH_TIERS = HeaderBarStoryHelpers.WIDTH_TIERS

local VIEWPORT_ORDER = HeaderBarStoryHelpers.VIEWPORT_ORDER
local VIEWPORT_BY_PRESET = HeaderBarStoryHelpers.VIEWPORT_BY_PRESET

local CenteredDetailCell = HeaderBarStoryHelpers.CenteredDetailCell
local ContentAndTrailingCell = HeaderBarStoryHelpers.ContentAndTrailingCell
local ContentFillCell = HeaderBarStoryHelpers.ContentFillCell
local ContentFillWithTrailingCell = HeaderBarStoryHelpers.ContentFillWithTrailingCell
local GlobalNavigationCell = HeaderBarStoryHelpers.GlobalNavigationCell
local SearchCell = HeaderBarStoryHelpers.SearchCell

local LabeledShell = HeaderBarStoryHelpers.LabeledShell
local Shell = HeaderBarStoryHelpers.Shell
local SlotPattern = HeaderBarStoryHelpers.SlotPattern
local contentPlaceholder = HeaderBarStoryHelpers.contentPlaceholder
local leadingPlaceholder = HeaderBarStoryHelpers.leadingPlaceholder
local tierCells = HeaderBarStoryHelpers.tierCells
local trailingPlaceholder = HeaderBarStoryHelpers.trailingPlaceholder

local function PlaygroundStory(props: { controls: Controls }): React.ReactNode
	local controls = props.controls
	local viewport = VIEWPORT_BY_PRESET[controls.viewport]

	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Shell = React.createElement(Shell, {
			LayoutOrder = 1,
			width = viewport.width,
			breakpoint = viewport.breakpoint,
			hasBackground = controls.hasBackground,
			leading = if controls.hasLeading then leadingPlaceholder() else nil,
			content = if controls.hasContent then contentPlaceholder() else nil,
			trailing = if controls.hasTrailing then trailingPlaceholder() else nil,
		}),
	})
end

local function SizingStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Width = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Width",
			note = "HeaderBar has no width prop; it fills the parent. These cells are harness widths.",
		}, tierCells(WIDTH_TIERS)),
		Height = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Height",
			note = "Height is not a prop. HeaderBar reads viewport breakpoint and maps it to a size tag.",
		}, tierCells(HEIGHT_TIERS)),
	})
end

local function HasBackgroundStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Default = React.createElement(LabeledShell, {
			LayoutOrder = 1,
			label = "true",
			hasPlaceholderSlots = true,
		}),
		Off = React.createElement(LabeledShell, {
			LayoutOrder = 2,
			label = "false",
			hasBackground = false,
			hasPlaceholderSlots = true,
		}),
	})
end

local function ContentStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Subparts = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Subparts",
		}, {
			Leading = React.createElement(LabeledShell, {
				LayoutOrder = 1,
				label = "Leading",
				leading = leadingPlaceholder(),
			}),
			Content = React.createElement(LabeledShell, {
				LayoutOrder = 2,
				label = "Content",
				content = contentPlaceholder(),
			}),
			Trailing = React.createElement(LabeledShell, {
				LayoutOrder = 3,
				label = "Trailing",
				trailing = trailingPlaceholder(),
			}),
		}),
		FullComposition = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Full composition",
		}, {
			LeadingAndTrailing = React.createElement(SlotPattern, {
				LayoutOrder = 1,
				label = "Leading and Trailing",
				leading = leadingPlaceholder(),
				trailing = trailingPlaceholder(),
				Cell = GlobalNavigationCell,
			}),
			LeadingAndContent = React.createElement(SlotPattern, {
				LayoutOrder = 2,
				label = "Leading and Content",
				leading = leadingPlaceholder(),
				content = contentPlaceholder(),
				Cell = CenteredDetailCell,
			}),
			ContentAndTrailing = React.createElement(SlotPattern, {
				LayoutOrder = 3,
				label = "Content and Trailing",
				content = contentPlaceholder(),
				trailing = trailingPlaceholder(),
				Cell = ContentAndTrailingCell,
			}),
			LeadingContentAndTrailing = React.createElement(SlotPattern, {
				LayoutOrder = 4,
				label = "Leading, Content, and Trailing",
				hasPlaceholderSlots = true,
				Cell = SearchCell,
			}),
		}),
		Overflow = React.createElement(Section, {
			LayoutOrder = 3,
			name = "Overflow",
		}, {
			ContentFillsWithoutTrailing = React.createElement(SlotPattern, {
				LayoutOrder = 1,
				label = "Content asks for the whole row, no Trailing",
				leading = leadingPlaceholder(),
				content = contentPlaceholder({ fill = true, isSubject = true }),
				Cell = ContentFillCell,
			}),
			ContentFillsBesideTrailing = React.createElement(SlotPattern, {
				LayoutOrder = 2,
				label = "Content asks for the whole row beside Trailing",
				leading = leadingPlaceholder(),
				content = contentPlaceholder({ fill = true, isSubject = true }),
				trailing = trailingPlaceholder(),
				Cell = ContentFillWithTrailingCell,
			}),
		}),
	})
end

return {
	summary = "A persistent top-level bar that arranges leading, content, and trailing slots in one responsive row.",
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
			name = "hasBackground",
			story = HasBackgroundStory,
		},
		{
			name = "Content",
			story = ContentStory,
		},
	},
	controls = {
		hasBackground = true,
		hasLeading = true,
		hasContent = true,
		hasTrailing = true,
		viewport = VIEWPORT_ORDER,
	},
}
