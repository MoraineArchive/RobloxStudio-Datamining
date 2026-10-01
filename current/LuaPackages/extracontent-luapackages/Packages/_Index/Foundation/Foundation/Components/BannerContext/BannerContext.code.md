---
category: Display
---

## Overview

`BannerContext` are used to surface contextual information.

---

## Usage

```luau
local Foundation = require(Packages.Foundation)
local BannerContext = Foundation.BannerContext
local BannerContextPresentation = Foundation.Enums.BannerContextPresentation
local BannerContextVariant = Foundation.Enums.BannerContextVariant
local IconName = Foundation.Enums.IconName

return React.createElement(BannerContext, {
	variant = BannerContextVariant.Standard,
	presentation = BannerContextPresentation.Inline,
	text = "Banner context",
	icon = IconName.CircleI,
	link = {
		text = "Link",
		onActivated = function()
			print("Link activated")
		end,
	},
	onClose = function()
		print("Banner dismissed")
	end,
})
```
