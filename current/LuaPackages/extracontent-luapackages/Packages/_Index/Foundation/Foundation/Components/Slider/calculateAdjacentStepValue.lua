local SliderStepDirection = require(script.Parent.SliderStepDirection)
type SliderStepDirection = SliderStepDirection.SliderStepDirection

local SliderStepSize = require(script.Parent.SliderStepSize)
type SliderStepSize = SliderStepSize.SliderStepSize

local DEFAULT_STEP_FRACTION = 0.01
local PAGE_STEP_FRACTION = 0.1
local GRID_TOLERANCE = 1e-6

local function calculateAdjacentStepValue(
	currentValue: number,
	direction: SliderStepDirection,
	range: NumberRange,
	step: number?,
	size: SliderStepSize?
): number
	local span = range.Max - range.Min
	local isIncrement = direction == SliderStepDirection.Increment

	if step and step > 0 then
		local positions = if size == SliderStepSize.Page
			then math.max(1, math.round(PAGE_STEP_FRACTION * span / step))
			else 1
		local position = (currentValue - range.Min) / step
		local tolerance = GRID_TOLERANCE * math.max(1, math.abs(position))
		local target = if isIncrement
			then math.floor(position + tolerance) + positions
			else math.ceil(position - tolerance) - positions

		return math.clamp(range.Min + target * step, range.Min, range.Max)
	end

	local magnitude = if size == SliderStepSize.Page then PAGE_STEP_FRACTION * span else DEFAULT_STEP_FRACTION * span
	local delta = if isIncrement then magnitude else -magnitude

	return math.clamp(currentValue + delta, range.Min, range.Max)
end

return calculateAdjacentStepValue
