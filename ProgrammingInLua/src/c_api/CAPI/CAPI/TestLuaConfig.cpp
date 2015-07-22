#include "TestLuaConfig.h"

#define MAX_COLOR 255

using namespace std;

TestLuaConfig::TestLuaConfig()
{
}


TestLuaConfig::~TestLuaConfig()
{
}

void TestLuaConfig::LoadLuaConfig(lua_State *L, const char* lua_path)
{
	int error = luaL_loadfile(L, lua_path) || lua_pcall(L, 0, 0, 0);
	if (error)
	{
		Tools::Error(L, "fail");
		return;
	}

	//reading config in lua
	int window_width;
	int window_height;
	TestColor color;
	lua_getglobal(L, "window_width");
	lua_getglobal(L, "window_height");
	lua_getglobal(L, "color");

	window_width = lua_tonumber(L, -3);
	window_height = lua_tonumber(L, -2);

	color.red = GetField(L, -1, "red") * MAX_COLOR;
	color.green = GetField(L, -1, "green") * MAX_COLOR;
	color.blue = GetField(L, -1, "blue") * MAX_COLOR;
	cout << "window_width = " << window_width << ", window_height = " << window_height << endl;
	cout << "Color red = " << color.red << ", green = " << color.green << ", blue = " << color.blue << endl;
	cout << "====================================================" << endl;

	//calling funtion fibonacci in lua
	int n = 10;
	lua_getglobal(L, "fibonacci");
	lua_pushnumber(L, 10);
	if (lua_pcall(L, 1, 1, 0) != 0)
	{
		Tools::Error(L, "error calling function fibonacci.");
	}
	int f_result = lua_tonumber(L, -1);
	lua_pop(L, 1);
	cout << "fibonacci(" << n << ") = " << f_result << endl;
}

double TestLuaConfig::GetField(lua_State *L, int index, const char* key)
{
	if (!lua_istable(L, index))
	{
		Tools::Error(L, "index %d is not table", index);
		return -1;
	}
	lua_getfield(L, index, key);
	double value = lua_tonumber(L, -1);
	lua_pop(L, 1);
	return value;
}
