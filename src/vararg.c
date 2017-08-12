/*
** $Id$
** Library for Vararg Manipulation
** See Copyright Notice in LICENSE
*/

#include "lua.h"
#include "lauxlib.h"


static int luaVA_len(lua_State *L) {
	lua_pushinteger(L, lua_gettop(L));
	return 1;
}

static lua_Integer posrelat (lua_Integer pos, int len) {
  if (pos >= 0) return pos;
  else return (lua_Integer)len + pos + 1;
}

static int luaVA_tuple(lua_State *L) {
	int n = (int)lua_tointeger(L, lua_upvalueindex(1));  /* number of packed values */
	int type = lua_type(L, 1);
	if (type == LUA_TNIL) {
		lua_Integer i = lua_tointeger(L, 2);
		if (++i>0 && i<=n) {
			lua_pushinteger(L, i);
			if (n<255) lua_pushvalue(L, lua_upvalueindex(2+(n-2+(int)i)%n));
			        else lua_rawgeti(L, lua_upvalueindex(2), i);
			return 2;
		}
	} else if (type == LUA_TSTRING && *lua_tostring(L, 1) == '#') {
		lua_pushinteger(L, n);
		return 1;
	} else {
		lua_Integer i = 1, e = n;
		int r = n;
		if (lua_gettop(L) > 0) {
			i = posrelat(luaL_checkinteger(L, 1), n);
			e = posrelat(luaL_optinteger(L, 2, i), n);
			if (i < 1) i = 1;
			if (e > n) e = n;
			if (i > e) return 0;
			r = (int)(e - i + 1);
			lua_settop(L, 0);
		}
		luaL_checkstack(L, r, "too many results");
		for(; i <= e; ++i) {
			if (n<255) lua_pushvalue(L, lua_upvalueindex(2+(n-2+(int)i)%n));
			        else lua_rawgeti(L, lua_upvalueindex(2), i);
		}
		return r;
	}
	return 0;
}

static int luaVA_pack(lua_State *L) {
	int n = lua_gettop(L);
	if (n<255) {
		lua_pushvalue(L, 1);
		lua_pushinteger(L, n);
		lua_replace(L, 1);
		lua_pushcclosure(L, luaVA_tuple, n+1);
	} else {
		int i;
		lua_createtable(L, n, 0);
		lua_pushvalue(L, 1);
		lua_rawseti(L, -2, 1);
		lua_replace(L, 1);
		for (i=n; i>=2; --i) lua_rawseti(L, 1, i);
		lua_pushinteger(L, n);
		lua_insert(L, 1);
		lua_pushcclosure(L, luaVA_tuple, 2);
	}
	return 1;
}

static int luaVA_range(lua_State *L) {
	int n = lua_gettop(L)-2;
	lua_Integer i = posrelat(luaL_checkinteger(L, 1), n);
	lua_Integer e = posrelat(luaL_checkinteger(L, 2), n);
	if (i < 1) i = 1;
	if (e > n) e = n;
	if (i > e) return 0;
	lua_settop(L, 2+(int)e);
	return (int)(e - i + 1);
}

static int luaVA_remove(lua_State *L) {
	int n = lua_gettop(L)-1;
	lua_Integer i = posrelat(luaL_checkinteger(L, 1), n);
	if (i > 0 && i <= n) {
		lua_remove(L, 1+(int)i);
		--n;
	}
	return n;
}

static int luaVA_replace(lua_State *L) {
	int n = lua_gettop(L)-2;
	lua_Integer i = posrelat(luaL_checkinteger(L, 2), n);
	if (i > n) {
		if (2+i >= INT_MAX || !lua_checkstack(L, (int)i-n))
			return luaL_error(L, "too many results");
		lua_settop(L, (int)i+1);
		lua_pushvalue(L, 1);
		return (int)i;
	}
	luaL_argcheck(L, i > 0, 2, "position out of bounds");
	lua_pushvalue(L, 1);
	lua_replace(L, 2+(int)i);
	return n;
}

static int luaVA_insert(lua_State *L) {
	int n = lua_gettop(L)-2;
	lua_Integer i = posrelat(luaL_checkinteger(L, 2), n);
	if (i > n) {
		if (2+i >= INT_MAX || !lua_checkstack(L, (int)i-n))
			return luaL_error(L, "too many results");
		lua_settop(L, (int)i+1);
		lua_pushvalue(L, 1);
		return (int)i;
	}
	luaL_argcheck(L, i > 0, 2, "position out of bounds");
	lua_pushvalue(L, 1);
	lua_insert(L, 2+(int)i);
	return n+1;
}

static int luaVA_append(lua_State *L) {
	int n = lua_gettop(L);
	luaL_checkany(L, 1);
	lua_pushvalue(L, 1);
	return n;
}

static int luaVA_gettopk(lua_State *L, int status, lua_KContext ctx) {
	(void)status;
	(void)ctx;
	return lua_gettop(L)-1;
}

static int luaVA_mapk(lua_State *L, int status, lua_KContext k) {
	int top, i = (int)k;
	(void)status;
	if (i>1) lua_replace(L, i); /* if continuation, remove result of last call */
	++i;                        /* continue processing next map */
	top = lua_gettop(L);
	for(; i<top; ++i) {
		lua_pushvalue(L, 1);
		lua_pushvalue(L, i);
		lua_callk(L, 1, 1, i, luaVA_mapk);
		lua_replace(L, i); /* to avoid the stack to double in size */
	}
	lua_pushvalue(L, 1);
	lua_insert(L, top);
	lua_callk(L, 1, LUA_MULTRET, 0, luaVA_gettopk);
	return luaVA_gettopk(L, LUA_OK, 0);
}

static int luaVA_map(lua_State *L) {
	int top = lua_gettop(L);
	luaL_checkany(L, 1);
	if (top > 1) return luaVA_mapk(L, LUA_OK, 1);
	return 0;
}

static int luaVA_concat(lua_State *L) {
	luaL_checkany(L, 1);
	lua_pushvalue(L, 1);
	lua_callk(L, 0, LUA_MULTRET, 0, luaVA_gettopk);
	return luaVA_gettopk(L, LUA_OK, 0);
}

static const luaL_Reg valib[] = {
	{"append", luaVA_append},
	{"concat", luaVA_concat},
	{"insert", luaVA_insert},
	{"len", luaVA_len},
	{"map", luaVA_map},
	{"pack", luaVA_pack},
	{"range", luaVA_range},
	{"remove", luaVA_remove},
	{"replace", luaVA_replace},
	{NULL, NULL}
};

LUALIB_API int luaopen_vararg(lua_State *L) {
	luaL_newlib(L, valib);
	return 1;
}
