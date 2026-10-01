--!nonstrict
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local Assets = require(script.Parent.Assets)

local FFlagFixInGameMenuMoreButtonIcon = game:DefineFastFlag("FixInGameMenuMoreButtonIcon", false)

describe("InGameMenu Assets", function()
	-- Regression: APPEXP-4212. In-experience the UIBlox Button always routes to
	-- Foundation, whose findIcon only resolves a value carrying a BuilderIcons migration
	-- key. The legacy spritesheet slice resolved to nil, so the icon-only MoreButton
	-- rendered with no glyph (a black circle). Behind FFlagFixInGameMenuMoreButtonIcon
	-- MoreActions exposes the migration key; without it, the pre-fix legacy value.
	it("gates MoreActions on the Foundation-migratable icon key", function()
		if FFlagFixInGameMenuMoreButtonIcon then
			expect(Assets.Images.MoreActions.Image).toBe("icons/common/more")
		else
			-- flag off preserves the legacy spritesheet slice (pre-fix behavior)
			expect(Assets.Images.MoreActions.Image).never.toBe("icons/common/more")
			expect(string.match(Assets.Images.MoreActions.Image, "^rbxasset://")).never.toBeNil()
		end
	end)
end)
