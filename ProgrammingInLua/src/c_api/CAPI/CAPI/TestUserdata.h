#pragma once
#include "TestBase.h"

extern "C"
{
	int New(lua_State *L);
	int Set(lua_State *L);
	int Get(lua_State *L);
	int Size(lua_State *L);
	DLL_API int luaopen_array(lua_State* L);
}

static luaL_Reg arraylibs[] =
{
	{ "new", New },
	{ "set", Set },
	{ "get", Get },
	{ "size", Size },
	{ NULL, NULL },
};

class LuaArray
{
public:
	int size;
	double values[1];
};

class TestUserdata : public TestBase
{
public:
	TestUserdata();
	~TestUserdata();
	virtual void DoTest(lua_State *L);
};

