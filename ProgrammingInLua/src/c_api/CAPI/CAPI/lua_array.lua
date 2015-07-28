require("array")

local a = array.new(10)
local mt = getmetatable(a)

for k = 1, array.size(a) do
	array.set(a, k, k * 2)
end

for k = 1, array.size(a) do
	print(array.get(a, k))
end

mt.__index = mt
mt.set = array.set
mt.get = array.get
mt.size = array.size

for k = 1, a:size() do
	a:set(k, k / 10)
	print(a:get(k))
end

--[[
mt.__index = array.get
mt.__newindex = array.set

for k = 1, array.size(a) do
	a[k] = k / 10
	print(a[k])
end
]]