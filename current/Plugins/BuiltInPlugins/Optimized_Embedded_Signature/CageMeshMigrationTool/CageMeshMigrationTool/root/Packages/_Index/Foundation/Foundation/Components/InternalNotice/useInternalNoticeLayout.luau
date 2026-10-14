local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local Breakpoint = require(Foundation.Enums.Breakpoint)
local BreakpointConfig = require(Foundation.Utility.Responsive.BreakpointConfig)
local Types = require(Foundation.Components.Types)
local useAbsoluteSize = require(Foundation.Utility.useAbsoluteSize)

type SizeConstraint = Types.SizeConstraint

-- Stack at XSmall based on notice width, not screen width.
local STACK_BREAKPOINT_WIDTH = BreakpointConfig.widths[Breakpoint.XSmall]
-- Reserve at least this much of the notice for the message. Stack the CTA if it would take more.
local MESSAGE_MIN_WIDTH_RATIO = 0.7

export type InternalNoticeLayout = {
	isStacked: boolean,
	onNoticeAbsoluteSizeChanged: (GuiObject) -> (),
	onStackedColumnAbsoluteSizeChanged: (GuiObject) -> (),
	measureInlineLink: ((GuiObject) -> ())?,
	stackedLinkConstraint: SizeConstraint?,
}

local function useInternalNoticeLayout(onNoticeAbsoluteSizeChanged: ((GuiObject) -> ())?): InternalNoticeLayout
	local noticeSize, handleNoticeAbsoluteSizeChanged = useAbsoluteSize(onNoticeAbsoluteSizeChanged)

	local inlineLinkWidth, setInlineLinkWidth = React.useState(0)
	local onInlineLinkAbsoluteSizeChanged = React.useCallback(function(rbx: GuiObject)
		setInlineLinkWidth(rbx.AbsoluteSize.X)
	end, {})

	local stackedColumnWidth, setStackedColumnWidth = React.useState(0)
	local onStackedColumnAbsoluteSizeChanged = React.useCallback(function(rbx: GuiObject)
		setStackedColumnWidth(rbx.AbsoluteSize.X)
	end, {})

	local isAtStackBreakpoint = noticeSize.X > 0 and noticeSize.X <= STACK_BREAKPOINT_WIDTH
	local maxInlineLinkWidth = noticeSize.X * (1 - MESSAGE_MIN_WIDTH_RATIO)
	local isInlineLinkTooWide = maxInlineLinkWidth > 0 and inlineLinkWidth > maxInlineLinkWidth
	local isStacked = isAtStackBreakpoint or isInlineLinkTooWide

	-- Measure the link only while inline so stacking does not shrink the saved width.
	local measureInlineLink = if not isStacked then onInlineLinkAbsoluteSizeChanged else nil
	-- Limit the stacked link to the column width so wrapped text does not overflow.
	local stackedLinkConstraint = if isStacked and stackedColumnWidth > 0
		then { MaxSize = Vector2.new(stackedColumnWidth, math.huge) }
		else nil

	return {
		isStacked = isStacked,
		onNoticeAbsoluteSizeChanged = handleNoticeAbsoluteSizeChanged,
		onStackedColumnAbsoluteSizeChanged = onStackedColumnAbsoluteSizeChanged,
		measureInlineLink = measureInlineLink,
		stackedLinkConstraint = stackedLinkConstraint,
	}
end

return useInternalNoticeLayout
