--!nonstrict
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local describe = JestGlobals.describe
local it = JestGlobals.it

local BlockingModalScreen = require(script.Parent.BlockingModalScreen)
local simpleMountFrame = require(CorePackages.Workspace.Packages.UnitTestHelpers).simpleMountFrame
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider

local noOpt = function() end
describe("lifecycle", function()
	it("SHOULD mount and render without issue", function()
		local _, cleanup = simpleMountFrame(Roact.createElement(LocalizationProvider, {
			localization = Localization.new("en-us"),
		}, {
			BlockingModalScreen = Roact.createElement(BlockingModalScreen, {
				player = {
					UserId = 1,
					Name = "Foo",
					DisplayName = "Bar",
				},
				translator = {
					FormatByKey = function(_, key)
						return key
					end,
				},
				closeModal = noOpt,
			}),
		}))

		cleanup()
	end)
end)
