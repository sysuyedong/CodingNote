#pragma once
#include <lua.hpp>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>

class Tools
{
public:
	Tools();
	~Tools();

	static void Error(lua_State *L, const char* fmt, ...);
	static void StackDump(lua_State *L);
	static void CallFunction(lua_State *L, const char* func, const char* fmt, ...);
};

