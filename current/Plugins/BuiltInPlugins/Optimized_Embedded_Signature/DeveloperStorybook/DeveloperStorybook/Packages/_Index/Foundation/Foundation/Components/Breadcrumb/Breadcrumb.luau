local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local BuilderIcons = require(Packages.BuilderIcons)
local React = require(Packages.React)

local IconName = BuilderIcons.Icon

local ButtonVariant = require(Foundation.Enums.ButtonVariant)

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local LinkVariant = require(Foundation.Enums.LinkVariant)

local IconButton = require(Foundation.Components.IconButton)
local Link = require(Foundation.Components.Link)
local Text = require(Foundation.Components.Text)
local Types = require(Foundation.Components.Types)
local View = require(Foundation.Components.View)

local devAssert = require(Foundation.Utility.devAssert)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)

local BreadcrumbAccessory = require(script.Parent.BreadcrumbAccessory)
type BreadcrumbAccessory = BreadcrumbAccessory.BreadcrumbAccessory

local useBreadcrumbVariants = require(script.Parent.useBreadcrumbVariants)
type BreadcrumbVariantProps = useBreadcrumbVariants.BreadcrumbVariantProps
local useTokens = require(Foundation.Providers.Style.useTokens)

export type BreadcrumbItem = {
	text: string,
	onActivated: (() -> ())?,
	leading: (string | BreadcrumbAccessory)?,
	trailing: (string | BreadcrumbAccessory)?,
	testId: string?,
}

export type BreadcrumbProps = {
	items: { BreadcrumbItem },
	size: InputSize?,
	separator: string?,
	maxItems: number?,
	itemsBeforeCollapse: number?,
	itemsAfterCollapse: number?,
} & Types.CommonProps

type Entry = { item: BreadcrumbItem?, index: number?, overflow: boolean? }

local defaultProps = {
	size = InputSize.Medium,
	separator = "/",
	maxItems = 8,
	itemsBeforeCollapse = 1,
	itemsAfterCollapse = 1,
	testId = "--foundation-breadcrumb",
}

type BreadcrumbItemProps = {
	item: BreadcrumbItem,
	isCurrent: boolean,
	size: InputSize,
	variantProps: BreadcrumbVariantProps,
	LayoutOrder: number,
	testId: string,
}

local function BreadcrumbItem(props: BreadcrumbItemProps)
	local item = props.item
	local variantProps = props.variantProps
	local testId = props.testId

	local text: React.ReactNode
	if props.isCurrent or item.onActivated == nil then
		text = React.createElement(Text, {
			Text = item.text,
			tag = if props.isCurrent then variantProps.current.tag else variantProps.label.tag,
			textStyle = if props.isCurrent then variantProps.current.style else variantProps.label.style,
			LayoutOrder = 1,
			testId = `{testId}--text`,
		})
	else
		text = React.createElement(Link, {
			text = item.text,
			onActivated = item.onActivated,
			variant = LinkVariant.Standard,
			size = props.size,
			hasUnderline = false,
			LayoutOrder = 1,
			testId = `{testId}--link`,
		})
	end

	return React.createElement(View, {
		tag = variantProps.item.tag,
		LayoutOrder = props.LayoutOrder,
		testId = testId,
	}, {
		Leading = if item.leading ~= nil
			then React.createElement(BreadcrumbAccessory, {
				config = item.leading,
				variant = variantProps.accessory,
				LayoutOrder = 1,
				testId = `{testId}--leading`,
			})
			else nil,
		ItemText = React.createElement(View, {
			tag = variantProps.itemText.tag,
			LayoutOrder = 2,
		}, {
			Text = text,
			Trailing = if item.trailing ~= nil
				then React.createElement(BreadcrumbAccessory, {
					config = item.trailing,
					variant = variantProps.accessory,
					LayoutOrder = 2,
					testId = `{testId}--trailing`,
				})
				else nil,
		}),
	})
end

local function Breadcrumb(breadcrumbProps: BreadcrumbProps, ref: React.Ref<GuiObject>?)
	local props = withDefaults(breadcrumbProps, defaultProps)
	local tokens = useTokens()
	local variantProps = useBreadcrumbVariants(tokens, props.size)

	devAssert(#props.items > 0, "Breadcrumb: `items` must contain at least one item.")

	local count = #props.items
	local expanded, setExpanded = React.useState(false)
	local onExpand = React.useCallback(function()
		setExpanded(true)
	end, {})

	-- Re-collapse when the trail changes. Keyed on item count (stable across renders)
	-- rather than the `items` table, which is often re-created every render.
	local prevCount = React.useRef(count)
	if prevCount.current ~= count then
		prevCount.current = count
		setExpanded(false)
	end

	local entries = React.useMemo(
		function(): { Entry }
			local before, after = props.itemsBeforeCollapse, props.itemsAfterCollapse
			local result: { Entry } = {}
			if not expanded and count > props.maxItems and before + after < count then
				for index = 1, before do
					table.insert(result, { item = props.items[index], index = index })
				end
				table.insert(result, { overflow = true })
				for index = count - after + 1, count do
					table.insert(result, { item = props.items[index], index = index })
				end
			else
				for index, item in props.items do
					table.insert(result, { item = item, index = index })
				end
			end
			return result
		end,
		{ props.items, props.maxItems, props.itemsBeforeCollapse, props.itemsAfterCollapse, expanded, count } :: { unknown }
	)

	local children = React.useMemo(function(): { [string]: React.ReactNode }
		local result: { [string]: React.ReactNode } = {}
		for i, entry in entries do
			if entry.overflow then
				result.Overflow = React.createElement(IconButton, {
					icon = IconName.ThreeDotsHorizontal,
					onActivated = onExpand,
					size = variantProps.overflow.size,
					variant = ButtonVariant.Standard,
					LayoutOrder = 2 * i - 1,
					testId = `{props.testId}--overflow`,
				})
			else
				local item = entry.item :: BreadcrumbItem
				local index = entry.index :: number
				result[`Item{index}`] = React.createElement(BreadcrumbItem, {
					item = item,
					isCurrent = index == count,
					size = props.size,
					variantProps = variantProps,
					LayoutOrder = 2 * i - 1,
					testId = item.testId or `{props.testId}--item-{index}`,
				})
			end

			if i ~= #entries then
				local sepKey = if entry.overflow then "overflow" else entry.index
				result[`Separator{sepKey}`] = React.createElement(View, {
					tag = variantProps.separator.tag,
					LayoutOrder = 2 * i,
					testId = `{props.testId}--separator-{sepKey}`,
				}, {
					Slash = React.createElement(Text, {
						Text = props.separator,
						tag = variantProps.separator.textTag,
						textStyle = variantProps.separator.style,
						LayoutOrder = 1,
						testId = `{props.testId}--separator-{sepKey}--text`,
					}),
				})
			end
		end
		return result
	end, { entries, variantProps, props.size, props.separator, props.testId, onExpand, count } :: { unknown })

	return React.createElement(
		View,
		withCommonProps(props, {
			tag = variantProps.container.tag,
			ref = ref,
		}),
		children
	)
end

return React.memo(React.forwardRef(Breadcrumb))
