local Packages = script.Parent.Parent

local SafeFlags = require(Packages.SafeFlags)

return {
	RoactFitComponentsFontDatatypeSupport = SafeFlags.createGetFFlag("RoactFitComponentsFontDatatypeSupport")(),
}
