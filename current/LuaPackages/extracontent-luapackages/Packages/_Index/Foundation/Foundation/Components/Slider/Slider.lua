local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)
local ReactUtils = require(Packages.ReactUtils)

local Constants = require(Foundation.Constants)

local GuiService = require(Foundation.Utility.Wrappers.Services).GuiService
local InputMode = require(Foundation.Utility.Input.InputMode)
local Types = require(Foundation.Components.Types)
local View = require(Foundation.Components.View)
local useBindable = require(Foundation.Utility.useBindable)
local useLastInputMode = require(Foundation.Utility.Input.useLastInputMode)
local usePointerPosition = require(Foundation.Utility.usePointerPosition)
local withCommonProps = require(Foundation.Utility.withCommonProps)
local withDefaults = require(Foundation.Utility.withDefaults)

local calculateNextStepValue = require(script.Parent.calculateNextStepValue)
local calculatePixelsPerStep = require(script.Parent.calculatePixelsPerStep)
local calculateSliderFraction = require(script.Parent.calculateSliderFraction)
local calculateSliderPositionDelta = require(script.Parent.calculateSliderPositionDelta)
local calculateSliderStepValue = require(script.Parent.calculateSliderStepValue)
local calculateSliderValueFromPosition = require(script.Parent.calculateSliderValueFromPosition)
local getGuiInputPosition = require(script.Parent.getGuiInputPosition)
local getSelectionEntryDirection = require(script.Parent.getSelectionEntryDirection)
local useSliderCaptureKeys = require(script.Parent.useSliderCaptureKeys)
local useSliderDirectionalInput = require(script.Parent.useSliderDirectionalInput)

local InputSize = require(Foundation.Enums.InputSize)
type InputSize = InputSize.InputSize

local Visibility = require(Foundation.Enums.Visibility)
type Visibility = Visibility.Visibility

local Orientation = require(Foundation.Enums.Orientation)
type Orientation = Orientation.Orientation

local SliderVariant = require(Foundation.Enums.SliderVariant)
type SliderVariant = SliderVariant.SliderVariant

local SliderType = require(Foundation.Enums.SliderType)

local SliderThumb = require(script.Parent.SliderThumb)

local ColorNamespace = require(Foundation.Enums.ColorNamespace)
local ControlState = require(Foundation.Enums.ControlState)
local CursorType = require(Foundation.Enums.CursorType)
local StateLayerAffordance = require(Foundation.Enums.StateLayerAffordance)
type ControlState = ControlState.ControlState

local CursorComponent = require(Foundation.Providers.Cursor.CursorComponent)
local Flags = require(Foundation.Utility.Flags)
local Knob = require(Foundation.Components.Knob)
local PresentationContext = require(Foundation.Providers.Style.PresentationContext)
local blendTransparencies = require(Foundation.Utility.blendTransparencies)
local getKnobSize = require(Foundation.Components.Knob.getKnobSize)
local usePresentationContext = PresentationContext.usePresentationContext
local useSliderMotionStates = require(Foundation.Components.Slider.useSliderMotionStates)
local useSliderVariants = require(Foundation.Components.Slider.useSliderVariants)
local useTokens = require(Foundation.Providers.Style.useTokens)

-- When observing the drag deltas this was a reasonably large value that would
-- only realistically be reached from the directional input jumping back to the
-- center.
--
-- The actual deltas were much smaller on average, but there are properties on
-- UIDragDetector to adjust the speed it moves for directional input, so this
-- may not work forever.
local MAX_DIRECTIONAL_INPUT_DRAG_DELTA = 0.01

type Bindable<T> = Types.Bindable<T>

type CommonSliderProps = {
	range: NumberRange?,

	size: InputSize?,
	width: UDim?,
	orientation: Orientation?,
	variant: SliderVariant?,
	isDisabled: boolean?,
	isContained: boolean?,
	knobVisibility: Visibility?,
	knob: React.ReactElement?,
	step: number?,

	onDragStarted: (() -> ())?,
	onDragEnded: (() -> ())?,
} & Types.CommonProps

export type SingleSliderProps = {
	type: typeof(SliderType.Single)?,
	value: Bindable<number>,
	onValueChanged: ((newValue: number) -> ())?,
} & CommonSliderProps

export type RangeSliderProps = {
	type: typeof(SliderType.Range),
	value: Bindable<NumberRange>,
	onValueChanged: ((newValue: NumberRange) -> ())?,
} & CommonSliderProps

export type SliderProps = SingleSliderProps | RangeSliderProps

local defaultProps = {
	range = NumberRange.new(0, 1),
	size = InputSize.Medium,
	width = UDim.new(1, 0),
	orientation = if Flags.FoundationSliderBeta then Orientation.Horizontal else nil :: never,
	variant = SliderVariant.Standard,
	isDisabled = false,
	isContained = false,
	knobVisibility = Visibility.Auto,
	testId = "--foundation-slider",
}

local IS_INVERSE = { colorNamespace = ColorNamespace.Inverse }

local DIRECTIONAL_SELECTION_GROUP: Types.SelectionGroup = {
	SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
	SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
	SelectionBehaviorUp = Enum.SelectionBehavior.Escape,
	SelectionBehaviorDown = Enum.SelectionBehavior.Escape,
}

local CAPTURED_SELECTION_GROUP: Types.SelectionGroup = {
	SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
	SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
	SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
	SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
}

local FOCUSED_SELECTION_GROUP: Types.SelectionGroup = {
	SelectionBehaviorLeft = Enum.SelectionBehavior.Escape,
	SelectionBehaviorRight = Enum.SelectionBehavior.Escape,
	SelectionBehaviorUp = Enum.SelectionBehavior.Escape,
	SelectionBehaviorDown = Enum.SelectionBehavior.Escape,
}

-- The capture cursor is its own selection group so that directional input while
-- captured cannot navigate off the knob onto another selectable inside the
-- slider (the focus target). The root group's Stop only blocks leaving the
-- group, not moving within it, so the knob traps every direction itself.
local CAPTURE_CURSOR_SELECTION_GROUP: Types.SelectionGroup = {
	SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
	SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
	SelectionBehaviorUp = Enum.SelectionBehavior.Stop,
	SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
}

-- selene: allow(high_cyclomatic_complexity) -- try removing when cleaning up either FFlagFoundationSliderOffloadDraggingMath or FFlagFoundationSliderAsSeenOnTV
local function Slider(sliderProps: SliderProps, forwardRef: React.Ref<GuiObject>?)
	local props = withDefaults(sliderProps, defaultProps)
	local isVertical = if Flags.FoundationSliderBeta
		then props.orientation :: Orientation == Orientation.Vertical
		else nil :: never
	local isRange = if Flags.FoundationSliderBeta then sliderProps.type == SliderType.Range else nil :: never
	local singleValue = if sliderProps.type == SliderType.Range then 0 else sliderProps.value
	local onSingleValueChanged = if sliderProps.type == SliderType.Range then nil else sliderProps.onValueChanged
	local onRangeValueChanged = if Flags.FoundationSliderBeta
		then if sliderProps.type == SliderType.Range then sliderProps.onValueChanged else nil
		else nil :: never
	local tokens = useTokens()
	local controlState, setControlState = React.useState(ControlState.Initialize :: ControlState)
	local isDragging, setIsDragging = React.useState(false)
	local isKnobVisible, setIsKnobVisible = React.useState(false)
	local isCaptured, setIsCaptured
	if Flags.FoundationSliderCapture then
		isCaptured, setIsCaptured = React.useState(false)
	end
	local isMaxThumbActive, setIsMaxThumbActive
	if Flags.FoundationSliderCapture then
		isMaxThumbActive, setIsMaxThumbActive = React.useState(false)
	end
	local focusTargetRef = if Flags.FoundationSliderCapture then React.useRef(nil :: GuiObject?) else nil :: never
	local captureTargetRef = if Flags.FoundationSliderCapture then React.useRef(nil :: GuiObject?) else nil :: never
	local wasSelectedRef = if Flags.FoundationSliderCapture then React.useRef(false) else nil :: never
	local rangeTrackIsMaxRef = if Flags.FoundationSliderBeta then React.useRef(false) else nil :: never
	local rangeDragIsMaxKnob, setRangeDragIsMaxKnob
	if Flags.FoundationSliderBeta then
		rangeDragIsMaxKnob, setRangeDragIsMaxKnob = React.useState(false)
	end
	local value = useBindable(singleValue):map(function(currValue)
		return math.clamp(currValue, props.range.Min, props.range.Max)
	end)
	local rangeBinding: React.Binding<NumberRange> = if Flags.FoundationSliderBeta
		then useBindable(if sliderProps.type == SliderType.Range then sliderProps.value else NumberRange.new(0))
		else nil :: never

	local lastDragPosition = if Flags.FoundationSliderOffloadDraggingMath
		then nil :: never
		else React.useRef(nil :: Vector2?)
	local dragDetectorRef = if Flags.FoundationSliderOffloadDraggingMath
		then React.useRef<<UIDragDetector?>>(nil)
		else nil :: never
	-- The fraction we seek to on DragStart. DragUDim2 deltas are anchored to it.
	local dragStartFractionRef = if Flags.FoundationSliderOffloadDraggingMath then React.useRef(0) else nil :: never
	local minDragTranslation, setMinDragTranslation
	local maxDragTranslation, setMaxDragTranslation
	if Flags.FoundationSliderBeta then
		minDragTranslation, setMinDragTranslation = React.useBinding(UDim2.new())
		maxDragTranslation, setMaxDragTranslation = React.useBinding(UDim2.new())
	end
	local updateDragTranslationBounds = if Flags.FoundationSliderBeta
		then React.useCallback(function(base: number)
			if isVertical then
				setMinDragTranslation(UDim2.fromScale(0, base - 1))
				setMaxDragTranslation(UDim2.fromScale(0, base))
			else
				setMinDragTranslation(UDim2.fromScale(-base, 0))
				setMaxDragTranslation(UDim2.fromScale(1 - base, 0))
			end
		end, { isVertical })
		else nil :: never
	-- Previous DragUDim2 scale, used to detect the engine resetting the drag origin
	-- when directional input changes direction.
	local lastDragUDim2Ref = if Flags.FoundationSliderOffloadDraggingMath then React.useRef(0) else nil :: never
	local lastInputMode = useLastInputMode()
	local ref = React.useRef(nil :: GuiObject?)
	React.useImperativeHandle(forwardRef, function()
		return ref.current
	end, {})

	local trackInstance, setTrackInstance
	if Flags.FoundationSliderOffloadDraggingMath then
		trackInstance, setTrackInstance = React.useBinding<<GuiObject?>>(nil)
	end
	local setTrackRef = if Flags.FoundationSliderOffloadDraggingMath
		then ReactUtils.useComposedRef(ref, setTrackInstance)
		else nil :: never

	local pointerPosition = if Flags.FoundationSliderOffloadDraggingMath
		then nil :: never
		else usePointerPosition(ref.current)

	local variant = useSliderVariants(tokens, props.size, props.variant, isVertical)
	local motionStates = if Flags.FoundationSliderBeta
		then nil :: never
		else useSliderMotionStates(variant.knob.style, variant.knob.dragStyle)

	-- Determine current motion state based on visibility and interaction
	local currentMotionState = if Flags.FoundationSliderBeta
		then nil :: never
		else React.useMemo(function()
			if not isKnobVisible then
				return motionStates.Hidden
			end
			return if isDragging then motionStates.Dragging else motionStates.Idle
		end, { tokens, isKnobVisible, isDragging, motionStates } :: { unknown })

	local knobStyle = if Flags.FoundationSliderBeta
		then React.useMemo(function(): Types.ColorStyleValue
			if not isKnobVisible then
				return { Color3 = variant.knob.style.Color3, Transparency = 1 }
			elseif isDragging and not isRange then
				return variant.knob.dragStyle
			end
			return variant.knob.style
		end, { variant, isKnobVisible, isDragging, isRange } :: { unknown })
		else nil :: never

	local isSelected = if Flags.FoundationSliderKnobSelection
		then controlState == ControlState.Selected
			or controlState == ControlState.SelectedPressed
			or (Flags.FoundationSliderCapture and isCaptured)
		else nil :: never
	local onCapture = if Flags.FoundationSliderCapture
		then React.useCallback(function()
			if isCaptured then
				if isRange then
					setIsMaxThumbActive(not isMaxThumbActive)
				end
			else
				setIsCaptured(true)
			end
		end, { isCaptured, isRange, isMaxThumbActive } :: { unknown })
		else nil :: never
	if Flags.FoundationSliderCapture then
		useSliderCaptureKeys(isSelected and not props.isDisabled, onCapture)
	end

	if Flags.FoundationSliderCapture then
		React.useEffect(function()
			if props.isDisabled then
				setIsCaptured(false)
			end
		end, { props.isDisabled })

		React.useEffect(function()
			local function redirectDragSelection()
				local selectedObject = GuiService.SelectedObject
				local isUnexpectedSliderSelection = selectedObject == ref.current
					or (
						selectedObject ~= nil
						and ref.current ~= nil
						and selectedObject:IsDescendantOf(ref.current)
						and selectedObject ~= focusTargetRef.current
						and selectedObject ~= captureTargetRef.current
					)

				if isUnexpectedSliderSelection then
					GuiService.SelectedObject = focusTargetRef.current
				end
			end

			redirectDragSelection()
			local connection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(redirectDragSelection)
			return function()
				connection:Disconnect()
			end
		end, {})

		React.useEffect(function()
			if not isCaptured then
				return
			end

			GuiService.SelectedObject = captureTargetRef.current
			local connection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
				if GuiService.SelectedObject ~= captureTargetRef.current then
					setIsCaptured(false)
				end
			end)
			return function()
				connection:Disconnect()
			end
		end, { isCaptured })
	end

	React.useEffect(
		function()
			if Flags.FoundationSliderBeta and props.isDisabled then
				setIsKnobVisible(false)
			elseif props.knobVisibility :: Visibility == Visibility.None then
				setIsKnobVisible(if Flags.FoundationSliderKnobSelection then isSelected else false)
			elseif props.knobVisibility :: Visibility == Visibility.Always then
				setIsKnobVisible(true)
			else
				setIsKnobVisible(
					isDragging
						or controlState == ControlState.Hover
						or controlState == ControlState.Selected
						or controlState == ControlState.Pressed
				)
			end
		end,
		{
			props.knobVisibility,
			controlState,
			isDragging,
			if Flags.FoundationSliderBeta then props.isDisabled else nil,
			if Flags.FoundationSliderKnobSelection then isSelected else nil,
		} :: { unknown }
	)

	local calculateValueFromAbsPosition = if Flags.FoundationSliderOffloadDraggingMath
		then nil :: never
		else React.useCallback(function(position: Vector2)
			if ref.current then
				local unsteppedValue = calculateSliderValueFromPosition(position, ref.current, props.range)
				if props.step then
					return calculateSliderStepValue(unsteppedValue, props.step, props.range)
				end

				return unsteppedValue
			else
				return 0
			end
		end, { ref, props.range, props.step } :: { unknown })

	local updateValue = React.useCallback(function(newValue: number)
		if newValue ~= value:getValue() then
			if onSingleValueChanged then
				onSingleValueChanged(newValue)
			end
		end
	end, { value, onSingleValueChanged } :: { unknown })

	local updateRange = if Flags.FoundationSliderBeta
		then React.useCallback(function(newRange: NumberRange)
			local current = rangeBinding:getValue()
			if
				onRangeValueChanged
				and (typeof(current) ~= "NumberRange" or newRange.Min ~= current.Min or newRange.Max ~= current.Max)
			then
				onRangeValueChanged(newRange)
			end
		end, { rangeBinding, onRangeValueChanged } :: { unknown })
		else nil :: never

	local onKnobDragStarted = if Flags.FoundationSliderBeta
		then React.useCallback(function(isMaxKnob: boolean)
			setRangeDragIsMaxKnob(isMaxKnob)
			if Flags.FoundationSliderCapture then
				setIsMaxThumbActive(isMaxKnob)
			end
			setIsDragging(true)
			if props.onDragStarted then
				props.onDragStarted()
			end
		end, { props.onDragStarted })
		else nil :: never

	local onKnobDragEnded = if Flags.FoundationSliderBeta
		then React.useCallback(function()
			setIsDragging(false)
			if props.onDragEnded then
				props.onDragEnded()
			end
		end, { props.onDragEnded })
		else nil :: never

	local onMinKnobDragStarted = if Flags.FoundationSliderBeta
		then React.useCallback(function()
			onKnobDragStarted(false)
		end, { onKnobDragStarted })
		else nil :: never
	local onMaxKnobDragStarted = if Flags.FoundationSliderBeta
		then React.useCallback(function()
			onKnobDragStarted(true)
		end, { onKnobDragStarted })
		else nil :: never

	local onSeek = if Flags.FoundationSliderOffloadDraggingMath
		then nil :: never
		else React.useCallback(function()
			local newValue = calculateValueFromAbsPosition(pointerPosition:getValue())
			updateValue(newValue)
		end, { calculateValueFromAbsPosition, pointerPosition, updateValue } :: { unknown })

	local toFraction = if Flags.FoundationSliderBeta
		then React.useCallback(function(rawValue: number): number
			return math.clamp((rawValue - props.range.Min) / (props.range.Max - props.range.Min), 0, 1)
		end, { props.range.Min, props.range.Max } :: { unknown })
		else nil :: never
	local rawValueFromFraction = if Flags.FoundationSliderBeta
		then React.useCallback(function(fraction: number): number
			return props.range.Min + fraction * (props.range.Max - props.range.Min)
		end, { props.range.Min, props.range.Max } :: { unknown })
		else nil :: never
	local valueFromFraction = if Flags.FoundationSliderBeta
		then React.useCallback(function(fraction: number): number
			local rawValue = rawValueFromFraction(fraction)
			return if props.step then calculateSliderStepValue(rawValue, props.step, props.range) else rawValue
		end, { rawValueFromFraction, props.step, props.range } :: { unknown })
		else nil :: never

	local getMinBounds = if Flags.FoundationSliderBeta
		then React.useCallback(
			function(): (number, number)
				local maxFraction = toFraction(rangeBinding:getValue().Max)
				if props.step and props.step > 0 then
					local maxValue = rawValueFromFraction(maxFraction)
					local stepCount = math.floor((maxValue - props.range.Min) / props.step + 0.5)
					maxFraction = toFraction(props.range.Min + stepCount * props.step)
				end
				return 0, maxFraction
			end,
			{
				rangeBinding,
				toFraction,
				props.step,
				rawValueFromFraction,
				props.range.Min,
			} :: { unknown }
		)
		else nil :: never
	local getMaxBounds = if Flags.FoundationSliderBeta
		then React.useCallback(
			function(): (number, number)
				local minFraction = toFraction(rangeBinding:getValue().Min)
				if props.step and props.step > 0 then
					local minValue = rawValueFromFraction(minFraction)
					local stepCount = math.floor((minValue - props.range.Min) / props.step + 0.5)
					minFraction = toFraction(props.range.Min + stepCount * props.step)
				end
				return minFraction, 1
			end,
			{
				rangeBinding,
				toFraction,
				props.step,
				rawValueFromFraction,
				props.range.Min,
			} :: { unknown }
		)
		else nil :: never
	local onSeekMin = if Flags.FoundationSliderBeta
		then React.useCallback(function(fraction: number)
			local currentRange = rangeBinding:getValue()
			updateRange(NumberRange.new(math.min(valueFromFraction(fraction), currentRange.Max), currentRange.Max))
		end, { rangeBinding, updateRange, valueFromFraction } :: { unknown })
		else nil :: never
	local onSeekMax = if Flags.FoundationSliderBeta
		then React.useCallback(function(fraction: number)
			local currentRange = rangeBinding:getValue()
			updateRange(NumberRange.new(currentRange.Min, math.max(valueFromFraction(fraction), currentRange.Min)))
		end, { rangeBinding, updateRange, valueFromFraction } :: { unknown })
		else nil :: never

	local seekRangeKnob = if Flags.FoundationSliderBeta
		then React.useCallback(function(fraction: number, isMaxKnob: boolean)
			if isMaxKnob then
				local minBound, maxBound = getMaxBounds()
				onSeekMax(math.clamp(fraction, minBound, maxBound))
			else
				local minBound, maxBound = getMinBounds()
				onSeekMin(math.clamp(fraction, minBound, maxBound))
			end
		end, { getMaxBounds, getMinBounds, onSeekMax, onSeekMin } :: { unknown })
		else nil :: never

	local onRangeTrackDragStarted = if Flags.FoundationSliderBeta
		then React.useCallback(
			function(_rbx: UIDragDetector, inputPosition: Vector2)
				if not isRange or lastInputMode == InputMode.Directional or not ref.current then
					return
				end

				local fraction =
					calculateSliderFraction(getGuiInputPosition(inputPosition, ref.current), ref.current, isVertical)
				local currentRange = rangeBinding:getValue()
				local minFraction = toFraction(currentRange.Min)
				local maxFraction = toFraction(currentRange.Max)
				local isMaxKnob = math.abs(maxFraction - fraction) < math.abs(fraction - minFraction)
					or (minFraction == maxFraction and fraction > maxFraction)

				rangeTrackIsMaxRef.current = isMaxKnob
				if Flags.FoundationSliderCapture then
					setIsMaxThumbActive(isMaxKnob)
				end
				onKnobDragStarted(isMaxKnob)
				seekRangeKnob(fraction, isMaxKnob)
			end,
			{
				isRange,
				lastInputMode,
				isVertical,
				rangeBinding,
				onKnobDragStarted,
				seekRangeKnob,
				toFraction,
			} :: { unknown }
		)
		else nil :: never

	local onRangeTrackDrag = if Flags.FoundationSliderBeta
		then React.useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
			if not isRange or lastInputMode == InputMode.Directional or not ref.current then
				return
			end

			local guiInputPosition = getGuiInputPosition(inputPosition, ref.current)
			seekRangeKnob(
				calculateSliderFraction(guiInputPosition, ref.current, isVertical),
				rangeTrackIsMaxRef.current
			)
		end, { isRange, lastInputMode, isVertical, seekRangeKnob } :: { unknown })
		else nil :: never

	local onRangeTrackDragEnded = if Flags.FoundationSliderBeta
		then React.useCallback(function()
			if not isRange then
				return
			end
			onKnobDragEnded()
		end, { isRange, onKnobDragEnded } :: { unknown })
		else nil :: never

	local exitCapture = if Flags.FoundationSliderCapture
		then React.useCallback(function()
			setIsCaptured(false)
			GuiService.SelectedObject = focusTargetRef.current
		end, {})
		else nil :: never

	local directionalInputHandlers = if Flags.FoundationSliderAsSeenOnTV
		then React.useMemo(
			function()
				return {
					getValue = function()
						if Flags.FoundationSliderCapture and isRange then
							local currentRange = rangeBinding:getValue()
							return if isMaxThumbActive then currentRange.Max else currentRange.Min
						end
						return value:getValue()
					end,
					onStep = if Flags.FoundationSliderCapture
						then function(newValue: number)
							if isRange then
								local currentRange = rangeBinding:getValue()
								if isMaxThumbActive then
									updateRange(NumberRange.new(currentRange.Min, math.max(newValue, currentRange.Min)))
								else
									updateRange(NumberRange.new(math.min(newValue, currentRange.Max), currentRange.Max))
								end
							else
								updateValue(newValue)
							end
						end
						else function(newValue: number)
							local stepped = if props.step
								then calculateSliderStepValue(newValue, props.step, props.range)
								else newValue
							updateValue(stepped)
						end,
					onExit = if Flags.FoundationSliderCapture then exitCapture else nil,
				}
			end,
			{
				value,
				updateValue,
				props.step,
				props.range,
				if Flags.FoundationSliderCapture then isRange else nil,
				if Flags.FoundationSliderCapture then rangeBinding else nil,
				if Flags.FoundationSliderCapture then isMaxThumbActive else nil,
				if Flags.FoundationSliderCapture then updateRange else nil,
				if Flags.FoundationSliderCapture then exitCapture else nil,
			} :: { unknown }
		)
		else nil :: never

	if Flags.FoundationSliderAsSeenOnTV then
		if not Flags.FoundationSliderKnobSelection then
			isSelected = controlState == ControlState.Selected or controlState == ControlState.SelectedPressed
		end

		local isDirectionalInputActive = isSelected and not props.isDisabled
		if Flags.FoundationSliderCapture then
			isDirectionalInputActive = isDirectionalInputActive and isCaptured
		else
			isDirectionalInputActive = isDirectionalInputActive and not isRange
		end

		useSliderDirectionalInput(
			isDirectionalInputActive,
			props.step,
			props.range,
			isVertical,
			directionalInputHandlers
		)
	end

	local onDrag = if Flags.FoundationSliderOffloadDraggingMath
		then React.useCallback(
			function(_rbx: UIDragDetector, _inputPosition: Vector2)
				local dragDetector = dragDetectorRef.current
				if not dragDetector then
					return
				end

				local rangeSpan = props.range.Max - props.range.Min
				local delta = if Flags.FoundationSliderBeta and isVertical
					then -dragDetector.DragUDim2.Y.Scale
					else dragDetector.DragUDim2.X.Scale

				-- Directional input resets the engine's drag origin when the direction flips,
				-- which surfaces as a large jump in DragUDim2. Discard it and re-anchor to the
				-- current value so the knob keeps its position instead of snapping back.
				if
					lastInputMode == InputMode.Directional
					and math.abs(delta - lastDragUDim2Ref.current) > MAX_DIRECTIONAL_INPUT_DRAG_DELTA
				then
					dragStartFractionRef.current = (value:getValue() - props.range.Min) / rangeSpan - delta
					lastDragUDim2Ref.current = delta
					if Flags.FoundationSliderBeta then
						updateDragTranslationBounds(dragStartFractionRef.current)
					end
					return
				end

				lastDragUDim2Ref.current = delta

				-- DragUDim2 reports the drag's translation from the press point, so add it to
				-- the fraction we seeked to on DragStart to get the absolute position.
				local fraction = math.clamp(dragStartFractionRef.current + delta, 0, 1)
				local newValue = props.range.Min + fraction * rangeSpan

				updateValue(
					if props.step then calculateSliderStepValue(newValue, props.step, props.range) else newValue
				)
			end,
			{
				props.step,
				props.range,
				lastInputMode,
				value,
				updateValue,
				if Flags.FoundationSliderBeta then isVertical else nil,
				if Flags.FoundationSliderBeta then updateDragTranslationBounds else nil,
			} :: { unknown }
		)
		else React.useCallback(
				function(_rbx: UIDragDetector, position: Vector2)
					if ref.current and lastDragPosition.current then
						-- When step is enabled, use absolute position calculation for better
						-- stepping behavior instead of delta-based calculation
						if props.step and props.step > 0 then
							if lastInputMode == InputMode.Directional then
								-- Handle directional input movement by stepping one `props.step` at a time

								local pixelDisplacement = position - lastDragPosition.current
								local pixelDistanceX = math.abs(pixelDisplacement.X)
								local pixelsPerStep =
									calculatePixelsPerStep(ref.current.AbsoluteSize.X, props.step, props.range)

								-- Detect position jumps that are too large for a single frame
								-- Thumbstick movement is gradual, so anything > 2 steps is likely a position reset
								local maxExpectedMovement = pixelsPerStep * 2
								if pixelDistanceX > maxExpectedMovement then
									lastDragPosition.current = position
									return
								end

								-- Only register movement if it's at least the half the size of one step
								if pixelDistanceX < pixelsPerStep / 2 then
									return
								end

								local currentValue = value:getValue()
								local newValue =
									calculateNextStepValue(pixelDisplacement.X, currentValue, props.step, props.range)

								if newValue ~= currentValue then
									-- Only update position baseline when we actually step
									updateValue(newValue)
									lastDragPosition.current = position
								end
							else
								-- Handle normal drag movement by snapping to the nearest step
								local newValue = calculateValueFromAbsPosition(position)
								updateValue(newValue)
								lastDragPosition.current = position
							end
						else
							local length = ref.current.AbsoluteSize.Magnitude
							local delta = calculateSliderPositionDelta(position, lastDragPosition.current, length)

							lastDragPosition.current = position

							-- When using directional input (Gamepad/WASD/Arrow keys) with a Scriptable UIDragDetector,
							-- the `position` gets reset when making significant directional changes.
							-- Examples of this include going from Right -> Right+Up or Right -> Left.
							--
							-- In practice, this means that if the user moves the Slider to the right then wants to adjust
							-- and move back a bit towards the left, this will immediately jump to the center of the
							-- bar. To work around this, we discard that jump in position by making sure the delta isn't too large,
							-- then from there we receive incremental changes like normal and sliding continues to work smoothly.
							if
								lastInputMode == InputMode.Directional
								and math.abs(delta) > MAX_DIRECTIONAL_INPUT_DRAG_DELTA
							then
								return
							end

							-- Calculate the new value from the position
							local unsteppedValue = calculateValueFromAbsPosition(position)

							updateValue(unsteppedValue)
						end
					end
				end,
				{ props.step, props.range, lastInputMode, value, updateValue, calculateValueFromAbsPosition } :: { unknown }
			) :: never

	local onDragStarted = if Flags.FoundationSliderOffloadDraggingMath
		then React.useCallback(
			function(_rbx: UIDragDetector, inputPosition: Vector2)
				setIsDragging(true)

				if props.onDragStarted then
					props.onDragStarted()
				end

				lastDragUDim2Ref.current = 0

				local rangeSpan = props.range.Max - props.range.Min

				if lastInputMode == InputMode.Directional then
					-- Directional input has no meaningful press position, so anchor to the
					-- current value and let DragUDim2 deltas adjust it from there.
					dragStartFractionRef.current = (value:getValue() - props.range.Min) / rangeSpan
					if Flags.FoundationSliderBeta then
						updateDragTranslationBounds(dragStartFractionRef.current)
					end
					return
				end

				-- DragUDim2 only reports movement *after* the grab, so seek to the press point
				-- here and anchor subsequent drag deltas to this fraction.
				local pressValue

				if Flags.FoundationSliderBeta then
					if ref.current then
						pressValue = props.range.Min
							+ calculateSliderFraction(
									getGuiInputPosition(inputPosition, ref.current),
									ref.current,
									isVertical
								)
								* rangeSpan
					else
						pressValue = props.range.Min
					end
				else
					pressValue = if ref.current
						then calculateSliderValueFromPosition(inputPosition, ref.current, props.range)
						else props.range.Min
				end

				dragStartFractionRef.current = (pressValue - props.range.Min) / rangeSpan

				updateValue(
					if props.step then calculateSliderStepValue(pressValue, props.step, props.range) else pressValue
				)

				if Flags.FoundationSliderBeta then
					updateDragTranslationBounds(dragStartFractionRef.current)
				end
			end,
			{
				props.onDragStarted,
				props.step,
				props.range,
				lastInputMode,
				value,
				updateValue,
				if Flags.FoundationSliderBeta then isVertical else nil,
				if Flags.FoundationSliderBeta then updateDragTranslationBounds else nil,
			} :: { unknown }
		)
		else React.useCallback(function(_rbx: UIDragDetector, inputPosition: Vector2)
			lastDragPosition.current = inputPosition
			setIsDragging(true)
			if props.onDragStarted then
				props.onDragStarted()
			end
		end, { props.onDragStarted }) :: never

	local onDragEnded = React.useCallback(function(_rbx: UIDragDetector, _position: Vector2)
		setIsDragging(false)
		if not Flags.FoundationSliderOffloadDraggingMath then
			lastDragPosition.current = nil
		end

		if props.onDragEnded then
			props.onDragEnded()
		end
	end, { props.onDragEnded })

	local onStateChanged = React.useCallback(function(state: ControlState)
		setControlState(state)

		if not isRange and not Flags.FoundationSliderOffloadDraggingMath and state == ControlState.Pressed then
			onSeek()
		end

		if Flags.FoundationSliderCapture then
			local isNowSelected = state == ControlState.Selected or state == ControlState.SelectedPressed
			if isRange and isNowSelected and not wasSelectedRef.current then
				setIsMaxThumbActive(getSelectionEntryDirection(isVertical) < 0)
			end
			wasSelectedRef.current = isNowSelected
		end
	end, { onSeek, isRange, isVertical } :: { unknown })

	local presentationContext = if Flags.FoundationSliderKnobSelection then usePresentationContext() else nil :: never

	if Flags.FoundationSliderOffloadDraggingMath then
		React.useEffect(function()
			local dragDetector = dragDetectorRef.current
			if not dragDetector then
				return
			end
			if Flags.FoundationSliderBeta then
				dragDetector.ReferenceUIInstance = ref.current
			else
				local connection = dragDetector:AddConstraintFunction(
					1,
					function(proposedPosition: UDim2, proposedRotation: number)
						-- Keep the seeked fraction plus the drag delta within [0, 1] so the knob
						-- stops at the ends instead of over-dragging past them.
						local base = dragStartFractionRef.current
						local clampedDelta = math.clamp(proposedPosition.X.Scale, -base, 1 - base)
						return UDim2.fromScale(clampedDelta, 0), proposedRotation
					end
				)
				return function()
					connection:Disconnect()
				end
			end
		end, {})
	end

	local knobPosition = if isVertical then UDim2.fromScale(0.5, 0) else UDim2.fromScale(1, 0.5)
	local knobAnchorPoint = if props.isContained
		then value:map(function(currentValue: number)
			local valuePercent = (currentValue - props.range.Min) / (props.range.Max - props.range.Min)
			return if isVertical then Vector2.new(0.5, 1 - valuePercent) else Vector2.new(valuePercent, 0.5)
		end)
		else Vector2.new(0.5, 0.5)

	local hitboxThickness = UDim.new(
		0,
		if Flags.FoundationSliderBeta
			then getKnobSize(tokens, props.size).X.Offset
			else (variant.hitbox :: { height: number }).height
	)
	local rootSize = if isVertical
		then UDim2.new(hitboxThickness, props.width)
		else UDim2.new(props.width, hitboxThickness)

	local knobStroke = if Flags.FoundationSliderBeta
		then React.useMemo(function(): Types.Stroke?
			local variantKnobStroke = variant.knob.stroke
			if variantKnobStroke == nil then
				return nil
			end
			return {
				Color = variantKnobStroke.Color,
				Thickness = variantKnobStroke.Thickness,
				Transparency = blendTransparencies(
					if typeof(variantKnobStroke.Transparency) == "number" then variantKnobStroke.Transparency else nil,
					if isKnobVisible then 0 else 1
				),
			}
		end, { variant, isKnobVisible } :: { unknown })
		else nil :: never

	local customKnobSize, setCustomKnobSize
	if Flags.FoundationSliderKnobSelection then
		customKnobSize, setCustomKnobSize = React.useBinding<<Vector2>>(Vector2.zero)
	end
	local onCustomKnobSizeChanged = if Flags.FoundationSliderKnobSelection
		then React.useCallback(function(rbx: GuiObject)
			setCustomKnobSize(rbx.AbsoluteSize)
		end, {})
		else nil :: never
	local minKnobAppearance: SliderThumb.KnobAppearance = if Flags.FoundationSliderBeta
		then React.useMemo(
			function()
				return {
					size = props.size,
					style = if isKnobVisible
							and isDragging
							and not rangeDragIsMaxKnob
						then variant.knob.dragStyle
						else knobStyle,
					stroke = knobStroke,
					hasShadow = variant.knob.hasShadow,
				}
			end,
			{
				props.size,
				isKnobVisible,
				isDragging,
				rangeDragIsMaxKnob,
				variant.knob.dragStyle,
				knobStyle,
				knobStroke,
				variant.knob.hasShadow,
			} :: { unknown }
		)
		else nil :: never
	local maxKnobAppearance: SliderThumb.KnobAppearance = if Flags.FoundationSliderBeta
		then React.useMemo(
			function()
				return {
					size = props.size,
					style = if isKnobVisible
							and isDragging
							and rangeDragIsMaxKnob
						then variant.knob.dragStyle
						else knobStyle,
					stroke = knobStroke,
					hasShadow = variant.knob.hasShadow,
				}
			end,
			{
				props.size,
				isKnobVisible,
				isDragging,
				rangeDragIsMaxKnob,
				variant.knob.dragStyle,
				knobStyle,
				knobStroke,
				variant.knob.hasShadow,
			} :: { unknown }
		)
		else nil :: never

	local minFraction = if Flags.FoundationSliderBeta
		then rangeBinding:map(function(currentRange: NumberRange)
			return toFraction(currentRange.Min)
		end)
		else nil :: never
	local maxFraction = if Flags.FoundationSliderBeta
		then rangeBinding:map(function(currentRange: NumberRange)
			return toFraction(currentRange.Max)
		end)
		else nil :: never
	local showKnobSelection = if Flags.FoundationSliderKnobSelection
		then isSelected and (not Flags.FoundationSliderCapture or isCaptured)
		else nil :: never
	local activeRangeFraction = if Flags.FoundationSliderCapture and isRange
		then if isMaxThumbActive then maxFraction else minFraction
		else nil :: never
	local rangeKnobAnchorPoint = if Flags.FoundationSliderCapture and isRange
		then if props.isContained
			then activeRangeFraction:map(function(fraction: number)
				return if isVertical then Vector2.new(0.5, 1 - fraction) else Vector2.new(fraction, 0.5)
			end)
			else Vector2.new(0.5, 0.5)
		else nil :: never
	local rangeKnobSize = if Flags.FoundationSliderCapture and isRange
		then if props.knob
			then customKnobSize:map(function(size: Vector2)
				return UDim2.fromOffset(size.X, size.Y)
			end)
			else getKnobSize(tokens, props.size)
		else nil :: never
	local onCaptureTargetStateChanged = if Flags.FoundationSliderCapture
		then React.useCallback(function(_state: ControlState) end, {})
		else nil :: never
	local isDirectionalInput = Flags.FoundationSliderCapture and lastInputMode == InputMode.Directional and isSelected

	local dragDetector = if isDirectionalInput
		then nil
		else if isRange
			then React.createElement("UIDragDetector", {
				DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
				[React.Event.DragStart] = onRangeTrackDragStarted :: any,
				[React.Event.DragContinue] = onRangeTrackDrag :: any,
				[React.Event.DragEnd] = onRangeTrackDragEnded :: any,
				SelectionModeDragSpeed = if Flags.FoundationSliderAsSeenOnTV then UDim2.new() else nil,
				Enabled = not props.isDisabled,
			})
			else if Flags.FoundationSliderOffloadDraggingMath
				then React.createElement("UIDragDetector", {
					ref = dragDetectorRef,
					ReferenceUIInstance = trackInstance,
					DragStyle = Enum.UIDragDetectorDragStyle.TranslateLine,
					DragAxis = if isVertical then Vector2.new(0, 1) else Vector2.new(1, 0),
					ResponseStyle = Enum.UIDragDetectorResponseStyle.CustomScale,
					DragRelativity = Enum.UIDragDetectorDragRelativity.Absolute,
					MinDragTranslation = if Flags.FoundationSliderBeta then minDragTranslation else nil,
					MaxDragTranslation = if Flags.FoundationSliderBeta then maxDragTranslation else nil,
					[React.Event.DragStart] = onDragStarted,
					[React.Event.DragContinue] = onDrag,
					[React.Event.DragEnd] = onDragEnded,
					SelectionModeDragSpeed = if Flags.FoundationSliderAsSeenOnTV then UDim2.new() else nil,
					Enabled = not props.isDisabled,
				})
				else React.createElement("UIDragDetector", {
					DragStyle = Enum.UIDragDetectorDragStyle.Scriptable,
					[React.Event.DragStart] = onDragStarted :: any,
					[React.Event.DragContinue] = onDrag :: any,
					[React.Event.DragEnd] = onDragEnded :: any,
					SelectionModeDragSpeed = if Flags.FoundationSliderAsSeenOnTV then UDim2.new() else nil,
					Enabled = not props.isDisabled,
				})

	local barChildren: { [string]: React.ReactNode } = if isRange
		then {
			Fill = React.createElement(View, {
				tag = variant.fill.tag,
				AnchorPoint = Vector2.new(0, 0),
				Position = if isVertical
					then maxFraction:map(function(fraction: number)
						return UDim2.fromScale(0, 1 - fraction)
					end)
					else minFraction:map(function(fraction: number)
						return UDim2.fromScale(fraction, 0)
					end),
				Size = rangeBinding:map(function(currentRange: NumberRange)
					local extent = toFraction(currentRange.Max) - toFraction(currentRange.Min)
					return if isVertical then UDim2.fromScale(1, extent) else UDim2.fromScale(extent, 1)
				end),
				testId = `{props.testId}--fill`,
			}),
			MinKnob = React.createElement(SliderThumb, {
				trackRef = ref,
				fraction = minFraction,
				isVertical = isVertical,
				isDisabled = props.isDisabled,
				isDragEnabled = not isDirectionalInput,
				knobAppearance = minKnobAppearance,
				knob = props.knob,
				isContained = props.isContained,
				onSeek = onSeekMin,
				getBounds = getMinBounds,
				onDragStarted = onMinKnobDragStarted,
				onDragEnded = onKnobDragEnded,
				Visible = isKnobVisible,
				onAbsoluteSizeChanged = if Flags.FoundationSliderCapture then onCustomKnobSizeChanged else nil,
				LayoutOrder = 1,
				testId = `{props.testId}--min`,
			}),
			MaxKnob = React.createElement(SliderThumb, {
				trackRef = ref,
				fraction = maxFraction,
				isVertical = isVertical,
				isDisabled = props.isDisabled,
				isDragEnabled = not isDirectionalInput,
				knobAppearance = maxKnobAppearance,
				knob = props.knob,
				isContained = props.isContained,
				onSeek = onSeekMax,
				getBounds = getMaxBounds,
				onDragStarted = onMaxKnobDragStarted,
				onDragEnded = onKnobDragEnded,
				Visible = isKnobVisible,
				onAbsoluteSizeChanged = if Flags.FoundationSliderCapture then onCustomKnobSizeChanged else nil,
				LayoutOrder = 2,
				testId = `{props.testId}--max`,
			}),
			SelectionCursor = if Flags.FoundationSliderCapture and showKnobSelection
				then React.createElement(
					View,
					{
						Size = rangeKnobSize,
						AnchorPoint = rangeKnobAnchorPoint,
						Position = activeRangeFraction:map(function(fraction: number)
							return if isVertical
								then UDim2.fromScale(0.5, 1 - fraction)
								else UDim2.fromScale(fraction, 0.5)
						end),
						ZIndex = 3,
						selection = { Selectable = true },
						selectionGroup = CAPTURE_CURSOR_SELECTION_GROUP,
						cursor = CursorType.Invisible,
						onStateChanged = onCaptureTargetStateChanged,
						ref = captureTargetRef,
						testId = `{props.testId}--selection-cursor`,
					} :: View.ViewProps,
					{
						Cursor = React.createElement(CursorComponent, {
							isVisible = true,
							cornerRadius = UDim.new(0.5, 0),
							offset = tokens.Padding.XSmall,
							borderWidth = tokens.Stroke.Thicker,
							colorNamespace = presentationContext.colorNamespace,
						}),
					}
				)
				else nil,
		}
		else {
			Fill = React.createElement(View, {
				tag = variant.fill.tag,
				AnchorPoint = if isVertical then Vector2.new(0, 1) else nil,
				Position = if isVertical then UDim2.fromScale(0, 1) else nil,
				Size = value:map(function(alpha: number)
					local fraction = (alpha - props.range.Min) / (props.range.Max - props.range.Min)
					return if isVertical then UDim2.fromScale(1, fraction) else UDim2.fromScale(fraction, 1)
				end),
				testId = `{props.testId}--fill`,
			}, {
				SelectionCursor = if showKnobSelection
					then React.createElement(
						View,
						{
							Size = if props.knob
								then customKnobSize:map(function(size: Vector2)
									return UDim2.fromOffset(size.X, size.Y)
								end)
								else getKnobSize(tokens, props.size),
							AnchorPoint = knobAnchorPoint,
							Position = knobPosition,
							selection = if Flags.FoundationSliderCapture then { Selectable = true } else nil,
							selectionGroup = if Flags.FoundationSliderCapture
								then CAPTURE_CURSOR_SELECTION_GROUP
								else nil,
							cursor = if Flags.FoundationSliderCapture then CursorType.Invisible else nil,
							onStateChanged = onCaptureTargetStateChanged,
							ref = captureTargetRef,
							testId = `{props.testId}--selection-cursor`,
						} :: View.ViewProps,
						{
							Cursor = React.createElement(CursorComponent, {
								isVisible = true,
								cornerRadius = UDim.new(0.5, 0),
								offset = tokens.Padding.XSmall,
								borderWidth = tokens.Stroke.Thicker,
								colorNamespace = presentationContext.colorNamespace,
							}),
						}
					)
					else nil,
				Knob = if props.knob
					then React.createElement(View, {
						tag = "size-0-0 auto-xy",
						AnchorPoint = knobAnchorPoint,
						Position = knobPosition,
						Visible = isKnobVisible,
						onAbsoluteSizeChanged = if Flags.FoundationSliderKnobSelection
							then onCustomKnobSizeChanged
							else nil,
						testId = `{props.testId}--custom-knob`,
					}, props.knob)
					else React.createElement(PresentationContext.Provider, { value = IS_INVERSE }, {
						Knob = React.createElement(Knob, {
							AnchorPoint = knobAnchorPoint,
							Position = knobPosition,
							size = props.size,
							style = if Flags.FoundationSliderBeta then knobStyle else currentMotionState.knobStyle,
							stroke = if Flags.FoundationSliderBeta then knobStroke else variant.knob.stroke,
							hasShadow = variant.knob.hasShadow,
							testId = `{props.testId}--knob`,
						}),
					}),
			}),
		}

	local barSize = if Flags.FoundationSliderBeta
		then if isVertical then UDim2.new(0, variant.bar.height, 1, 0) else UDim2.new(1, 0, 0, variant.bar.height)
		else nil

	local bar = React.createElement(View, {
		tag = variant.bar.tag,
		Size = barSize,
		testId = `{props.testId}--bar`,
	}, barChildren)
	local sliderContent = {
		DragDetector = dragDetector,
		Bar = bar,
	}

	if Flags.FoundationSliderCapture then
		return React.createElement(
			View,
			withCommonProps(
				props,
				{
					Size = rootSize,
					GroupTransparency = if props.isDisabled then Constants.DISABLED_TRANSPARENCY else nil,
					selectionGroup = if isCaptured then CAPTURED_SELECTION_GROUP else FOCUSED_SELECTION_GROUP,
					ref = if isRange
						then ref
						else if Flags.FoundationSliderOffloadDraggingMath then setTrackRef else ref,
				} :: View.ViewProps
			),
			{
				FocusTarget = React.createElement(
					View,
					{
						Size = UDim2.fromScale(1, 1),
						stateLayer = {
							affordance = StateLayerAffordance.None,
						},
						cursor = if Flags.FoundationSliderKnobSelection
							then if isCaptured then CursorType.Invisible else nil
							else nil,
						onStateChanged = onStateChanged,
						isDisabled = props.isDisabled,
						ref = focusTargetRef,
						ZIndex = 0,
						testId = `{props.testId}--focus-target`,
					} :: View.ViewProps,
					{
						DragDetector = dragDetector,
					}
				),
				Bar = bar,
			}
		)
	end

	return React.createElement(
		View,
		withCommonProps(
			props,
			{
				Size = rootSize,
				GroupTransparency = if props.isDisabled then Constants.DISABLED_TRANSPARENCY else nil,
				stateLayer = {
					-- This element is just the hitbox so we don't actually want it to visually change
					affordance = StateLayerAffordance.None,
				},
				selectionGroup = if Flags.FoundationSliderAsSeenOnTV
					then if isRange
						then nil
						else if Flags.FoundationSliderBeta
							then variant.selectionGroup
							else DIRECTIONAL_SELECTION_GROUP
					else nil,
				cursor = if Flags.FoundationSliderKnobSelection then CursorType.Invisible else nil,
				onStateChanged = onStateChanged,
				isDisabled = props.isDisabled,
				ref = if isRange then ref else if Flags.FoundationSliderOffloadDraggingMath then setTrackRef else ref,
			} :: View.ViewProps
		),
		sliderContent
	)
end

return React.forwardRef(Slider)
