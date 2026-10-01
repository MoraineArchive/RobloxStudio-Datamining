local CorePackages = game:GetService("CorePackages")

local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local ShareButton = require(script.Parent.ShareButton)

it("should mount", function()
	local element = UnitTestHelpers.createStyleProvider({
		ShareButton = Roact.createElement(ShareButton),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)
