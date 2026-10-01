--!nonstrict
--[[
	// Filename: PromptAgeCheckHandler.lua
	// Description: Listens to Players.PromptAgeCheckRequested(player) and
	//              opens the AMP wizard for the local player. On a Granted
	//              response, calls LocalPlayer:NotifyAgeCheckPassed() so the
	//              engine flips Player.AgeChecked.
]]--

local Players = game:GetService("Players")
local CorePackages = game:GetService("CorePackages")
local CoreGui = game:GetService("CoreGui")

local SharedFlags = require(CorePackages.Workspace.Packages.SharedFlags)
local FStringLuaAppPlayButtonAgeCheckAmpFeatureName = SharedFlags.FStringLuaAppPlayButtonAgeCheckAmpFeatureName
local FStringLuaAppPlayButtonAgeCheckAmpNameSpace = SharedFlags.FStringLuaAppPlayButtonAgeCheckAmpNameSpace
local FFlagPioneerLeaveOnInExpFaeDownAge = SharedFlags.FFlagPioneerLeaveOnInExpFaeDownAge

local Logging = require(CorePackages.Workspace.Packages.AppCommonLib).Logging
local maybeLeavePioneerOnFaeDownAge =
	require(CorePackages.Workspace.Packages.PioneerUtils.maybeLeavePioneerOnFaeDownAge)

local PromptAgeCheckHandler = {}

local function onPromptAgeCheckRequested(player)
	local LocalPlayer = Players.LocalPlayer
	if player ~= LocalPlayer then
		return
	end

	local ok, AmpUpsell = pcall(require, CorePackages.Workspace.Packages.AmpUpsell)
	if not ok or not AmpUpsell or not AmpUpsell.InExpAmpWizardController then
		return
	end

	local apolloOk, apolloClient = pcall(require, CoreGui.RobloxGui.Modules.ApolloClient)
	if not apolloOk or not apolloClient then
		return
	end

	AmpUpsell.InExpAmpWizardController.OpenAmpWizardContainerInExp(
		FStringLuaAppPlayButtonAgeCheckAmpFeatureName,
		function(accessResponse, actionsTaken)
			local function notifyIfGranted()
				if accessResponse == "Granted" then
					local notifyOk, err = pcall(function()
						LocalPlayer:NotifyAgeCheckPassed()
					end)
					if not notifyOk then
						Logging.warn("PromptAgeCheckRequested: NotifyAgeCheckPassed failed: " .. tostring(err))
					end
				end
			end

			if FFlagPioneerLeaveOnInExpFaeDownAge then
				local AmpEnums = AmpUpsell.AmpEnums
				local ageEstimationSucceeded = actionsTaken ~= nil
					and actionsTaken[AmpEnums.ActionTypeEnum.AgeEstimation] == AmpEnums.ActionStatusEnum.Success
				maybeLeavePioneerOnFaeDownAge(ageEstimationSucceeded, notifyIfGranted)
			else
				notifyIfGranted()
			end
		end,
		nil, -- recourseData
		"PromptAgeCheckRequested", -- entryPointEventCtx (telemetry)
		nil, -- extraParameters
		FStringLuaAppPlayButtonAgeCheckAmpNameSpace,
		apolloClient
	)
end

function PromptAgeCheckHandler.init()
	Players.PromptAgeCheckRequested:Connect(onPromptAgeCheckRequested)
end

return PromptAgeCheckHandler
