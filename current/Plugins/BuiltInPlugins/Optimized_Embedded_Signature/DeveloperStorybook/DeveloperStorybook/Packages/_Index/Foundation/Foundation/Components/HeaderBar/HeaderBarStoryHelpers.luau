local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local BuilderIcons = require(Packages.BuilderIcons)
local React = require(Packages.React)

local Avatar = require(Foundation.Components.Avatar)
local AvatarSize = require(Foundation.Enums.AvatarSize)
local Breakpoint = require(Foundation.Enums.Breakpoint)
local BreakpointConfig = require(Foundation.Utility.Responsive.BreakpointConfig)
local HeaderBar = require(Foundation.Components.HeaderBar)
local IconButton = require(Foundation.Components.IconButton)
local ResponsiveContext = require(Foundation.Providers.Responsive.ResponsiveContext)
local ResponsiveProvider = require(Foundation.Providers.Responsive.ResponsiveProvider)
local SearchInput = require(Foundation.Components.SearchInput)
local StorySection = require(Foundation.Utility.Stories.Shared.StorySection)
local Text = require(Foundation.Components.Text)
local View = require(Foundation.Components.View)
local useResponsive = require(Foundation.Providers.Responsive.useResponsive)

local LabeledCell = StorySection.LabeledCell

local IconName = BuilderIcons.Icon

type Breakpoint = Breakpoint.Breakpoint
type HeaderBarAction = HeaderBar.HeaderBarAction
type ResponsiveConfig = ResponsiveContext.ResponsiveConfig

export type SlotPlaceholderOptions = {
	demand: number?,
	fill: boolean?,
	childCount: number?,
	isSubject: boolean?,
	showDemand: boolean?,
}

export type SlotChildren = {
	leading: React.ReactNode?,
	content: React.ReactNode?,
	trailing: React.ReactNode?,
}

export type ShellProps = {
	LayoutOrder: number?,
	width: number?,
	breakpoint: Breakpoint?,
	hasBackground: boolean?,
	hasPlaceholderSlots: boolean?,
} & SlotChildren

export type LabeledShellProps = ShellProps & {
	label: string?,
}

export type ShellTier = {
	label: string,
	width: number?,
	breakpoint: Breakpoint?,
}

export type CompositionCellProps = {
	LayoutOrder: number,
	width: number,
}

export type CompositionCell = (CompositionCellProps) -> React.ReactNode

export type ViewportPreset =
	"XSmall (360px)"
	| "Small (600px)"
	| "Medium (1140px)"
	| "Large (1520px)"
	| "XLarge (1920px)"
	| "XXLarge (2560px)"

export type Viewport = {
	preset: ViewportPreset,
	breakpoint: Breakpoint,
	width: number,
}

local BREAKPOINT_ORDER: { Breakpoint } = {
	Breakpoint.XSmall,
	Breakpoint.Small,
	Breakpoint.Medium,
	Breakpoint.Large,
	Breakpoint.XLarge,
	Breakpoint.XXLarge,
}

local MOBILE_PARENT_WIDTH = 360
local DESKTOP_PARENT_WIDTH = 720
local MOBILE_BREAKPOINT: Breakpoint = Breakpoint.XSmall

-- BreakpointConfig caps the top tier at math.huge, so the widest preset names its own width.
local XXLARGE_PARENT_WIDTH = 2560

local VIEWPORTS: { Viewport } = {
	{
		preset = "XSmall (360px)",
		breakpoint = Breakpoint.XSmall,
		width = BreakpointConfig.widths[Breakpoint.XSmall],
	},
	{
		preset = "Small (600px)",
		breakpoint = Breakpoint.Small,
		width = BreakpointConfig.widths[Breakpoint.Small],
	},
	{
		preset = "Medium (1140px)",
		breakpoint = Breakpoint.Medium,
		width = BreakpointConfig.widths[Breakpoint.Medium],
	},
	{
		preset = "Large (1520px)",
		breakpoint = Breakpoint.Large,
		width = BreakpointConfig.widths[Breakpoint.Large],
	},
	{
		preset = "XLarge (1920px)",
		breakpoint = Breakpoint.XLarge,
		width = BreakpointConfig.widths[Breakpoint.XLarge],
	},
	{
		preset = "XXLarge (2560px)",
		breakpoint = Breakpoint.XXLarge,
		width = XXLARGE_PARENT_WIDTH,
	},
}

local VIEWPORT_ORDER: { ViewportPreset } = {}
local VIEWPORT_BY_PRESET: { [ViewportPreset]: Viewport } = {}
for index, viewport in VIEWPORTS do
	VIEWPORT_ORDER[index] = viewport.preset
	VIEWPORT_BY_PRESET[viewport.preset] = viewport
end

local WIDTH_TIERS: { ShellTier } = {
	{ label = `Mobile, parent width {MOBILE_PARENT_WIDTH}px`, width = MOBILE_PARENT_WIDTH },
	{ label = `Desktop, parent width {DESKTOP_PARENT_WIDTH}px`, width = DESKTOP_PARENT_WIDTH },
}

local HEIGHT_TIERS: { ShellTier } = {
	{ label = "XSmall, Small", breakpoint = Breakpoint.Small },
	{ label = "Medium, Large", breakpoint = Breakpoint.Large },
	{ label = "XLarge, XXLarge", breakpoint = Breakpoint.XXLarge },
}

local SLOT_CHILD_COUNTS = { 1, 2, 3 }

local LEADING_ACTIONS: { HeaderBarAction } = {
	{
		id = "close",
		icon = IconName.X,
		onActivated = function() end,
	},
	{
		id = "back",
		icon = IconName.ChevronLargeLeft,
		onActivated = function() end,
	},
}

local TRAILING_ACTIONS: { HeaderBarAction } = {
	{
		id = "search",
		icon = IconName.MagnifyingGlass,
		onActivated = function() end,
	},
	{
		id = "robux",
		icon = IconName.Robux,
		onActivated = function() end,
	},
	{
		id = "notifications",
		icon = IconName.Bell,
		onActivated = function() end,
	},
}

local function takeActions(source: { HeaderBarAction }, count: number): { HeaderBarAction }
	return table.move(source, 1, math.min(count, #source), 1, {})
end

local SLOT_BAND_TAG = "fill row align-y-center radius-medium stroke-default"
local SLOT_CHIP_TAG = "row align-x-center align-y-center padding-small radius-medium bg-shift-200"

local SUBJECT_BAND_TAG = "fill row align-y-center radius-medium stroke-system-emphasis"
local SUBJECT_CHIP_TAG = "row align-x-center align-y-center padding-small radius-medium bg-action-emphasis"

local LEADING_DEMAND = 96
local CONTENT_DEMAND = 128
local TRAILING_DEMAND = 96

local OVERSIZED_DEMAND = 400

local function slotChip(label: string, width: number?, layoutOrder: number, isSubject: boolean): React.ReactNode
	local chipTag = if isSubject then SUBJECT_CHIP_TAG else SLOT_CHIP_TAG

	return React.createElement(View, {
		tag = if width then chipTag else `auto-x {chipTag}`,
		Size = if width then UDim2.new(0, width, 1, 0) else UDim2.fromScale(0, 1),
		LayoutOrder = layoutOrder,
	}, {
		Label = React.createElement(Text, {
			Text = label,
			tag = if isSubject
				then "auto-xy text-caption-small content-inverse-emphasis"
				else "auto-xy text-caption-small content-muted",
			LayoutOrder = 1,
		}),
	})
end

local function slotPlaceholders(
	slotName: string,
	defaultDemand: number,
	chipAlignTag: string,
	chipHugsLabel: boolean,
	options: SlotPlaceholderOptions?
): { [string]: React.ReactNode }
	local config: SlotPlaceholderOptions = options or {}
	local childCount = config.childCount or 1
	local isSubject = config.isSubject == true

	if childCount == 1 then
		local demand = config.demand or defaultDemand
		local isFill = config.fill == true
		local bandTag = if isSubject then SUBJECT_BAND_TAG else SLOT_BAND_TAG
		local label = if isFill
			then `{slotName} 100%`
			elseif config.showDemand then `{slotName} {demand}px`
			else slotName
		return {
			Band = React.createElement(View, {
				tag = `{bandTag} {chipAlignTag}`,
				Size = if isFill then UDim2.fromScale(1, 1) else UDim2.new(0, demand, 1, 0),
				LayoutOrder = 1,
			}, {
				Chip = slotChip(label, if isFill or chipHugsLabel then nil else demand, 1, isSubject),
			}),
		}
	end

	local children: { [string]: React.ReactNode } = {}
	for index = 1, childCount do
		children[`Child{index}`] = slotChip(`Child {index}`, nil, index, isSubject)
	end
	return children
end

local function leadingSlot(children: { [string]: React.ReactNode }): React.ReactNode
	return React.createElement(HeaderBar.Leading, nil, children)
end

local function contentSlot(children: { [string]: React.ReactNode }): React.ReactNode
	return React.createElement(HeaderBar.Content, nil, children)
end

local function trailingSlot(children: { [string]: React.ReactNode }): React.ReactNode
	return React.createElement(HeaderBar.Trailing, nil, children)
end

local function leadingPlaceholder(options: SlotPlaceholderOptions?): React.ReactNode
	return leadingSlot(slotPlaceholders("Leading", LEADING_DEMAND, "align-x-left", true, options))
end

local function contentPlaceholder(options: SlotPlaceholderOptions?): React.ReactNode
	return contentSlot(slotPlaceholders("Content", CONTENT_DEMAND, "align-x-center", false, options))
end

local function trailingPlaceholder(options: SlotPlaceholderOptions?): React.ReactNode
	return trailingSlot(slotPlaceholders("Trailing", TRAILING_DEMAND, "align-x-right", true, options))
end

local function ForcedBreakpoint(props: {
	breakpoint: Breakpoint,
	children: React.ReactNode,
})
	local config = useResponsive().config

	local forcedConfig = React.useMemo(function(): ResponsiveConfig
		local widths: { [Breakpoint]: number } = {}
		local reachedTarget = false
		for _, breakpoint: Breakpoint in BREAKPOINT_ORDER do
			if breakpoint == props.breakpoint then
				reachedTarget = true
			end
			widths[breakpoint] = if reachedTarget then math.huge else -1
		end

		return {
			breakpoint = {
				order = BREAKPOINT_ORDER,
				shortNames = config.breakpoint.shortNames,
				widths = widths,
			},
			grid = config.grid,
		}
	end, { config, props.breakpoint } :: { unknown })

	return React.createElement(ResponsiveProvider, {
		config = forcedConfig,
	}, props.children)
end

local function Shell(props: ShellProps): React.ReactNode
	local width = props.width or MOBILE_PARENT_WIDTH

	local frame = React.createElement(View, {
		tag = "col auto-y stroke-default bg-surface-100",
		Size = UDim2.fromOffset(width, 0),
		LayoutOrder = props.LayoutOrder,
	}, {
		HeaderBar = React.createElement(HeaderBar.Root, {
			hasBackground = props.hasBackground,
			LayoutOrder = 1,
		}, {
			Leading = if props.hasPlaceholderSlots then leadingPlaceholder() else props.leading,
			Content = if props.hasPlaceholderSlots then contentPlaceholder() else props.content,
			Trailing = if props.hasPlaceholderSlots then trailingPlaceholder() else props.trailing,
		}),
	})

	return React.createElement(ForcedBreakpoint, {
		breakpoint = props.breakpoint or MOBILE_BREAKPOINT,
	}, frame)
end

local function LabeledShell(props: LabeledShellProps): React.ReactNode
	local shell = React.createElement(Shell, {
		LayoutOrder = if props.label then 1 else props.LayoutOrder,
		width = props.width,
		breakpoint = props.breakpoint,
		hasBackground = props.hasBackground,
		hasPlaceholderSlots = props.hasPlaceholderSlots,
		leading = props.leading,
		content = props.content,
		trailing = props.trailing,
	})

	if not props.label then
		return shell
	end

	return React.createElement(LabeledCell, {
		LayoutOrder = props.LayoutOrder or 1,
		label = props.label,
	}, {
		Shell = shell,
	})
end

local function tierCells(tiers: { ShellTier }): { [string]: React.ReactNode }
	local cells: { [string]: React.ReactNode } = {}
	for index, tier in tiers do
		cells[tier.label] = React.createElement(LabeledShell, {
			LayoutOrder = index,
			label = tier.label,
			width = tier.width,
			breakpoint = tier.breakpoint,
			hasPlaceholderSlots = true,
		})
	end
	return cells
end

local COMPOSITION_WIDTHS: { number } = { MOBILE_PARENT_WIDTH, DESKTOP_PARENT_WIDTH }

local ACCOUNT_USER_ID = 24813339
local PAGE_TITLE = "Page Title"
local DETAIL_TITLE = "Title"
local DETAIL_SUBTITLE = "Username: 13+"

local COMPACT_SEARCH_WIDTH = UDim.new(0, 176)
local WIDE_SEARCH_WIDTH = UDim.new(0, 320)
local FILL_SEARCH_WIDTH = UDim.new(1, 0)

local function noop() end

local function isCompact(width: number): boolean
	return width <= MOBILE_PARENT_WIDTH
end

local function searchWidth(compact: boolean): UDim
	return if compact then COMPACT_SEARCH_WIDTH else WIDE_SEARCH_WIDTH
end

local function pageTitle(layoutOrder: number): React.ReactNode
	return React.createElement(Text, {
		Text = PAGE_TITLE,
		tag = "auto-xy text-heading-medium content-emphasis",
		LayoutOrder = layoutOrder,
	})
end

local function iconButton(icon: string, layoutOrder: number): React.ReactNode
	return React.createElement(IconButton, {
		icon = icon,
		onActivated = noop,
		LayoutOrder = layoutOrder,
	})
end

local function accountAvatar(layoutOrder: number): React.ReactNode
	return React.createElement(Avatar, {
		userId = ACCOUNT_USER_ID,
		size = AvatarSize.Small,
		LayoutOrder = layoutOrder,
	})
end

local function SearchContent(props: { width: UDim }): React.ReactNode
	local text, setText = React.useBinding("")

	return contentSlot({
		Search = React.createElement(SearchInput, {
			text = text,
			onChanged = setText,
			width = props.width,
			LayoutOrder = 1,
		}),
	})
end

local function searchContent(width: UDim): React.ReactNode
	return React.createElement(SearchContent, { width = width })
end

local function utilityTrailing(hasAccount: boolean): React.ReactNode
	if not hasAccount then
		return trailingSlot({
			Actions = React.createElement(HeaderBar.Actions, {
				actions = TRAILING_ACTIONS,
			}),
		})
	end

	local children: { [string]: React.ReactNode } = {}
	for index, action in TRAILING_ACTIONS do
		children[tostring(action.id)] = iconButton(action.icon :: string, index)
	end
	children.Account = accountAvatar(#TRAILING_ACTIONS + 1)

	return trailingSlot(children)
end

local function searchTrailing(compact: boolean): React.ReactNode
	if compact then
		return trailingSlot({
			Filter = iconButton(IconName.ThreeSlidersHorizontal, 1),
		})
	end

	return utilityTrailing(true)
end

local function CompositionShell(props: {
	LayoutOrder: number,
	width: number,
} & SlotChildren): React.ReactNode
	return React.createElement(LabeledShell, {
		LayoutOrder = props.LayoutOrder,
		label = `{props.width}px`,
		width = props.width,
		breakpoint = if isCompact(props.width) then Breakpoint.XSmall else Breakpoint.Small,
		leading = props.leading,
		content = props.content,
		trailing = props.trailing,
	})
end

local function GlobalNavigationCell(props: CompositionCellProps): React.ReactNode
	local compact = isCompact(props.width)

	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Menu = if compact then iconButton(IconName.ThreeBarsHorizontal, 1) else nil,
			Title = pageTitle(2),
		}),
		trailing = utilityTrailing(not compact),
	})
end

local function SearchCell(props: CompositionCellProps): React.ReactNode
	local compact = isCompact(props.width)

	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Back = if compact then iconButton(IconName.ChevronLargeLeft, 1) else nil,
			Title = if compact then nil else pageTitle(2),
		}),
		content = searchContent(searchWidth(compact)),
		trailing = searchTrailing(compact),
	})
end

local function ContentAndTrailingCell(props: CompositionCellProps): React.ReactNode
	local compact = isCompact(props.width)

	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		content = searchContent(searchWidth(compact)),
		trailing = searchTrailing(compact),
	})
end

local function ContentFillCell(props: CompositionCellProps): React.ReactNode
	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Title = pageTitle(1),
		}),
		content = searchContent(FILL_SEARCH_WIDTH),
	})
end

local function ContentFillWithTrailingCell(props: CompositionCellProps): React.ReactNode
	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Title = pageTitle(1),
		}),
		content = searchContent(FILL_SEARCH_WIDTH),
		trailing = trailingSlot({
			Filter = iconButton(IconName.ThreeSlidersHorizontal, 1),
		}),
	})
end

local function CrowdedLeadingCell(props: CompositionCellProps): React.ReactNode
	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Menu = iconButton(IconName.ThreeBarsHorizontal, 1),
			Back = iconButton(IconName.ChevronLargeLeft, 2),
		}),
		content = searchContent(searchWidth(isCompact(props.width))),
		trailing = trailingSlot({
			Account = accountAvatar(1),
		}),
	})
end

local function CrowdedTrailingCell(props: CompositionCellProps): React.ReactNode
	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Menu = iconButton(IconName.ThreeBarsHorizontal, 1),
		}),
		content = searchContent(searchWidth(isCompact(props.width))),
		trailing = trailingSlot({
			Currency = iconButton(IconName.Robux, 1),
			Notifications = iconButton(IconName.Bell, 2),
			Account = accountAvatar(3),
		}),
	})
end

local function CenteredDetailCell(props: CompositionCellProps): React.ReactNode
	return React.createElement(CompositionShell, {
		LayoutOrder = props.LayoutOrder,
		width = props.width,
		leading = leadingSlot({
			Close = iconButton(IconName.X, 1),
			Back = iconButton(IconName.ChevronLargeLeft, 2),
		}),
		content = contentSlot({
			Stack = React.createElement(View, {
				tag = "col align-x-center auto-xy",
				LayoutOrder = 1,
			}, {
				Title = React.createElement(Text, {
					Text = DETAIL_TITLE,
					tag = "auto-xy text-label-medium content-emphasis",
					LayoutOrder = 1,
				}),
				Subtitle = React.createElement(Text, {
					Text = DETAIL_SUBTITLE,
					tag = "auto-xy text-caption-small content-muted",
					LayoutOrder = 2,
				}),
			}),
		}),
	})
end

local function CompositionGroup(props: {
	LayoutOrder: number,
	Cell: CompositionCell,
}): React.ReactNode
	local cells: { [string]: React.ReactNode } = {}
	for index, width in COMPOSITION_WIDTHS do
		cells[`Width{width}`] = React.createElement(props.Cell, {
			LayoutOrder = index,
			width = width,
		})
	end

	return React.createElement(View, {
		tag = "col align-x-left gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, cells)
end

local function SlotPattern(props: {
	LayoutOrder: number,
	label: string,
	hasPlaceholderSlots: boolean?,
	Cell: CompositionCell?,
} & SlotChildren): React.ReactNode
	return React.createElement(View, {
		tag = "col align-x-left gap-medium auto-xy",
		LayoutOrder = props.LayoutOrder,
	}, {
		Placeholder = React.createElement(LabeledShell, {
			LayoutOrder = 1,
			label = props.label,
			hasPlaceholderSlots = props.hasPlaceholderSlots,
			leading = props.leading,
			content = props.content,
			trailing = props.trailing,
		}),
		Composition = if props.Cell
			then React.createElement(CompositionGroup, {
				LayoutOrder = 2,
				Cell = props.Cell,
			})
			else nil,
	})
end

return {
	MOBILE_PARENT_WIDTH = MOBILE_PARENT_WIDTH,
	WIDTH_TIERS = WIDTH_TIERS,
	HEIGHT_TIERS = HEIGHT_TIERS,
	VIEWPORT_ORDER = VIEWPORT_ORDER,
	VIEWPORT_BY_PRESET = VIEWPORT_BY_PRESET,
	SLOT_CHILD_COUNTS = SLOT_CHILD_COUNTS,
	OVERSIZED_DEMAND = OVERSIZED_DEMAND,
	LEADING_ACTIONS = LEADING_ACTIONS,
	TRAILING_ACTIONS = TRAILING_ACTIONS,
	takeActions = takeActions,
	leadingPlaceholder = leadingPlaceholder,
	contentPlaceholder = contentPlaceholder,
	trailingPlaceholder = trailingPlaceholder,
	LabeledShell = LabeledShell,
	Shell = Shell,
	SlotPattern = SlotPattern,
	tierCells = tierCells,
	CenteredDetailCell = CenteredDetailCell,
	ContentAndTrailingCell = ContentAndTrailingCell,
	ContentFillCell = ContentFillCell,
	ContentFillWithTrailingCell = ContentFillWithTrailingCell,
	CrowdedLeadingCell = CrowdedLeadingCell,
	CrowdedTrailingCell = CrowdedTrailingCell,
	GlobalNavigationCell = GlobalNavigationCell,
	SearchCell = SearchCell,
}
