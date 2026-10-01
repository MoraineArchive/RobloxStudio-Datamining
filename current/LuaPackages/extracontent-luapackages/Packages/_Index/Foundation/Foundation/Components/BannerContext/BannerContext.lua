local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local BannerContextPresentation = require(Foundation.Enums.BannerContextPresentation)
local BannerContextVariant = require(Foundation.Enums.BannerContextVariant)
local InternalNotice = require(Foundation.Components.InternalNotice)
local Types = require(Foundation.Components.Types)
local useTokens = require(Foundation.Providers.Style.useTokens)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)

local useBannerContextVariants = require(script.Parent.useBannerContextVariants)

type BannerContextPresentation = BannerContextPresentation.BannerContextPresentation
type BannerContextVariant = BannerContextVariant.BannerContextVariant
type IconConfig = Types.IconConfig
type InternalNoticeLink = InternalNotice.InternalNoticeLink

export type BannerContextProps = {
	-- Bordered (Standard) or filled (Emphasis)
	variant: BannerContextVariant?,
	-- In-flow (Inline) or full-bleed with edge borders for sticky positioning (Affixed)
	presentation: BannerContextPresentation?,
	-- Message shown in the banner
	text: string,
	-- Optional leading icon: a Builder icon name, or `{ name, variant }`
	icon: IconConfig?,
	-- Optional trailing text link
	link: InternalNoticeLink?,
	-- Close affordance. Dismissal is consumer-owned.
	onClose: (() -> ())?,
} & Types.CommonProps

local defaultProps = {
	variant = BannerContextVariant.Standard,
	presentation = BannerContextPresentation.Inline,
	testId = "--foundation-banner-context",
}

local function BannerContext(bannerContextProps: BannerContextProps, ref: React.Ref<Instance>)
	local props = withDefaults(bannerContextProps, defaultProps)
	local tokens = useTokens()
	local variantProps = useBannerContextVariants(tokens, props.presentation, props.variant)

	return React.createElement(
		InternalNotice,
		withCommonProps(props, {
			text = props.text,
			icon = props.icon,
			link = props.link,
			onClose = props.onClose,
			truncation = true,
			variantProps = variantProps,
			ref = ref,
		})
	)
end

return React.memo(React.forwardRef(BannerContext))
