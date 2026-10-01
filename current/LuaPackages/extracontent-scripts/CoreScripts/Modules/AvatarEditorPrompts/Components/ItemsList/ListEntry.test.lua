local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local expect = JestGlobals.expect

local Roact = require(CorePackages.Packages.Roact)
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

describe("ListEntry", function()
	it("should create and destroy without errors", function()
		local ListEntry = require(script.Parent.ListEntry)

		local element = UnitTestHelpers.createStyleProvider({
			ListEntry = Roact.createElement(ListEntry, {
				text = "Hello World!",
				hasBullet = true,
				layoutOrder = 1,
			}),
		})

		local instance = Roact.mount(element)
		Roact.unmount(instance)
	end)

	it("should accept and assign refs", function()
		local ListEntry = require(script.Parent.ListEntry)
		local ref = Roact.createRef()

		local element = UnitTestHelpers.createStyleProvider({
			ListEntry = Roact.createElement(ListEntry, {
				text = "Hello World!",
				hasBullet = true,
				layoutOrder = 1,
				[Roact.Ref] = ref,
			}),
		})

		local instance = Roact.mount(element)

		expect(ref.current).never.toBeNil()
		expect(ref.current:IsA("Instance")).toBe(true)

		Roact.unmount(instance)
	end)
end)
