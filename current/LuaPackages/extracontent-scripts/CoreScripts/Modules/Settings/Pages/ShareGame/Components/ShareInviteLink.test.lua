local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local InGameMenuDependencies = require(CorePackages.Packages.InGameMenuDependencies)
local Roact = InGameMenuDependencies.Roact
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local Store = require(CorePackages.Packages.Rodux).Store
local UnitTestHelpers = require(CorePackages.Workspace.Packages.UnitTestHelpers)
local ShareGame = RobloxGui.Modules.Settings.Pages.ShareGame
local Constants = require(ShareGame.Constants)
local dependencies = require(CorePackages.Workspace.Packages.NotificationsCommon).ReducerDependencies

local ShareLinksNetworking = dependencies.ShareLinksNetworking

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local afterEach = JestGlobals.afterEach

local ShareInviteLink = require(script.Parent.ShareInviteLink)

afterEach(function()
	ShareLinksNetworking.GenerateLink.Mock.clear()
end)

it("should mount", function()
	local store = Store.new(function()
		return {
			ShareLinks = {
				Invites = {
					shareInviteLink = {
						linkId = "123456",
					},
				},
			},
			NetworkStatus = {},
		}
	end)

	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		ShareInviteLink = UnitTestHelpers.createStyleProvider({
			ShareButton = Roact.createElement(ShareInviteLink, {
				deviceLayout = Constants.DeviceLayout.DESKTOP,
			}),
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)
