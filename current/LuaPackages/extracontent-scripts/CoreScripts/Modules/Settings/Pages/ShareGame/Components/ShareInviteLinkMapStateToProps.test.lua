local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it
local jestExpect = JestGlobals.expect

local mapStateToProps = require(script.Parent.ShareInviteLinkMapStateToProps)

describe("should properly map to props", function()
	local mockState = {
		ShareLinks = {
			Invites = {
				ShareInviteLink = {
					linkId = "123456",
				},
			},
		},
		NetworkStatus = {},
		fetchShareInviteLinkNetworkStatus = "NotStarted",
	}

	it("SHOULD have the expected fields", function()
		local newProps = mapStateToProps(mockState)

		jestExpect(newProps).toEqual({
			shareInviteLink = { linkId = "123456" },
			fetchShareInviteLinkNetworkStatus = "NotStarted",
		})
	end)

	it("SHOULD have the short url if provided", function()
		local mockState = {
			ShareLinks = {
				Invites = {
					ShareInviteLink = {
						linkId = "123456",
						shortUrl = "www.bbc.co.uk",
					},
				},
			},
			NetworkStatus = {},
			fetchShareInviteLinkNetworkStatus = "NotStarted",
		}

		local newProps = mapStateToProps(mockState)

		jestExpect(newProps).toEqual({
			shareInviteLink = { linkId = "123456", shortUrl = "www.bbc.co.uk" },
			fetchShareInviteLinkNetworkStatus = "NotStarted",
		})
	end)
end)
