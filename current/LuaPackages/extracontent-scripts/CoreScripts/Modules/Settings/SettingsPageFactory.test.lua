--!nonstrict
local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect
local afterEach = JestGlobals.afterEach

local waitForEvents = require(CorePackages.Workspace.Packages.TestUtils).DeferredLuaHelpers.waitForEvents

local SettingsPageFactory = require(script.Parent.SettingsPageFactory)

local function createPage()
	local page = SettingsPageFactory:CreateNewPage()
	-- Displayed handler calls SelectARow when HubRef.Shield.Visible;
	-- use Shield.Visible = false to avoid focus side effects.
	page:SetHub({ Shield = { Visible = false } })
	return page
end

local function createPageParent()
	local parent = Instance.new("Frame")
	parent.Name = "PageViewInnerFrame"
	return parent
end

describe("SettingsPageFactory", function()
	local pageParents: { Frame } = {}

	afterEach(function()
		for _, pageParent in pageParents do
			pageParent:Destroy()
		end
		table.clear(pageParents)
	end)

	it("SHOULD expose Displaying, Displayed, and Hidden events on CreateNewPage", function()
		local page = createPage()

		expect(typeof(page.Displaying)).toBe("Instance")
		expect(page.Displaying:IsA("BindableEvent")).toBe(true)
		expect(typeof(page.Displayed)).toBe("Instance")
		expect(page.Displayed:IsA("BindableEvent")).toBe(true)
		expect(typeof(page.Hidden)).toBe("Instance")
		expect(page.Hidden:IsA("BindableEvent")).toBe(true)
	end)

	it("SHOULD fire Displaying before Displayed when Display uses skipAnimation", function()
		local page = createPage()
		local pageParent = createPageParent()
		table.insert(pageParents, pageParent)

		local events: { string } = {}
		page.Displaying.Event:Connect(function()
			table.insert(events, "Displaying")
		end)
		page.Displayed.Event:Connect(function()
			table.insert(events, "Displayed")
		end)

		page:Display(pageParent, true)
		waitForEvents()

		expect(events).toEqual({ "Displaying", "Displayed" })
	end)

	it("SHOULD parent and show the page before Displaying fires", function()
		local page = createPage()
		local pageParent = createPageParent()
		table.insert(pageParents, pageParent)

		local parentAtDisplaying: Instance? = nil
		local visibleAtDisplaying: boolean? = nil
		page.Displaying.Event:Connect(function()
			parentAtDisplaying = page.Page.Parent
			visibleAtDisplaying = page.Page.Visible
		end)

		page:Display(pageParent, true)
		waitForEvents()

		expect(parentAtDisplaying).toBe(pageParent)
		expect(visibleAtDisplaying).toBe(true)
	end)

	it("SHOULD mark the page displayed after Display with skipAnimation", function()
		local page = createPage()
		local pageParent = createPageParent()
		table.insert(pageParents, pageParent)

		page:Display(pageParent, true)

		expect(page:GetDisplayed()).toBe(true)
	end)

	it("SHOULD fire Hidden and clear displayed state after Hide with skipAnimation", function()
		local page = createPage()
		local pageParent = createPageParent()
		table.insert(pageParents, pageParent)

		page:Display(pageParent, true)
		waitForEvents()

		local hiddenFired = false
		page.Hidden.Event:Connect(function()
			hiddenFired = true
		end)

		page:Hide(-1, page.TabPosition, true, nil, pageParent)
		waitForEvents()

		expect(hiddenFired).toBe(true)
		expect(page:GetDisplayed()).toBe(false)
		expect(page.Page.Visible).toBe(false)
	end)
end)
