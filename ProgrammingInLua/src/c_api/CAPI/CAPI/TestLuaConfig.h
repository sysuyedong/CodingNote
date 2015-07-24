/*
Test C Api: reading lua config
*/

#pragma once
#include "Tools.h"
#include "TestBase.h"

class TestColor
{
public:
	int red;
	int green;
	int blue;
};

class TestLuaConfig : public TestBase
{
public:
	TestLuaConfig();
	~TestLuaConfig();

	virtual void DoTest(lua_State *L);
	void LoadLuaConfig(lua_State *L, const char* lua_path);
private:
	double GetField(lua_State *L, int index, const char* key);
};

