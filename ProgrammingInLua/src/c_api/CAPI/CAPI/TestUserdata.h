#pragma once
#include "TestBase.h"
class TestUserdata : public TestBase
{
public:
	TestUserdata();
	~TestUserdata();
	virtual void DoTest(lua_State *L);
};

