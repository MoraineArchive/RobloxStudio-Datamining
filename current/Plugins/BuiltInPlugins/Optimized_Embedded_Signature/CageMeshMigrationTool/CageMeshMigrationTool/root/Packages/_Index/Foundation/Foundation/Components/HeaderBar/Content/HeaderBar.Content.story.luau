local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local HeaderBarStoryHelpers = require(Foundation.Components.HeaderBar.HeaderBarStoryHelpers)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local View = require(Foundation.Components.View)

local Section = StorySection.Section
local STORY_PAGE_TAG = StorySection.STORY_PAGE_COL_TAG

local OVERSIZED_DEMAND = HeaderBarStoryHelpers.OVERSIZED_DEMAND

local LabeledShell = HeaderBarStoryHelpers.LabeledShell
local Shell = HeaderBarStoryHelpers.Shell
local contentPlaceholder = HeaderBarStoryHelpers.contentPlaceholder
local leadingPlaceholder = HeaderBarStoryHelpers.leadingPlaceholder
local trailingPlaceholder = HeaderBarStoryHelpers.trailingPlaceholder

local function PlaygroundStory(): React.ReactNode
	return React.createElement(View, {
		tag = STORY_PAGE_TAG,
	}, {
		Shell = React.createElement(Shell, {
			LayoutOrder = 1,
			leading = leadingPlaceholder(),
			content = contentPlaceholder({ isSubject = true }),
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
			ContentFits = React.createElement(LabeledShell, {
				LayoutOrder = 1,
				label = "Content asks for part of the row",
				leading = leadingPlaceholder({ showDemand = true }),
				content = contentPlaceholder({ isSubject = true, showDemand = true }),
				trailing = trailingPlaceholder({ showDemand = true }),
			}),
		}),
		Overflow = React.createElement(Section, {
			LayoutOrder = 2,
			name = "Overflow",
		}, {
			ContentTakesAll = React.createElement(LabeledShell, {
				LayoutOrder = 1,
				label = "Content asks for more than the row has",
				leading = leadingPlaceholder({ showDemand = true }),
				content = contentPlaceholder({ demand = OVERSIZED_DEMAND, isSubject = true, showDemand = true }),
				trailing = trailingPlaceholder({ showDemand = true }),
			}),
		}),
	})
end

return {
	summary = "The center slot of a HeaderBar: it is served its child's width first and in full, so Leading and Trailing are the slots that give way. Every cell mounts all three slots; the accented one is Content.",
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
}
