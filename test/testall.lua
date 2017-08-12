local vararg = require "vararg"
local append = vararg.append
local concat = vararg.concat
local insert = vararg.insert
local len = vararg.len
local map = vararg.map
local pack = vararg.pack
local range = vararg.range
local remove = vararg.remove
local replace = vararg.replace

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

-- test 'len' function ---------------------------------------------------------

assert(len() == 0)
assert(len({},{},{}) == 3)
assert(len(nil) == 1)
assert(len(nil, nil) == 2)
assert(len(nil, 1, nil) == 3)
assert(len(table.unpack(values, 1, 254)) == 254)
assert(len(table.unpack(values, 1, 255)) == 255)
assert(len(table.unpack(values, 1, 256)) == 256)
assert(len(table.unpack(values, 1, maxstack)) == maxstack)

-- test 'pack' function --------------------------------------------------------

local function testpack(...)
	local v = {...}
	local n = select("#", ...)
	local p = pack(...)
	assertsame(v, 1, n, p())
	assert(n == p("#"))
	local c = 0
	for i, pv in p do
		c = c+1
		assert(c == i)
		assert(v[i] == pv)
	end
	assert(select("#", p(0)) == 0)
	assert(select("#", p(n+1)) == 0)
	assert(select("#", p(-(n+1))) == 0)
	for i = 1, n do
		assert(v[i] == p(i))
		assert(v[i] == p(i-n-1))
	end
	assert(select("#", p(-1, 0)) == 0)
	assert(select("#", p(0, 0)) == 0)
	for i = 1, n, 10 do
		assert(select("#", p(i, -(n+1))) == 0)
		assert(select("#", p(n+1, -i)) == 0)
		local j = i+9
		assertsame(v, i, math.min(n, j), p(i, j))
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
testpack(table.unpack(values, 1, 254))
testpack(table.unpack(values, 1, 255))
testpack(table.unpack(values, 1, 256))
testpack(table.unpack(values, 1, maxstack))

-- test 'range' function -------------------------------------------------------

local function testrange(n, ...)
	local v = {...}
	for c = 1, 3 do
		for i = 1, n, c do
			assert(select("#", range(i, -(n+1), ...)) == 0)
			assert(select("#", range(n+1, -i, ...)) == 0)
			local j = math.min(i+c-1, n)
			assertsame(v, i, j, range(i, j, ...))
			local n = select("#", ...)
			if n > 0 then
				assertsame(v, i, j, range(i-n-1, j-n-1, ...))
			end
		end
	end
end

testrange(0)
testrange(5 , nil,nil,nil,nil,nil)
testrange(10, 0,1,2,3,4,5,6,7,8,9)
testrange(maxstack, table.unpack(values, 1, maxstack))

-- test other functions --------------------------------------------------------

assert(select("#", remove(0)) == 0)
assert(select("#", remove(1)) == 0)
assert(select("#", remove(-1)) == 0)
assertsame({1,2,3,4,5}, 1, 5, remove( 3, 1,2,0,3,4,5))
assertsame({1,2,3,4,5}, 1, 5, remove(-1, 1,2,3,4,5,0))
assertsame({1,2,nil,4}, 1, 4, remove( 4, 1,2,nil,0,4))
assertsame({nil,nil,3}, 1, 3, remove( 3, nil,nil,0,3))
assertsame({1,2,3,4,5}, 1, 5, remove(10, 1,2,3,4,5))
assertsame({1,2,3,4,5}, 1, 5, remove( 0, 1,2,3,4,5))
assertsame({1,2,3,4,5}, 1, 5, remove( 6, 1,2,3,4,5))
assertsame({1,2,3,4,5}, 1, 5, remove(-6, 1,2,3,4,5))

assertsame({1}        , 1, 1, replace(1, 1))
assertsame({1,2,3,4,5}, 1, 5, replace(3, 3, 1,2,0,4,5))
assertsame({1,2,3,4,5}, 1, 5, replace(5,-1, 1,2,3,4,0))
assertsame({1,2,nil,4}, 1, 4, replace(4, 4, 1,2))
assertsame({nil,nil,3}, 1, 3, replace(3, 3))

assertsame({1}        , 1, 1, insert(1, 1))
assertsame({nil,nil,3}, 1, 3, insert(3, 3))
assertsame({1,2,3,4,5}, 1, 5, insert(3, 3, 1,2,4,5))
assertsame({1,2,3,4,5}, 1, 5, insert(4,-1, 1,2,3,5))
assertsame({1,2,nil,4}, 1, 4, insert(4, 4, 1,2))

assertsame({nil}      , 1, 1, append(nil))
assertsame({1}        , 1, 1, append(1))
assertsame({1,2,3,4,5}, 1, 5, append(5, 1,2,3,4))
assertsame({1,2,nil,4}, 1, 4, append(4, 1,2,nil))
assertsame({nil,nil,3}, 1, 3, append(3, nil,nil))
assertsame({1,nil,nil}, 1, 3, append(nil, 1,nil))

assert(select("#", map(nil)) == 0)
assert(select("#", map(error)) == 0)
assertsame({"1","2","3","4","5"}, 1, 5, map(tostring, 1,2,3,4,5))
assertsame({"1","2","nil","4"  }, 1, 4, map(tostring, 1,2,nil,4))
assertsame({"nil","nil","3"    }, 1, 3, map(tostring, nil,nil,3))
assertsame({"1","nil","nil"    }, 1, 3, map(tostring, 1,nil,nil))
local function three(v) return v,v,v end
assertsame({3,3,3}    , 1, 3, map(three, 3))
assertsame({1,2,3,3,3}, 1, 5, map(three, 1,2,3))

assert(select("#", concat(function () end)) == 0)
assertsame({1,2,3}, 1, 3, concat(function () end, 1,2,3))
assertsame({1,2,3}, 1, 3, concat(pack(1,2,3)))
assertsame({1,2,3,4,5,6}, 1, 6, concat(pack(4,5,6), 1,2,3))
assertsame({1,2,3,4,5,6,7,8,9}, 1, 9, concat(pack(7,8,9),
                                      concat(pack(4,5,6),
                                      concat(pack(1,2,3)))))

-- test function calls that yield ----------------------------------------------

local c = coroutine.create(function (...)
	return map(coroutine.yield, ...)
end)
local function resumetoend(c, ok, ...)
	assert(ok, ...)
	if coroutine.status(c) == "suspended" then
		return resumetoend(c, coroutine.resume(c, 9*(...)))
	end
	return ...
end
assertsame({9,18,27}, 1, 3, resumetoend(c, coroutine.resume(c, 1,2,3)))

local c = coroutine.create(function (...)
	return concat(coroutine.yield, ...)
end)
assert(coroutine.resume(c, 1,2,3))
assertsame({true, 1,2,3,4,5,6}, 1, 7, coroutine.resume(c, 4,5,6))

-- test function errors and exceptional conditions -----------------------------

asserterror("(number expected, got no value)", insert)
asserterror("(number expected, got no value)", insert, nil)
asserterror("(number expected, got nil)", insert, nil, nil)
asserterror("(position out of bounds)", insert, nil, 0)
asserterror("(position out of bounds)", insert, nil, -1)
asserterror("(position out of bounds)", insert, nil, 0, 1,2,3)
asserterror("(position out of bounds)", insert, nil, -4, 1,2,3)

asserterror("(number expected, got no value)", replace)
asserterror("(number expected, got no value)", replace, nil)
asserterror("(number expected, got nil)", replace, nil, nil)
asserterror("(position out of bounds)", replace, nil, 0)
asserterror("(position out of bounds)", replace, nil, -1)
asserterror("(position out of bounds)", replace, nil, 0, 1,2,3)
asserterror("(position out of bounds)", replace, nil, -4, 1,2,3)

asserterror("(number expected, got no value)", remove)
asserterror("(number expected, got nil)", remove, nil)

asserterror("(value expected)", append)

asserterror("(value expected)", concat)
asserterror("attempt to call a nil value", concat, nil)
asserterror("attempt to call a nil value", concat, nil, 1,2,3)

asserterror("(value expected)", map)
asserterror("attempt to call a nil value", map, nil, 1,2,3)

--------------------------------------------------------------------------------

print("Success!")
