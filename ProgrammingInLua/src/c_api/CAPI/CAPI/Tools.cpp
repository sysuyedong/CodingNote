#include "Tools.h"

using namespace std;

Tools::Tools()
{
}


Tools::~Tools()
{
}

void Tools::Error(lua_State *L, const char* fmt, ...)
{
	va_list argp;
	va_start(argp, fmt);
	vfprintf(stderr, fmt, argp);
	va_end(argp);
	cout << "\n" << lua_tostring(L, -1) << endl;
	lua_close(L);
	exit(EXIT_FAILURE);
}

void Tools::StackDump(lua_State *L)
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

void Tools::CallFunction(lua_State *L, const char* func, const char* fmt, ...)
{

}
