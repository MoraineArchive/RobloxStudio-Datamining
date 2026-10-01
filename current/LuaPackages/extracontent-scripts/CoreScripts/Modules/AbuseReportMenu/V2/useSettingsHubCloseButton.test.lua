local CoreGui = game:GetService("CoreGui")
local CorePackages = game:GetService("CorePackages")
local GuiService = game:GetService("GuiService")

local React = require(CorePackages.Packages.React)
local Roact = require(CorePackages.Packages.Roact)
local waitForEvents = require(CorePackages.Workspace.Packages.TestUtils).DeferredLuaHelpers.waitForEvents

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it

local useSettingsHubCloseButton = require(script.Parent.useSettingsHubCloseButton)

local captured: { closeButton: GuiObject?, isSelected: boolean } = {
	closeButton = nil,
	isSelected = false,
}

type HarnessProps = {
	getSettingsHubRef: (() -> any)?,
	isReportTabVisible: boolean,
}

local function TestHarness(props: HarnessProps)
	local closeButton, isSelected = useSettingsHubCloseButton(props.getSettingsHubRef, props.isReportTabVisible)
	captured = { closeButton = closeButton, isSelected = isSelected }
	return React.createElement("Frame", { Name = "Harness" })
end

local mountedInstance: any = nil
local screenGui: ScreenGui = nil :: any
local closeButton: ImageButton = nil :: any

local function mount(name: string, props: HarnessProps)
	Roact.act(function()
		mountedInstance = Roact.mount(React.createElement(TestHarness, props), CoreGui, name)
	end)
end

local function select(guiObject: GuiObject?)
	Roact.act(function()
		GuiService.SelectedCoreObject = guiObject
		waitForEvents()
	end)
end

-- GuiService only selects objects that actually render, so the stand-in buttons live in a
-- ScreenGui rather than directly under CoreGui.
local function createSelectableButton(name: string): ImageButton
	local button = Instance.new("ImageButton")
	button.Name = name
	button.Selectable = true
	button.Size = UDim2.fromOffset(40, 40)
	button.Parent = screenGui
	return button
end

describe("useSettingsHubCloseButton", function()
	beforeEach(function()
		captured = { closeButton = nil, isSelected = false }
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "UseSettingsHubCloseButtonTestGui"
		screenGui.Parent = CoreGui
		closeButton = createSelectableButton("PageTitleCloseButton")
	end)

	afterEach(function()
		GuiService.SelectedCoreObject = nil
		if mountedInstance then
			Roact.unmount(mountedInstance)
			mountedInstance = nil
		end
		screenGui:Destroy()
	end)

	it("resolves the close button off the hub", function()
		mount("UseSettingsHubCloseButtonResolveTest", {
			getSettingsHubRef = function()
				return { PageTitleCloseButton = closeButton }
			end,
			isReportTabVisible = true,
		})

		expect(captured.closeButton).toBe(closeButton)
		expect(captured.isSelected).toBe(false)
	end)

	it("reports no button when the hub has not built its header", function()
		mount("UseSettingsHubCloseButtonMissingTest", {
			getSettingsHubRef = function()
				return {}
			end,
			isReportTabVisible = true,
		})

		expect(captured.closeButton).toBeNil()
		expect(captured.isSelected).toBe(false)
	end)

	it("reports no button when the hub is unreachable", function()
		mount("UseSettingsHubCloseButtonNoHubTest", {
			getSettingsHubRef = nil,
			isReportTabVisible = true,
		})

		expect(captured.closeButton).toBeNil()
		expect(captured.isSelected).toBe(false)
	end)

	it("tracks the close button gaining and losing selection", function()
		mount("UseSettingsHubCloseButtonSelectionTest", {
			getSettingsHubRef = function()
				return { PageTitleCloseButton = closeButton }
			end,
			isReportTabVisible = true,
		})

		select(closeButton)
		expect(captured.isSelected).toBe(true)

		select(nil)
		expect(captured.isSelected).toBe(false)
	end)

	it("ignores selection elsewhere in the menu", function()
		local otherButton = createSelectableButton("SomeOtherButton")

		mount("UseSettingsHubCloseButtonOtherSelectionTest", {
			getSettingsHubRef = function()
				return { PageTitleCloseButton = closeButton }
			end,
			isReportTabVisible = true,
		})

		select(otherButton)
		expect(captured.isSelected).toBe(false)

		otherButton:Destroy()
	end)
end)
