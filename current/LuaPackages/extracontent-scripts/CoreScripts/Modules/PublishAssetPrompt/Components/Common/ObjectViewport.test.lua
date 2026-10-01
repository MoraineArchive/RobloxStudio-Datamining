local CorePackages = game:GetService("CorePackages")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local afterEach = JestGlobals.afterEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest

local Roact = require(CorePackages.Packages.Roact)
local Foundation = require(CorePackages.Packages.Foundation)
local ReactTestingLibrary = require(CorePackages.Packages.Dev.ReactTestingLibrary)
local UIBlox = require(CorePackages.Packages.UIBlox)

local FFlagIECPublishValidationLoadingUI = require(script.Parent.Parent.Parent.Flags.FFlagIECPublishValidationLoadingUI)
local REVIEWING_CREATION_KEY = "CoreScripts.PublishCommon.ReviewingCreation"
local REVIEWING_CREATION_FALLBACK = "Reviewing your creation..."
local LOCALIZED_REVIEWING_CREATION_TEXT = "Localized review status"
local translationUnavailable = false
local formatByKey = jest.fn(function(_self, key)
	expect(key).toBe(REVIEWING_CREATION_KEY)
	if translationUnavailable then
		error("Missing test translation")
	end
	return LOCALIZED_REVIEWING_CREATION_TEXT
end)

jest.mock(CorePackages.Workspace.Packages.RobloxTranslator, function()
	return {
		FormatByKey = formatByKey,
	}
end)

local ObjectViewport = require(script.Parent.ObjectViewport)

describe("ObjectViewport", function()
	afterEach(function()
		translationUnavailable = false
		ReactTestingLibrary.cleanup()
	end)

	local function renderLoadingViewport()
		return ReactTestingLibrary.render(Roact.createElement(Foundation.FoundationProvider, {
			colorMode = Foundation.Enums.ColorMode.Dark,
		}, {
			StyleProvider = Roact.createElement(UIBlox.Core.Style.Provider, {}, {
				ObjectViewport = Roact.createElement(ObjectViewport, {
					isLoading = true,
				}),
			}),
		}))
	end

	if FFlagIECPublishValidationLoadingUI then
		it("SHOULD show review progress while the preview is loading", function()
			local result = renderLoadingViewport()

			expect(result.getByTestId("--foundation-progress")).never.toBeNil()
			expect(result.getByTestId("reviewing-creation-status").ClassName).toBe("Frame")
			expect(result.getByText(LOCALIZED_REVIEWING_CREATION_TEXT)).never.toBeNil()
			expect(result.queryByTestId("--foundation-skeleton")).toBeNil()
		end)

		it("SHOULD show the English fallback when localized copy is unavailable", function()
			translationUnavailable = true
			local result = renderLoadingViewport()

			expect(result.getByText(REVIEWING_CREATION_FALLBACK)).never.toBeNil()
		end)
	else
		it("SHOULD show the existing shimmer while the preview is loading", function()
			local result = renderLoadingViewport()

			expect(result.getByTestId("--foundation-skeleton")).never.toBeNil()
			expect(result.queryByTestId("--foundation-progress")).toBeNil()
			expect(result.queryByText(LOCALIZED_REVIEWING_CREATION_TEXT)).toBeNil()
		end)
	end
end)
