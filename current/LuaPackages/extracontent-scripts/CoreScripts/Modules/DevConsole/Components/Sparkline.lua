--!nonstrict
local CorePackages = game:GetService("CorePackages")
local Roact = require(CorePackages.Packages.Roact)

local Constants = require(script.Parent.Parent.Constants)
local LINE_WIDTH = Constants.GeneralFormatting.LineWidth
local DEFAULT_COLOR = Constants.Color.HighlightBlue
local DEFAULT_SPARKLINE_SIZE = UDim2.fromOffset(52, 13)

export type Props = {
	dataSet: any,
	getY: (any) -> number,
	minY: number,
	maxY: number,
	color: Color3?,
	size: UDim2?,
	pos: UDim2?,
	layoutOrder: number?,
}

local Sparkline = Roact.Component:extend("Sparkline")

function Sparkline:init()
	self.graphRef = Roact.createRef()
	self.state = {
		absSize = nil,
	}
end

function Sparkline:didMount()
	self:setState({ absSize = self.graphRef.current.AbsoluteSize })
end

function Sparkline:didUpdate()
	local absSize = self.graphRef.current.AbsoluteSize
	if self.state.absSize ~= absSize then
		self:setState({ absSize = absSize })
	end
end

function Sparkline:render()
	local dataSet = self.props.dataSet
	local getY = self.props.getY
	local minY = self.props.minY
	local maxY = self.props.maxY
	local color = self.props.color or DEFAULT_COLOR
	local absSize = self.state.absSize

	local segments = {}
	if absSize and dataSet then
		local values = {}
		local iter = dataSet:iterator()
		local entry = iter:next()
		while entry do
			table.insert(values, getY(entry))
			entry = iter:next()
		end

		local divisor = maxY - minY
		local count = #values
		for i = 2, count do
			local aY = divisor > 0 and (values[i] - minY) / divisor or 0.5
			local bY = divisor > 0 and (values[i - 1] - minY) / divisor or 0.5

			local aX = (i - 1) / (count - 1) * absSize.X
			local bX = (i - 2) / (count - 1) * absSize.X
			aY *= absSize.Y
			bY *= absSize.Y

			local vecPosX = (aX + bX) / 2
			local vecPosY = (aY + bY) / 2
			local vecX = aX - bX
			local vecY = aY - bY

			local length = math.sqrt((vecX * vecX) + (vecY * vecY))
			local rot = math.deg(math.atan2(vecY, vecX))

			segments["seg" .. i] = Roact.createElement("Frame", {
				Size = UDim2.new(0, length, 0, LINE_WIDTH),
				Position = UDim2.new(0, vecPosX - length / 2, 1, -vecPosY),
				BackgroundColor3 = color,
				BorderSizePixel = 0,
				Rotation = -rot,
			})
		end
	end

	return Roact.createElement("Frame", {
		Size = self.props.size or DEFAULT_SPARKLINE_SIZE,
		Position = self.props.pos,
		LayoutOrder = self.props.layoutOrder,
		BackgroundTransparency = 1,
		[Roact.Ref] = self.graphRef,
	}, segments)
end

return Sparkline
