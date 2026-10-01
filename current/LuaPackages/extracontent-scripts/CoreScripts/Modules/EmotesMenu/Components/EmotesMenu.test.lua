local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local it = JestGlobals.it
local expect = JestGlobals.expect

local Roact = require(CorePackages.Packages.Roact)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local UIBlox = require(CorePackages.Packages.UIBlox)

local Foundation = require(CorePackages.Packages.Foundation)
local ColorMode = Foundation.Enums.ColorMode

local AppStyleProvider = UIBlox.App.Style.AppStyleProvider
local StyleConstants = UIBlox.App.Style.Constants
local Colors = UIBlox.App.Style.Colors

local EmotesModules = script.Parent.Parent
local EmotesMenuReducer = require(EmotesModules.Reducers.EmotesMenuReducer)
local EmotesMenu = require(script.Parent.EmotesMenu)

it("should create and destroy without errors", function()
	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = Rodux.Store.new(EmotesMenuReducer, {}, {
			Rodux.thunkMiddleware,
		}),
	}, {
		Roact.createElement(AppStyleProvider, {
			style = {
				themeName = ColorMode.Dark,
				fontName = StyleConstants.FontName.Gotham,
			},
		}, {
			EmotesMenu = Roact.createElement(EmotesMenu),
		}),
	})

	local instance = Roact.mount(element)
	Roact.unmount(instance)
end)

it("should use appropriate wheel background based on flag", function()
	local preferredTransparency = 0.7
	local element = Roact.createElement(RoactRodux.StoreProvider, {
		store = Rodux.Store.new(EmotesMenuReducer, {}, {
			Rodux.thunkMiddleware,
		}),
	}, {
		Roact.createElement(AppStyleProvider, {
			style = {
				themeName = ColorMode.Dark,
				fontName = StyleConstants.FontName.Gotham,
				settings = {
					preferredTransparency = preferredTransparency,
				},
			},
		}, {
			EmotesMenu = Roact.createElement(EmotesMenu),
		}),
	})

	local folder = Instance.new("Folder")
	local instance = Roact.mount(element, folder)

	local backgroundCircleOverlay = folder:FindFirstChild("BackgroundCircleOverlay", true)
	expect((backgroundCircleOverlay :: Frame).BackgroundTransparency).toBeCloseTo(0.4 * preferredTransparency)
	expect((backgroundCircleOverlay :: Frame).BackgroundColor3).toBe(
		Colors.Flint:Lerp(Color3.new(0, 0, 0), preferredTransparency)
	)

	Roact.unmount(instance)
end)
