local _G = require "_G"
local assert = _G.assert
local pcall = _G.pcall
local print = _G.print
local select = _G.select
local type = _G.type

local math = require "math"
local ceil = math.ceil
local huge = math.huge
local min = math.min

local string = require "string"
local dump = string.dump

local table = require "table"
local unpack = table.unpack or _G.unpack

local vararg = require "vararg"
local pack = vararg.pack
local range = vararg.range
local insert = vararg.insert
local remove = vararg.remove
local replace = vararg.replace
local append = vararg.append
local concat = vararg.concat
local map = vararg.map

-- auxiliary functions----------------------------------------------------------

local values = {}
local maxstack = 1024
for i = 1, maxstack, 2 do
	values[i] = i
end

local function tpack(...)
	return {..., n=select("#", ...)}
end

local function assertsame(v, i, j, ...)
	local count = select("#", ...)
	assert(count == j-i+1, count..","..i..","..j)
	for pos = 1, count do
		assert(v[i+pos-1] == select(pos, ...))
	end
end

local function asserterror(expected, f, ...)
	local ok, actual = pcall(f, ...)
	assert(ok == false, "error was expected")
	assert(actual:find(expected, 1, true), "wrong error, got "..actual)
end

-- test 'pack' function --------------------------------------------------------

local function testpack(...)
	local v = {...}
	local n = select("#", ...)
	local p = pack(...)
	assertsame(v, 1, n, p())
	assert(n == p("#"))
	for i,pv in p do assert(v[i] == pv) end
	for i = 1, n do
		assert(v[i] == p(i))
		if n > 0 then
			assert(v[i] == p(i-n-1))
		end
	end
	for i = 1, n, 10 do
		local j = i+9
		assertsame(v, i, j, p(i, j))
		if n > j then
			assertsame(v, i, j, p(i-n-1, j-n-1))
		end
	end
end

testpack()
testpack({},{},{})
testpack(nil)
testpack(nil, nil)
testpack(nil, 1, nil)
testpack(unpack(values, 1, 254))
testpack(unpack(values, 1, 255))
testpack(unpack(values, 1, 256))
testpack(unpack(values, 1, maxstack))

-- test 'range' function -------------------------------------------------------

local function testrange(n, ...)
	local v = {...}
	for c = 1, 3 do
		for i = 1, n, c do
			local j = min(i+c-1, n)
			assertsame(v, i, j, range(i, j, ...))
			local n = select("#", ...)
			if n > 0 then
				assertsame(v, i, j, range(i-n-1, j-n-1, ...))
			end
		end
	end
end

testrange(10)
testrange(10, 1,2,3,4,5,6,7,8,9,0)
testrange(maxstack, unpack(values, 1, maxstack))

-- test other functions --------------------------------------------------------

assertsame({1,2,3,4,5}, 1, 5, insert(3, 3, 1,2,4,5))
assertsame({1,2,3,4,5}, 1, 5, insert(4,-1, 1,2,3,5))
assertsame({1,2,nil,4}, 1, 4, insert(4, 4, 1,2))
assertsame({nil,nil,3}, 1, 3, insert(3, 3))

assertsame({1,2,3,4,5}, 1, 5, replace(3, 3, 1,2,0,4,5))
assertsame({1,2,3,4,5}, 1, 5, replace(5,-1, 1,2,3,4,0))
assertsame({1,2,nil,4}, 1, 4, replace(4, 4, 1,2))
assertsame({nil,nil,3}, 1, 3, replace(3, 3))

assertsame({1,2,3,4,5}, 1, 5, remove( 3, 1,2,0,3,4,5))
assertsame({1,2,3,4,5}, 1, 5, remove(-1, 1,2,3,4,5,0))
assertsame({1,2,nil,4}, 1, 4, remove( 4, 1,2,nil,0,4))
assertsame({nil,nil,3}, 1, 3, remove( 3, nil,nil,0,3))
assertsame({1,2,3,4,5}, 1, 5, remove(10, 1,2,3,4,5))

assertsame({1,2,3,4,5}, 1, 5, append(5, 1,2,3,4))
assertsame({1,2,nil,4}, 1, 4, append(4, 1,2,nil))
assertsame({nil,nil,3}, 1, 3, append(3, nil,nil))

assertsame({1,2,3,4,5,6,7,8,9}, 1, 9, concat(pack(1,2,3),
                                             pack(4,5,6),
                                             pack(7,8,9)))

assertsame({"1","2","3","4","5"}, 1, 5, map(tostring, 1,2,3,4,5))
assertsame({"1","2","nil","4"  }, 1, 4, map(tostring, 1,2,nil,4))
assertsame({"nil","nil","3"    }, 1, 3, map(tostring, nil,nil,3))
assertsame({"1","nil","nil"    }, 1, 3, map(tostring, 1,nil,nil))

-- test function errors and expectional conditions ---------------------------

if not pcall(dump, insert) then -- C implementation
	asserterror("(index out of bounds)", range, 0, 0, ...)
	
	asserterror("(number expected, got no value)", insert)
	asserterror("(number expected, got no value)", insert, nil)
	asserterror("(number expected, got nil)", insert, nil, nil)
	asserterror("(index out of bounds)", insert, nil, 0)
	
	asserterror("(number expected, got no value)", replace)
	asserterror("(number expected, got no value)", replace, nil)
	asserterror("(number expected, got nil)", replace, nil, nil)
	asserterror("(index out of bounds)", replace, nil, 0)
	
	asserterror("(number expected, got no value)", remove)
	asserterror("(number expected, got nil)", remove, nil)
	asserterror("(index out of bounds)", remove, 0)
	
	assertsame({}, 1, 0, append())
	assertsame({nil}, 1, 1, append(nil))
	
	assertsame({}, 1, 0, concat())
	asserterror("attempt to call a nil value", concat, nil)
	
	asserterror("(value expected)", map)
	assertsame({}, 1, 0, map(nil))
	asserterror("attempt to call a nil value", map, nil, nil)
end

