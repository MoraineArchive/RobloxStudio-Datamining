local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local AccessResponseEnum = require(CorePackages.Workspace.Packages.AccountUpgrade).Eligibility.AccessResponseEnum

local shouldShowMoreSettingsBanner = require(script.Parent.shouldShowMoreSettingsBanner)

type Availability = shouldShowMoreSettingsBanner.Availability

local function pioneerLaunch()
	return true
end

local function nonPioneerLaunch()
	return false
end

local function availability(access: string)
	return function(): Availability
		return { granted = access == AccessResponseEnum.Granted, access = access }
	end
end

local inconclusiveResponses: { string } = {
	AccessResponseEnum.Actionable,
	AccessResponseEnum.Pending,
	AccessResponseEnum.Error,
	"Disabled",
	"Malformed",
	"Misconfigured",
}

describe("shouldShowMoreSettingsBanner", function()
	it("SHOULD show the banner for a full account, which AMP denies the upgrade upsell", function()
		expect(shouldShowMoreSettingsBanner(pioneerLaunch, availability(AccessResponseEnum.Denied))).toBe(true)
	end)

	it("SHOULD NOT show the banner for an Express account, which AMP grants the upgrade upsell", function()
		expect(shouldShowMoreSettingsBanner(pioneerLaunch, availability(AccessResponseEnum.Granted))).toBe(false)
	end)

	it("SHOULD NOT show the banner outside a Pioneer launch", function()
		expect(shouldShowMoreSettingsBanner(nonPioneerLaunch, availability(AccessResponseEnum.Denied))).toBe(false)
	end)

	it("SHOULD NOT evaluate availability outside a Pioneer launch", function()
		local callCount = 0
		shouldShowMoreSettingsBanner(nonPioneerLaunch, function(): Availability
			callCount += 1
			return { granted = false, access = AccessResponseEnum.Denied }
		end)

		expect(callCount).toBe(0)
	end)

	it("SHOULD reuse a Denied answer WHEN the menu is opened again", function()
		local callCount = 0
		local getAvailability = function(): Availability
			callCount += 1
			return { granted = false, access = AccessResponseEnum.Denied }
		end

		expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(true)
		expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(true)

		expect(callCount).toBe(1)
	end)

	it("SHOULD ask again after Granted so an in-session upgrade can show the banner", function()
		local callCount = 0
		local getAvailability = function(): Availability
			callCount += 1
			return {
				granted = callCount == 1,
				access = if callCount == 1 then AccessResponseEnum.Granted else AccessResponseEnum.Denied,
			}
		end

		expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(false)
		expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(true)
		expect(callCount).toBe(2)
	end)

	it("SHOULD ask again on the next open WHEN the lookup was inconclusive", function()
		for _, access in inconclusiveResponses do
			local callCount = 0
			local getAvailability = function(): Availability
				callCount += 1
				return { granted = false, access = if callCount == 1 then access else AccessResponseEnum.Denied }
			end

			expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(false)
			expect(shouldShowMoreSettingsBanner(pioneerLaunch, getAvailability)).toBe(true)

			expect(callCount).toBe(2)
		end
	end)

	it("SHOULD fail closed for every inconclusive AMP response", function()
		for _, access in inconclusiveResponses do
			expect(shouldShowMoreSettingsBanner(pioneerLaunch, availability(access))).toBe(false)
		end
	end)
end)
