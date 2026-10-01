--[[
	`t` has no matcher for the Font datatype, so typography validators share this one.
]]

return function(value: unknown)
	if typeof(value) == "Font" then
		return true
	end
	return false, `expected Font, got {value}`
end
