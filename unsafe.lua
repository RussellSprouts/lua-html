--Unsafe strings can be put into html templates, and they
--will be escaped properly.
--
--Usage:
--  local Unsafe = require'unsafe'
--  local unsafe_string = Unsafe("A string")
--  print(Unsafe.is(unsafe_string)) --> true

local Unsafe do
	local UnsafeM = {}
	UnsafeM.__index = UnsafeM
	
	function Unsafe(_,str)
		return setmetatable({type='unsafe', __unsafeString = str}, UnsafeM)
	end

	function UnsafeM:__tostring()
		error("Cannot convert unsafe string to string!")
	end
end

local function is_unsafe(str)
	return type(str) == 'table' and str.type == 'unsafe'
end

return setmetatable({is=is_unsafe},{__call=function(_, str) return Unsafe(str) end})