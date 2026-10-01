---
category: Display
---

## Overview

`Slider` is a draggable bar that can be used for form fields, media timelines, or anything else where you need to slide a bar around.

---

## Usage

Slider is designed such that the consumer controls the current bar fill percentage.

To create a basic form field the main props to supply are `value` and `onValueChanged`. This is enough to allow the user to drag the bar around, and the `value` binding can then be read when submitting the form.

Directional navigation uses two stages. When focus lands on a Slider, every direction can move to a neighboring control and the value does not change. Press A or Enter to capture the Slider and move selection to its active knob. While captured, Left/Right adjust a horizontal Slider and Up/Down adjust a vertical Slider; the cross axis is inert. Press B or Backspace to return selection to the whole control.

Directional input uses `step` when supplied, or 1% of the range otherwise. Held input starts repeating after 400 ms. Continuous Sliders accelerate through faster repeat intervals, while stepped Sliders retain a fixed interval. Slider does not claim L1/R1 for coarse adjustment.

Set `orientation` to `Orientation.Vertical` to fill upward from the bottom of the track. For a vertical Slider, `width` specifies the track length.

```luau
local Foundation = require(Packages.Foundation)
local Slider = Foundation.Slider
local SliderVariant = Foundation.Enums.SliderVariant
local Visibility = Foundation.Enums.Visibility
local InputSize = Foundation.Enums.InputSize

local function FormSlider()
	local value, setValue = React.useBinding(0.5)

	return React.createElement(Slider, {
		value = value,
		onValueChanged = setValue,

		size = InputSize.Medium,
		knobVisibility = Visibility.Always,
		variant = SliderVariant.Emphasis,
	})
end
```

Use `SliderType.Range` with a `NumberRange` binding to select an interval. Capturing a Range Slider activates the thumb nearest the direction focus entered from. While captured, press A or Enter to toggle the active thumb. Thumbs retain their minimum or maximum identity and stop when they meet.

```luau
local Foundation = require(Packages.Foundation)
local Slider = Foundation.Slider
local SliderType = Foundation.Enums.SliderType

local function PriceRange()
	local value, setValue = React.useBinding(NumberRange.new(25, 75))

	return React.createElement(Slider, {
		type = SliderType.Range,
		value = value,
		onValueChanged = setValue,
		range = NumberRange.new(0, 100),
	})
end
```

Directional capture currently follows `GuiService.SelectedObject` for PlayerGui surfaces. CoreGui surfaces that use `SelectedCoreObject` do not yet support this capture model.

A more complex example would be a media timeline that progresses independently and allows the user to scrub along it to skip to where they want in the media's playback.

```luau
local Foundation = require(Packages.Foundation)
local Slider = Foundation.Slider
local SliderVariant = Foundation.Enums.SliderVariant
local Visibility = Foundation.Enums.Visibility
local InputSize = Foundation.Enums.InputSize

local function MediaTimeline()
	local value, setValue = React.useBinding(0.25)
	local isPlaying, setIsPlaying = React.useState(false)
	local wasPlaying = React.useRef(false)

	local onDragStarted = React.useCallback(function()
		if isPlaying then
			wasPlaying.current = true
		end
		setIsPlaying(false)
	end, { isPlaying } :: { unknown })

	local onDragEnded = React.useCallback(function()
		if wasPlaying.current then
			setIsPlaying(true)
		end
		wasPlaying.current = false
	end, {})

	local onTogglePlayback = React.useCallback(function()
		setIsPlaying(function(prev)
			return not prev
		end)
	end, {})

	-- This is illustrative logic to move the timeline playback along. In
	-- practice the source of playback would be coming from audio/video
	React.useEffect(function(): (() -> ())?
		if isPlaying then
			local isRunning = true

			task.spawn(function()
				while isRunning do
					setValue(value:getValue() + 1 / 600)
					task.wait(1 / 16)
				end
			end)

			return function()
				isRunning = false
			end
		end

		return nil
	end, { isPlaying })

	return React.createElement(View, {
		tag = "size-full-0 auto-y col gap-small",
	}, {
		Slider = React.createElement(Slider, {
			value = value,
			size = InputSize.XSmall,
			knobVisibility = Visibility.Auto,
			variant = SliderVariant.Standard,
			onValueChanged = setValue,
			onDragStarted = onDragStarted,
			onDragEnded = onDragEnded,
			LayoutOrder = 1,
		}),

		Playback = React.createElement(Button, {
			text = if isPlaying then "Pause" else "Play",
			onActivated = onTogglePlayback,
			LayoutOrder = 2,
		}),
	})
end
```

For discrete values, you can use the `step` prop to snap the slider to specific increments. This is useful for volume controls, transparency setting, or any setting that should have distinct steps rather than continuous values.

If `step` is `nil` or `0` then it will be a continuous values.

```luau
local Foundation = require(Packages.Foundation)
local Slider = Foundation.Slider
local SliderVariant = Foundation.Enums.SliderVariant
local Visibility = Foundation.Enums.Visibility
local InputSize = Foundation.Enums.InputSize

local function VolumeControl()
	-- Start at volume level 5 (50%)
	local volume, setVolume = React.useBinding(5)

	local onVolumeChanged = React.useCallback(function(newVolume: number)
		setVolume(newVolume)
		print("Volume set to:", newVolume)
		-- Apply volume to audio system here
	end, {})

	return React.createElement(Slider, {
		value = volume,
		onValueChanged = onVolumeChanged,

		-- Volume levels from 0 (mute) to 10 (max)
		range = NumberRange.new(0, 10),
		-- Snap to whole number volume levels
		step = 1,

		size = InputSize.Medium,
		knobVisibility = Visibility.Auto,
		variant = SliderVariant.Standard,
	})
end
```
