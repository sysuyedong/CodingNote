#pragma once
#include <lua.hpp>

class TestBase
{
public:
	TestBase();
	~TestBase();

	virtual void DoTest(lua_State *L) = 0;
};