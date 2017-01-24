package = "vararg"
version = "scm-1"
source = {
	url = "https://github.com/renatomaia/luavararg/archive/master.zip",
	dir = "luavararg-master",
}
description = {
	summary = "Manipulation of variable arguments",
	detailed = [[
		'vararg' is a Lua library for manipulation of variable arguments (vararg) of
		functions. These functions basically allows you to do things with vararg that
		cannot be efficiently done in pure Lua, but can be easily done through the C API.
	]],
	homepage = "https://git.tecgraf.puc-rio.br/maia/lua/vararg",
	license = "MIT"
}
dependencies = {
	"lua >= 5.2, < 5.4"
}
build = {
	type = "builtin",
	modules = {
		vararg = "src/vararg.c"
	},
}
