#include "TestLuaConfig.h"
#include "TestBase.h"
#include "TestCallFunc.h"
#include "TestUserdata.h"
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

void BasicAPI(lua_State *L);
void StackDump(lua_State *L);
enum TestOption
{
	Exit,
	Basic,
	LuaConfig,
	CallFunc,
	Userdata,
};

const string TestOptionArr[] { "Exit", "BasicAPI", "ReadLuaConfig", "Test Call Function", "Test Userdata" };
TestBase *test_ptr;

int main(int argc, char* argv[])
{
	lua_State *L = lua_open();
	luaL_openlibs(L);

	TestOption test_option;
	int temp;
	int size = sizeof(TestOptionArr) / sizeof(string);
	cout << "Input Test Option:" << endl;
	for (int i = 0; i < size; ++i)
	{
		cout << i << ": " << TestOptionArr[i] << endl;
	}
	cin >> temp;
	cout << "==============================================" << endl;
	test_option = (TestOption)temp;

	switch (test_option)
	{
	case Exit:
		break;
	case Basic:
		BasicAPI(L);
		break;
	case LuaConfig:
		test_ptr = new TestLuaConfig();
		test_ptr->DoTest(L);
		break;
	case CallFunc:
		test_ptr = new TestCallFunc();
		test_ptr->DoTest(L);
		break;
	case Userdata:
		test_ptr = new TestUserdata();
		test_ptr->DoTest(L);
		break;
	default:
		break;
	}

	lua_close(L);

	return 0;
}

void BasicAPI(lua_State *L)
{
	char buff[256];
	int error;
	while (fgets(buff, sizeof(buff), stdin) != NULL)
	{
		error = luaL_loadbuffer(L, buff, strlen(buff), "line") || lua_pcall(L, 0, 0, 0);
		if (error)
		{
			fprintf(stderr, "%s", lua_tostring(L, -1));
			lua_pop(L, 1);
		}
	}
}