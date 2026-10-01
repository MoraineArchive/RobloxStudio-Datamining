---
category: Layout
---

## Overview

Breadcrumbs are a list of links that help a user visualize a page's location within the hierarchical structure of an experience, and let them navigate up to any of its ancestors.

---

## Usage

A breadcrumb is driven by an ordered `items` list, from the top-most ancestor to the current page. An ancestor with an `onActivated` renders as a [[Link]] that navigates on activation; an ancestor without one renders as plain, non-interactive text. The last entry is the **current page**, rendered as emphasized, non-interactive text. A separator is drawn between each pair of items.

The prop names mirror the web/MUI `Breadcrumbs` API (`separator`, `maxItems`, `itemsBeforeCollapse`, `itemsAfterCollapse`) with the exception of `items`, which are passed as an array rather than as children.

### Size

The `size` property applies to every crumb and separator. Possible values are defined in [[InputSize]] (`Small`/`Medium`/`Large`); `Medium` is the default.

### Leading and trailing accessories

Each item may set a `leading` and/or `trailing` accessory, rendered before and after its text. An accessory is one of:

- a **BuilderIcons name** string (e.g. `IconName.House`) — rendered as an icon;
- an **icon config** `{ iconName, iconVariant }` — to choose an icon variant;
- an **avatar** `{ type = "Avatar", userId }` — rendered as an [[AvatarIcon]];
- a **media image** — any non-icon asset string, rendered as an [[Image]].

The union is extensible: a future accessory kind is a new `type` on the config, so call sites that pass an icon or avatar today keep working.

### Separator

`separator` sets the string drawn between crumbs; it defaults to `/`.

### Collapsing

When the number of items exceeds `maxItems` (default 8), the middle crumbs collapse into an overflow (`…`) button that keeps `itemsBeforeCollapse` leading crumbs and `itemsAfterCollapse` trailing crumbs (both default 1). Activating the button reveals the full trail.

### Examples

```luau
local Foundation = require(Packages.Foundation)
local Breadcrumb = Foundation.Breadcrumb
local InputSize = require(Foundation.Enums.InputSize)
local IconName = Foundation.Enums.IconName

React.createElement(Breadcrumb, {
	size = InputSize.Medium,
	items = {
		{ text = "Home", onActivated = goHome, leading = IconName.House },
		{ text = "Games", onActivated = goToGames },
		{ text = "Tower Defense Simulator" },
	},
})
```

## Accessibility

- Ancestor crumbs are interactive [[Link]]s and participate in selection/focus; the current page and separators are non-interactive text, so they stay out of the focus order.
- Hover transitions honor reduced-motion (handled by [[Link]]), and the crumb, separator, and current-page colors meet WCAG AA contrast.
