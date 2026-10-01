local Foundation = script:FindFirstAncestor("Foundation")

local UserInputService = require(Foundation.Utility.Wrappers.Services).UserInputService

local constants = require(script.Parent.constants)

local function getActiveGamepad(): Enum.UserInputType?
	local lastInputType = UserInputService:GetLastInputType()
	if
		lastInputType.Name:match("^Gamepad")
		and table.find(UserInputService:GetConnectedGamepads(), lastInputType) ~= nil
	then
		return lastInputType
	end
	return nil
end

local function isHeld(keyboardKey: Enum.KeyCode, gamepadButton: Enum.KeyCode): boolean
	if UserInputService:IsKeyDown(keyboardKey) then
		return true
	end

	local activeGamepad = getActiveGamepad()
	return activeGamepad ~= nil and UserInputService:IsGamepadButtonDown(activeGamepad, gamepadButton)
end

local function getThumbstickDirection(isVertical: boolean): number
	local activeGamepad = getActiveGamepad()
	if not activeGamepad then
		return 0
	end

	for _, input in UserInputService:GetGamepadState(activeGamepad) do
		if input.KeyCode == Enum.KeyCode.Thumbstick1 then
			local x = input.Position.X
			local y = input.Position.Y
			local isForward = if isVertical
				then y >= constants.thumbstickDeadzone or x >= constants.thumbstickDeadzone
				else x >= constants.thumbstickDeadzone or y <= -constants.thumbstickDeadzone
			local isBackward = if isVertical
				then y <= -constants.thumbstickDeadzone or x <= -constants.thumbstickDeadzone
				else x <= -constants.thumbstickDeadzone or y >= constants.thumbstickDeadzone

			if isForward then
				return 1
			elseif isBackward then
				return -1
			end
			return 0
		end
	end

	return 0
end

local function getSelectionEntryDirection(isVertical: boolean): number
	local isForward = if isVertical
		then isHeld(Enum.KeyCode.Up, Enum.KeyCode.DPadUp) or isHeld(Enum.KeyCode.Right, Enum.KeyCode.DPadRight)
		else isHeld(Enum.KeyCode.Right, Enum.KeyCode.DPadRight) or isHeld(Enum.KeyCode.Down, Enum.KeyCode.DPadDown)
	local isBackward = if isVertical
		then isHeld(Enum.KeyCode.Down, Enum.KeyCode.DPadDown) or isHeld(Enum.KeyCode.Left, Enum.KeyCode.DPadLeft)
		else isHeld(Enum.KeyCode.Left, Enum.KeyCode.DPadLeft) or isHeld(Enum.KeyCode.Up, Enum.KeyCode.DPadUp)

	if isForward then
		return 1
	elseif isBackward then
		return -1
	end
	return getThumbstickDirection(isVertical)
end

return getSelectionEntryDirection
