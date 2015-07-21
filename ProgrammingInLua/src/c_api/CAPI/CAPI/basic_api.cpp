#include <map>
#include <iostream>
#include <string>
#include <vector>
#include <functional>
#include <algorithm>
#include <assert.h>
extern "C"
{
	#include <stdio.h>
}
#include <lua.hpp>

#pragma comment(lib, "lua5.1.lib")  

using namespace std;

void StackDump(lua_State *L);

int main(int argc, char* argv[])
{
	char buff[256];
	int error;
	lua_State *l = lua_open();
	luaL_openlibs(l);
	lua_pushnumber(l, 1);
	lua_pushboolean(l, 1);
	StackDump(l);

	while (fgets(buff, sizeof(buff), stdin) != NULL)
	{
		error = luaL_loadbuffer(l, buff, strlen(buff), "line") || lua_pcall(l, 0, 0, 0);
		if (error)
		{
			fprintf(stderr, "%s", lua_tostring(l, -1));
			lua_pop(l, 1);
		}
	}
	lua_close(l);

	return 0;
}

void StackDump(lua_State *L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; ++i)
	{
		int t = lua_type(L, i);
		switch (t)
		{
		case LUA_TBOOLEAN:
			printf("bool: %s", lua_toboolean(L, i) ? "true" : "false");
			break;
		case LUA_TSTRING:
			printf("string: %s", lua_tostring(L, i));
			break;
		case LUA_TNUMBER:
			printf("number: %g", lua_tonumber(L, i));
			break;
		default:
			printf("other value: %s", lua_typename(L, i));
			break;
		}
		printf("\n");
	}
}