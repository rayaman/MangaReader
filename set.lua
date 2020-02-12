local pairs, setmetatable = pairs, setmetatable
local mt -- metatable
mt = {
  __add = function(s1, s2) -- union
    local s = {}
    for e in pairs(s1) do s[e] = true end
    for e in pairs(s2) do s[e] = true end
    return setmetatable(s, mt)
  end,
  __mul = function(s1, s2) -- intersection
    local s = {}
    for e in pairs(s1) do
      if s2[e] then s[e] = true end
    end
    return setmetatable(s, mt)
  end,
  __sub = function(s1, s2) -- set difference
    local s = {}
    for e in pairs(s1) do
      if not s2[e] then s[e] = true end
    end
    return setmetatable(s, mt)
  end,
  __tostring = function(s)
	return table.concat(s,",")
  end
}

local card = function(s) -- #elements
  local n = 0
  for k in pairs(s) do n = n + 1 end
  return n
end

return setmetatable({elements = pairs, card = card}, {
  __call = function(_, t) -- new set
    local t = t or {}
    local s = {}
    for _, e in pairs(t) do s[e:lower()] = true end
    return setmetatable(s, mt)
  end
})