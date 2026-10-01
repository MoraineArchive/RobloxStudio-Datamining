--!strict
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local PlayerListPackage = require(CorePackages.Workspace.Packages.PlayerList)
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

local Roact = require(CorePackages.Packages.Roact)
local waitUntil = require(CorePackages.Workspace.Packages.TestUtils).waitUntil

local PlayerListController = require(script.Parent.PlayerListController)
local FFlagPlayerListUseMobileOnSmallDisplay = PlayerListPackage.Flags.FFlagPlayerListUseMobileOnSmallDisplay

it("should render PlayerList", function()
	local _list = PlayerListController.new()
	if FFlagPlayerListUseMobileOnSmallDisplay then
		local PlayerListApp = CoreGui:FindFirstChild("PlayerListApp", true)
		expect(PlayerListApp).toBeDefined()
	else
		local PlayerList = CoreGui:FindFirstChild("PlayerScrollList", true) :: Frame

		expect(PlayerList).toBeDefined()
		expect(PlayerList:IsA("Frame")).toEqual(true)

		waitUntil(function()
			Roact.act(function() end)
			-- Player ID associated with roblox-cli LocalPlayer
			return PlayerList:FindFirstChild("PlayerEntry_12345678", true) ~= nil
		end, 2)
	end
end)
