-- qar_ty code of all time

_realprint = print
_tostring = tostring

local function fixtable(t)
    local c = getmetatable(t)
    if c and c["__tostring"] then return _tostring(t) end
	local c = "["
	for i, v in pairs(t) do
        if type(i) ~= "number" then c = c .. tostring(i) .. " = " end
		if type(v) == "table" then
			c = c .. fixtable(v)
		else
			c = c .. _tostring(v)
		end
		c = c .. ", "
	end
	c = string.sub(c, 0, string.len(c) - 2) .. "]"
	return c
end

function _G.tostring(v)
	if type(v) == "table" then
		return fixtable(v)
	else
		return _tostring(v)
	end
end
local unpack = unpack or table.unpack
function _G.print(...)
    local h = {...}
    local h2 = {}
    for i, v in pairs(h) do
        if type(v) == "table" then
            h2[i] = fixtable(v)
        else
            h2[i] = v
        end
    end
    _realprint(unpack(h2))
end
