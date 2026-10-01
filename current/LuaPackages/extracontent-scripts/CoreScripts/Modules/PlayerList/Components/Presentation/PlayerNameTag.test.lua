local Players = game:GetService("Players")
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

-- TODO: Re-enable when the suite is upgraded to use Jest3
-- local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals)
-- local expect = JestGlobals.expect

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it

local waitUntil = require(CorePackages.Workspace.Packages.TestUtils).waitUntil

local Components = script.Parent.Parent

local PlayerList = Components.Parent
local CreateLayoutValues = require(PlayerList.CreateLayoutValues)

local TestProviders = require(PlayerList.TestProviders)

local PlayerNameTag = require(script.Parent.PlayerNameTag)

it("should create and destroy without errors", function()
	local container = Instance.new("Folder")
	local element = Roact.createElement(TestProviders, {}, {
		PlayerNameTag = Roact.createElement(PlayerNameTag, {
			player = Players.LocalPlayer :: Player,
			isTitleEntry = false,
			isHovered = false,

			textStyle = {
				Color = Color3.new(1, 1, 1),
				Transparency = 1,
			},
			textFont = {
				Size = 20,
				MinSize = 20,
				Font = Enum.Font.Gotham,
			},
			layoutOrder = 0,
		}),
	})
	local instance = Roact.mount(element, container)

	waitUntil(function()
		Roact.act(function() end)
		-- local nameTag = container:FindFirstChild("PlayerName", true) :: TextLabel
		-- TODO: Re-enable this check when the suite is upgraded to use Jest3
		-- expect(nameTag.Text).toEqual("inExperienceCombinedName12345678")

		return true
	end, 2)

	Roact.unmount(instance)
end)

it("should create and destroy without errors tenfoot", function()
	local layoutValues = CreateLayoutValues(true) :: any
	local container = Instance.new("Folder")

	local element = Roact.createElement(TestProviders, {
		layoutValues = layoutValues,
	}, {
		PlayerNameTag = Roact.createElement(PlayerNameTag, {
			player = Players.LocalPlayer :: Player,
			isTitleEntry = true,
			isHovered = true,

			textStyle = layoutValues.DefaultTextStyle :: any,
			textFont = {
				Size = 32,
				MinSize = 32,
				Font = Enum.Font.Gotham,
			},
			layoutOrder = 0,
		}),
	})
	local instance = Roact.mount(element, container)

	waitUntil(function()
		Roact.act(function() end)
		-- local nameTag = container:FindFirstChild("PlayerName", true) :: TextLabel

		-- TODO: Re-enable this check when the suite is upgraded to use Jest3
		-- expect(nameTag.Text).toEqual("inExperienceCombinedName12345678")

		return true
	end, 2)

	Roact.unmount(instance)
end)
