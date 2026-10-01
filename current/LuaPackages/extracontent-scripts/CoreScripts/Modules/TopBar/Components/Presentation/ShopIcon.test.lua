local CorePackages = game:GetService("CorePackages")

local React = require(CorePackages.Packages.React)
local ReactRoblox = require(CorePackages.Packages.ReactRoblox)
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local ShopIcon = require(script.Parent.ShopIcon)

local ROOT_NAME = "ShopIconUnderTest"

local function renderShopIcon(props: any): boolean
	local container = Instance.new("Frame")
	container.Size = UDim2.fromOffset(800, 600)
	local root = ReactRoblox.createRoot(container)

	ReactRoblox.act(function()
		root:render(React.createElement("Folder", {}, {
			ShopIconUnderTest = React.createElement(ShopIcon, props),
		}))
	end)

	local rendered = container:FindFirstChild(ROOT_NAME, true) ~= nil

	ReactRoblox.act(function()
		root:unmount()
	end)
	container:Destroy()
	return rendered
end

-- Test the expected state when backend data is not supplied (ie not mocked)
describe("ShopIcon", function()
	it("SHOULD render nothing WHEN the shop global icon is not enabled", function()
		expect(renderShopIcon({ buttonSize = 32, layoutOrder = 1 })).toBe(false)
	end)

	it("SHOULD render nothing AND not error WHEN an onAreaChanged handler is supplied", function()
		expect(renderShopIcon({
			buttonSize = 32,
			layoutOrder = 3,
			onAreaChanged = function() end,
		})).toBe(false)
	end)
end)
