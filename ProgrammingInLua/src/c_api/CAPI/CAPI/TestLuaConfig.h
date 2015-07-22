/*
Test C Api: reading lua config
*/

#pragma once
#include <lua.hpp>
#include "Tools.h"

class TestColor
{
public:
	int red;
	int green;
	int blue;
};

class TestLuaConfig
{
public:
	TestLuaConfig();
	~TestLuaConfig();

	void LoadLuaConfig(lua_State *L, const char* lua_path);
private:
	double GetField(lua_State *L, int index, const char* key);
};

