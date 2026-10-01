local SocialLibraries = script:FindFirstAncestor("SocialLibraries")
local dependencies = require(SocialLibraries.dependencies)
local React = dependencies.React

local getTextBoundsAsync = dependencies.Foundation.Utility.getTextBoundsAsync

return function(text: string, font: Font | Enum.Font, fontSize: number, width: number?): Vector2?
	local bounds, setBounds = React.useState(nil :: Vector2?)

	React.useEffect(function()
		local cancelled = false
		task.spawn(function()
			local result = getTextBoundsAsync(text, font, fontSize, width)
			if result and not cancelled then
				setBounds(result)
			end
		end)

		return function()
			cancelled = true
		end
	end, { text, font, fontSize, width } :: { unknown })

	return bounds
end
