#pragma once
#include "TestBase.h"
#include <lua.hpp>

#define DLL_EXPORTS 1

#ifdef DLL_EXPORTS
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

extern "C"
{
	int Sub(lua_State *L);
	DLL_API int luaopen_testlibs(lua_State* L);
}

static luaL_Reg mylibs[] =
{
	{"sub", Sub},
	{NULL, NULL},
};

class TestCallFunc : public TestBase
{
public:
	TestCallFunc();
	~TestCallFunc();

	static int Add(lua_State *L);
	virtual void DoTest(lua_State *L);
};