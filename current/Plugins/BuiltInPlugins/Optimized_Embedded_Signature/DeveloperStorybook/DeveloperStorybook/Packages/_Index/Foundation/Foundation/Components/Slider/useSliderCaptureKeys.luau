local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

local UserInputService = require(Foundation.Utility.Wrappers.Services).UserInputService

local constants = require(script.Parent.constants)

local function isCaptureKey(keyCode: Enum.KeyCode): boolean
	return table.find(constants.enter, keyCode) ~= nil or table.find(constants.thumbSwitch, keyCode) ~= nil
end

local function useSliderCaptureKeys(isListening: boolean, onCapture: () -> ())
	local latestOnCaptureRef = React.useRef(onCapture)
	latestOnCaptureRef.current = onCapture

	React.useEffect(function()
		if not isListening then
			return
		end

		local connection = UserInputService.InputBegan:Connect(function(input: InputObject)
			if isCaptureKey(input.KeyCode) then
				latestOnCaptureRef.current()
			end
		end)
		return function()
			connection:Disconnect()
		end
	end, { isListening })
end

return useSliderCaptureKeys
