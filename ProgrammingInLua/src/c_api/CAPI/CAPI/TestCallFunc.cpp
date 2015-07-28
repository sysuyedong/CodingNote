#include "TestCallFunc.h"

TestCallFunc::TestCallFunc()
{
}


TestCallFunc::~TestCallFunc()
{
}

void TestCallFunc::DoTest(lua_State *L)
{
	//注册被Lua调用的C函数，参数"add"表示Lua调用时使用的全局函数名，func为被调用的C函数
	lua_register(L, "add", TestCallFunc::Add);
	const char* test1 = "print('2 + 2 = ', add(2, 2))";
	const char* test2 = "require'testlibs' print('4 - 2 = ', testlibs.sub(4, 2))";
	if (luaL_dostring(L, test2))
	{
		 cout << lua_tostring(L, -1) << endl;
	}
}

//注册在宿主中被Lua调用的C函数的格式，以a+b为例
int TestCallFunc::Add(lua_State *L)
{
	//从栈中获取函数参数并检查合法性，1表示Lua调用时的第一个参数，以此类推
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);

	//将函数结果入栈，如果有多个返回值，可以多次入栈
	lua_pushnumber(L, arg1 + arg2);

	//返回值表示该函数的返回值的数量
	return 1;
}

//注册做成C函数库被Lua调用的格式，以a-b为例
extern "C" int Sub(lua_State *L)
{
	//从栈中获取函数参数并检查合法性，1表示Lua调用时的第一个参数，以此类推
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);

	//将函数结果入栈，如果有多个返回值，可以多次入栈
	lua_pushnumber(L, arg1 - arg2);

	//返回值表示该函数的返回值的数量
	return 1;
}

//注册testlibs.dll库，Lua中使用该库的用法：testlibs.sub(1, 2)
DLL_API int luaopen_testlibs(lua_State* L)
{
	luaL_register(L, "testlibs", mylibs);
	return 1;
}
