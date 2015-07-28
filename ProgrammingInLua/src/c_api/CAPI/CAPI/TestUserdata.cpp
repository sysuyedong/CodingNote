#include "TestUserdata.h"

TestUserdata::TestUserdata()
{
}


TestUserdata::~TestUserdata()
{
}

void TestUserdata::DoTest(lua_State *L)
{
	Tools::LoadFile(L, "lua_array.lua");
}

//获得userdata并检验合法性(是否带有指定metatable)
LuaArray* checkLuaArray(lua_State *L)
{
	void* ud = luaL_checkudata(L, 1, "LuaArrayMetatable");
	luaL_argcheck(L, ud != NULL, 1, "Not Array");
	return (LuaArray*)ud;
}

//获得指定索引的值
double* getValue(lua_State *L)
{
	LuaArray *a = checkLuaArray(L);
	int index = luaL_checkint(L, 2);
	//检查参数合法性
	luaL_argcheck(L, index >= 1 && index <= a->size, 2, "index out of range");
	
	return &a->values[index - 1];
}

int New(lua_State *L)
{
	//获取参数，size: 数组大小
	int size = luaL_checkint(L, 1);

	size_t n_bytes = sizeof(LuaArray) + (size - 1) * sizeof(double);
	LuaArray *a = (LuaArray*)lua_newuserdata(L, n_bytes);
	a->size = size;

	//设置metatable
	luaL_newmetatable(L, "LuaArrayMetatable");
	lua_setmetatable(L, -2);

	return 1;
}

DLL_API int luaopen_array(lua_State* L)
{
	luaL_register(L, "array", arraylibs);

	return 1;
}

int Set(lua_State *L)
{
	double *val = getValue(L);
	double value = luaL_checknumber(L, 3);
	*val = value;

	return 0;
}

int Get(lua_State *L)
{
	double value = *getValue(L);
	lua_pushnumber(L, value);

	return 1;
}

int Size(lua_State *L)
{
	LuaArray *a = checkLuaArray(L);
	lua_pushnumber(L, a->size);

	return 1;
}
