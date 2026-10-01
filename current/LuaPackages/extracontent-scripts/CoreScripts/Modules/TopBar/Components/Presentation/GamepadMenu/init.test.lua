--!strict
-- APPEXP-2274: Remove with FFlagEnableConsoleExpControls
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")
local AppStorageService = game:GetService("AppStorageService")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals3)
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local expect = JestGlobals.expect
local React = require(CorePackages.Packages.React)
local ReactRoblox = require(CorePackages.Packages.ReactRoblox)
local Rodux = require(CorePackages.Packages.Rodux)
local RoactRodux = require(CorePackages.Packages.RoactRodux)
local LocalizationProvider = require(CorePackages.Workspace.Packages.Localization).LocalizationProvider
local Localization = require(CorePackages.Workspace.Packages.InExperienceLocales).Localization
local UIBlox = require(CorePackages.Packages.UIBlox)
local DesignTokenProvider = require(CorePackages.Workspace.Packages.Style).DesignTokenProvider

local MenuNavigationPromptTokenMapper =
	require(script.Parent.Parent.Parent.Parent.TokenMappers.MenuNavigationPromptTokenMapper)
local GamepadMenu = require(script.Parent.Parent.GamepadMenu)

local RobloxAppEnums = require(CorePackages.Workspace.Packages.RobloxAppEnums)
local Reducer = require(script.Parent.Parent.Parent.Parent.Reducer)
local Components = script.Parent.Parent.Parent
local Actions = Components.Parent.Actions
local SetGamepadMenuOpen = require(Actions.SetGamepadMenuOpen)
local SetScreenSize = require(Actions.SetScreenSize)
local UpdateCoreGuiEnabled = require(Actions.UpdateCoreGuiEnabled)
local TenFootInterface = require(RobloxGui.Modules.TenFootInterface)

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local getFFlagExpChatAlwaysRunTCS = SharedFlags.getFFlagExpChatAlwaysRunTCS

local CoreGuiCommon = require(CorePackages.Workspace.Packages.CoreGuiCommon)
local FFlagTopBarSignalizeScreenSize = CoreGuiCommon.Flags.FFlagTopBarSignalizeScreenSize

local FFlagTopBarDeprecateCoreGuiRodux = require(Components.Parent.Flags.FFlagTopBarDeprecateCoreGuiRodux)
local FFlagTopBarDeprecateChatRodux = require(Components.Parent.Flags.FFlagTopBarDeprecateChatRodux)

if FFlagTopBarDeprecateCoreGuiRodux or FFlagTopBarDeprecateChatRodux then
	it = it.skip :: typeof(JestGlobals.it)
end

local defaultStyle = {
	themeName = "dark",
	fontName = "gotham",
	deviceType = RobloxAppEnums.DeviceType.Console,
}

local store

--[[
	App is currently used within all tests for verifying the existence of UI elements
]]
--
local localization = Localization.new("en-us")
local function App(props: { chatVersion: Enum.ChatVersion? })
	return React.createElement(RoactRodux.StoreProvider, {
		store = store,
	}, {
		StyleProvider = React.createElement(UIBlox.App.Style.AppStyleProvider, {
			style = defaultStyle,
		}, {
			DesignTokenProvider = React.createElement(DesignTokenProvider, {
				tokenMappers = {
					MenuNavigationPrompt = MenuNavigationPromptTokenMapper,
				},
			}, {
				LocalizationProvider = React.createElement(LocalizationProvider, {
					localization = localization,
				}, {
					MenuNavigationDismissablePrompt = React.createElement(
						GamepadMenu,
						{ chatVersion = props.chatVersion }
					),
				}),
			}),
		}),
	})
end

--[[
	Because of the hard dependency on TenFootInterface we mock the implementation
	of IsEnabled by rewriting the moduleApi table and reverting it after the test.
	The version of jest used by this test runner currently doesn't seem to support
	module mocking.

	This could potentially cause issues when tests are run in parallel.
]]
--
local prevIsEnabledImpl = nil :: any
local function injectTenFootInterfaceIsEnabledResult(result)
	if prevIsEnabledImpl then
		return
	end -- in-case of accidental double-call
	prevIsEnabledImpl = TenFootInterface["IsEnabled"]
	TenFootInterface["IsEnabled"] = function()
		return result
	end
end

--[[ Swap method back to original implementation ]]
--
local function resetTenFootInterfaceIsEnabled()
	TenFootInterface["IsEnabled"] = prevIsEnabledImpl
	prevIsEnabledImpl = nil
end

beforeEach(function()
	store = Rodux.Store.new(Reducer, {}, {
		Rodux.thunkMiddleware,
	})

	store:dispatch(SetGamepadMenuOpen(true))
	if not FFlagTopBarSignalizeScreenSize then
		store:dispatch(SetScreenSize(Vector2.new(1920, 1080)))
	end
	store:dispatch(UpdateCoreGuiEnabled(Enum.CoreGuiType.Chat, true))
end)

it("should not render the Chat button if chat is disabled", function()
	AppStorageService:SetItem("GamepadMenuVirtualCursorPromptShown", "true")
	store:dispatch(UpdateCoreGuiEnabled(Enum.CoreGuiType.Chat, false))

	local container = Instance.new("ScreenGui")

	local root = ReactRoblox.createRoot(container)

	ReactRoblox.act(function()
		root:render(React.createElement(App))
	end)

	local Chat = container:FindFirstChild("Chat", true)
	expect(Chat).toBeNil()

	ReactRoblox.act(function()
		root:render(nil)
	end)
end)

it(
	"should not render the Chat button on 10ft interfaces when legacy chat is being used, unless place is migrated",
	function()
		injectTenFootInterfaceIsEnabledResult(true)

		AppStorageService:SetItem("GamepadMenuVirtualCursorPromptShown", "true")

		local container = Instance.new("ScreenGui")

		local root = ReactRoblox.createRoot(container)

		ReactRoblox.act(function()
			root:render(React.createElement(App, { chatVersion = Enum.ChatVersion.LegacyChatService }))
		end)

		local Chat = container:FindFirstChild("Chat", true)

		if getFFlagExpChatAlwaysRunTCS() then
			expect(Chat).toBeDefined()
		else
			expect(Chat).toBeNil()
		end

		ReactRoblox.act(function()
			root:render(nil)
		end)

		resetTenFootInterfaceIsEnabled()
	end
)

it("should render the Chat button on 10ft interfaces when flag is enabled", function()
	injectTenFootInterfaceIsEnabledResult(true)

	AppStorageService:SetItem("GamepadMenuVirtualCursorPromptShown", "true")

	local container = Instance.new("ScreenGui")

	local root = ReactRoblox.createRoot(container)

	ReactRoblox.act(function()
		root:render(React.createElement(App, { chatVersion = Enum.ChatVersion.TextChatService }))
	end)

	local Chat = container:FindFirstChild("Chat", true)
	expect(Chat).toBeDefined()

	ReactRoblox.act(function()
		root:render(nil)
	end)

	resetTenFootInterfaceIsEnabled()
end)
