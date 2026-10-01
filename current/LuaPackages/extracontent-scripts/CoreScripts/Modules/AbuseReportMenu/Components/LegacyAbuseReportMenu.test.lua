local root = script:FindFirstAncestor("AbuseReportMenu")
local CoreGui = game:GetService("CoreGui")

local CorePackages = game:GetService("CorePackages")

local Roact = require(CorePackages.Packages.Roact)
local React = require(CorePackages.Packages.React)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it

local LegacyAbuseReportMenu = require(root.Components.LegacyAbuseReportMenu)

local displayReportTab = function() end

local defaultProps = {
	hideReportTab = function() end,
	showReportTab = function() end,
	showReportSentPage = function() end,
	registerOnReportTabHidden = function() end,
	registerOnReportTabDisplayed = function(callWhenDisplayed)
		displayReportTab = callWhenDisplayed
	end,
	registerOnSettingsHidden = function() end,
	registerSetNextPlayerToReport = function() end,
	registerOnMenuWidthChange = function() end,
	onReportComplete = function() end,
}

describe("LegacyAbuseReportMenu", function()
	it("registers the report tab displayed callback", function()
		local onReportTabDisplayed: (() -> ())? = nil
		local props = table.clone(defaultProps)
		props.registerOnReportTabDisplayed = function(callback)
			onReportTabDisplayed = callback
		end
		local element = React.createElement(LegacyAbuseReportMenu, props)
		local instance = Roact.mount(element, CoreGui, "LegacyAbuseReportMenu")

		expect(onReportTabDisplayed).never.toBeNil()
		Roact.unmount(instance)
	end)

	it("renders ReportTypeSelector when the report tab is displayed", function()
		local element = React.createElement(LegacyAbuseReportMenu, defaultProps)
		local instance = Roact.mount(element, CoreGui, "LegacyAbuseReportMenu")

		Roact.act(function()
			displayReportTab()
		end)

		local MenuRoot = CoreGui:FindFirstChild("LegacyAbuseReportMenuRoot", true)
		expect(MenuRoot).never.toBeNil()

		--[[
		Look under MenuRoot since if looking under CoreGui, it'll find the module rather than the actual component
		Compare:
		Component path: CoreGui.LegacyAbuseReportMenuRoot.FocusNavigationCoreScriptsWrapper.AbuseReportMenuPlaceholderFrame.MenuLayoutFrame.Menu.ReportTypeSelector
		Module path: CoreGui.RobloxGui.Modules.AbuseReportMenu.Components.ReportTypeSelector
		]]

		local ReportTypeSelector = (MenuRoot :: any):FindFirstChild("ReportTypeSelector", true)
		expect(ReportTypeSelector).never.toBeNil()

		Roact.unmount(instance)
	end)
end)
