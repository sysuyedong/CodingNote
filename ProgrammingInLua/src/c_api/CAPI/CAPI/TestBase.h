#pragma once
#include <lua.hpp>
#include <iostream>
#include "Tools.h"

using namespace std;

#define DLL_EXPORTS 1

#ifdef DLL_EXPORTS
#define DLL_API __declspec(dllexport)
#else
#define DLL_API __declspec(dllimport)
#endif

class TestBase
{
public:
	TestBase();
	~TestBase();

	virtual void DoTest(lua_State *L) = 0;
};