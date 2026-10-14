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

local CrowdedLeadingCell = HeaderBarStoryHelpers.CrowdedLeadingCell
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
			leading = leadingPlaceholder({ childCount = props.controls.childCount, isSubject = true }),
			content = contentPlaceholder(),
			trailing = trailingPlaceholder(),
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
				leading = leadingPlaceholder({ childCount = 1, isSubject = true }),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder(),
			}),
			TwoChildren = React.createElement(LabeledShell, {
				LayoutOrder = 2,
				label = "Two children",
				leading = leadingPlaceholder({ childCount = 2, isSubject = true }),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder(),
			}),
		}),
		Overflow = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Overflow",
		}, {
			TwoChildren = React.createElement(SlotPattern, {
				LayoutOrder = 1,
				label = "Two children: the slot keeps its width and they run over Content",
				leading = leadingPlaceholder({ childCount = 2, isSubject = true }),
				content = contentPlaceholder(),
				trailing = trailingPlaceholder(),
				Cell = CrowdedLeadingCell,
			}),
		}),
	})
end

return {
	summary = "The slot at the start of a HeaderBar: a row that packs its children against the leading edge and takes its width from what HeaderBar.Content leaves rather than from its own children. Every cell mounts all three slots; the accented one is Leading.",
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
