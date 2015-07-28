#include "TestCallFunc.h"

TestCallFunc::TestCallFunc()
{
}


TestCallFunc::~TestCallFunc()
{
}

void TestCallFunc::DoTest(lua_State *L)
{
	//ע�ᱻLua���õ�C����������"add"��ʾLua����ʱʹ�õ�ȫ�ֺ�������funcΪ�����õ�C����
	lua_register(L, "add", TestCallFunc::Add);
	const char* test1 = "print('2 + 2 = ', add(2, 2))";
	const char* test2 = "require'testlibs' print('4 - 2 = ', testlibs.sub(4, 2))";
	if (luaL_dostring(L, test2))
	{
		 cout << lua_tostring(L, -1) << endl;
	}
}

//ע���������б�Lua���õ�C�����ĸ�ʽ����a+bΪ��
int TestCallFunc::Add(lua_State *L)
{
	//��ջ�л�ȡ�������������Ϸ��ԣ�1��ʾLua����ʱ�ĵ�һ���������Դ�����
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);

	//�����������ջ������ж������ֵ�����Զ����ջ
	lua_pushnumber(L, arg1 + arg2);

	//����ֵ��ʾ�ú����ķ���ֵ������
	return 1;
}

//ע������C�����ⱻLua���õĸ�ʽ����a-bΪ��
extern "C" int Sub(lua_State *L)
{
	//��ջ�л�ȡ�������������Ϸ��ԣ�1��ʾLua����ʱ�ĵ�һ���������Դ�����
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);

	//�����������ջ������ж������ֵ�����Զ����ջ
	lua_pushnumber(L, arg1 - arg2);

	//����ֵ��ʾ�ú����ķ���ֵ������
	return 1;
}

//ע��testlibs.dll�⣬Lua��ʹ�øÿ���÷���testlibs.sub(1, 2)
DLL_API int luaopen_testlibs(lua_State* L)
{
	luaL_register(L, "testlibs", mylibs);
	return 1;
}
