local Foundation = script:FindFirstAncestor("Foundation")
local Packages = Foundation.Parent

local React = require(Packages.React)

type OnAbsoluteSizeChanged = ((instance: GuiObject) -> ())?

local function useAbsoluteSize(onAbsoluteSizeChanged: OnAbsoluteSizeChanged): (Vector2, (GuiObject) -> ())
	local size, setSize = React.useState(Vector2.zero)

	local handleAbsoluteSizeChanged = React.useCallback(function(rbx: GuiObject)
		setSize(rbx.AbsoluteSize)
		if onAbsoluteSizeChanged then
			onAbsoluteSizeChanged(rbx)
		end
	end, { onAbsoluteSizeChanged })

	return size, handleAbsoluteSizeChanged
end

return useAbsoluteSize
