local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local HeaderBarStoryHelpers = require(Foundation.Components.HeaderBar.HeaderBarStoryHelpers)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local View = require(Foundation.Components.View)

local Section = StorySection.Section
local STORY_PAGE_TAG = StorySection.STORY_PAGE_COL_TAG

type Controls = {
	childCount: number,
}

local CrowdedTrailingCell = HeaderBarStoryHelpers.CrowdedTrailingCell
local LabeledShell = HeaderBarStoryHelpers.LabeledShell
local Shell = HeaderBarStoryHelpers.Shell
local SlotPattern = HeaderBarStoryHelpers.SlotPattern
local contentPlaceholder = HeaderBarStoryHelpers.contentPlaceholder
local leadingPlaceholder = HeaderBarStoryHelpers.leadingPlaceholder
local trailingPlaceholder = HeaderBarStoryHelpers.trailingPlaceholder

local SLOT_CHILD_COUNTS = HeaderBarStoryHelpers.SLOT_CHILD_COUNTS

local function PlaygroundStory(props: { controls: Controls }): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Shell = React.createElement(Shell, {
			LayoutOrder = 1,
			leading = leadingPlaceholder(),
			content = contentPlaceholder(),
			trailing = trailingPlaceholder({ childCount = props.controls.childCount, isSubject = true }),
		}),
	})
end

local function ContentStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Children = React.createElement(Section, {
			LayoutOrder = 1,
			name = "Children",
		}, {
			OneChild = React.createElement(LabeledShell, {
				LayoutOrder = 1,
				label = "One child",
				leading = leadingPlaceholder(),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder({ childCount = 1, isSubject = true }),
			}),
			TwoChildren = React.createElement(LabeledShell, {
				LayoutOrder = 2,
				label = "Two children",
				leading = leadingPlaceholder(),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder({ childCount = 2, isSubject = true }),
			}),
		}),
		Overflow = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Overflow",
		}, {
			ThreeChildren = React.createElement(SlotPattern, {
				LayoutOrder = 1,
				label = "Three children: the slot keeps its width and they run over Content",
				leading = leadingPlaceholder(),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder({ childCount = 3, isSubject = true }),
				Cell = CrowdedTrailingCell,
			}),
		}),
	})
end

return {
	summary = "The slot at the end of a HeaderBar: a row that packs its children against the trailing edge and takes its width from what HeaderBar.Content leaves rather than from its own children. Every cell mounts all three slots; the accented one is Trailing.",
	stories = {
		{
			name = "Playground",
			story = PlaygroundStory :: unknown,
		},
		{
			name = "Content",
			story = ContentStory,
		},
	},
	controls = {
		childCount = SLOT_CHILD_COUNTS,
	},
}
