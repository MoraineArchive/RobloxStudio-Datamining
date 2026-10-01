local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local renderMoreSettingsBanner = require(script.Parent.renderMoreSettingsBanner)

local function render(isPioneerLaunch)
	local parent = Instance.new("Frame")
	local banner = renderMoreSettingsBanner({
		layoutOrder = 1,
		parent = parent,
		isPioneerLaunch = isPioneerLaunch,
	})
	return banner, parent
end

describe("renderMoreSettingsBanner", function()
	it("SHOULD not mount a wrapper outside a Pioneer launch", function()
		local banner = render(function()
			return false
		end)

		expect(banner).toBeNil()
	end)

	it("SHOULD mount a wrapper on a Pioneer launch", function()
		local banner, parent = render(function()
			return true
		end)
		assert(banner, "expected a banner wrapper on a Pioneer launch")

		expect(banner.Name).toBe("MoreSettingsBannerWrapper")
		expect(banner.Parent).toBe(parent)
	end)
end)
