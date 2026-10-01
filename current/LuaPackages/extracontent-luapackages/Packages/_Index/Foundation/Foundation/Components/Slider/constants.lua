local CAPTURE_KEYS = {
	Enum.KeyCode.Return,
	Enum.KeyCode.KeypadEnter,
	Enum.KeyCode.ButtonA,
}

return {
	enter = CAPTURE_KEYS,
	exit = {
		Enum.KeyCode.Backspace,
		Enum.KeyCode.ButtonB,
	},
	stepIncrement = {
		horizontal = {
			Enum.KeyCode.Right,
			Enum.KeyCode.DPadRight,
		},
		vertical = {
			Enum.KeyCode.Up,
			Enum.KeyCode.DPadUp,
		},
	},
	stepDecrement = {
		horizontal = {
			Enum.KeyCode.Left,
			Enum.KeyCode.DPadLeft,
		},
		vertical = {
			Enum.KeyCode.Down,
			Enum.KeyCode.DPadDown,
		},
	},
	thumbSwitch = CAPTURE_KEYS,
	coarseIncrement = {
		Enum.KeyCode.ButtonR1,
	},
	coarseDecrement = {
		Enum.KeyCode.ButtonL1,
	},
	analogStep = {
		Enum.KeyCode.Thumbstick1,
	},
	-- Pushing the thumbstick this far past center starts stepping or focus
	-- entry; matches the CoreScripts Settings Slider deadzone.
	thumbstickDeadzone = 0.8,
}
