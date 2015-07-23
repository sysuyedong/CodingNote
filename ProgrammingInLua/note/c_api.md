## C API
* 云风Blog：[Lua C API 的正确用法](http://blog.codingnow.com/2015/05/lua_c_api.html)
* C读取和调用Lua文件的库：`lua.h, lauxlib.h, lualib.h`
* 包括：读写Lua全局变量的函数、调用Lua函数的函数、运行Lua代码片段的函数、注册C函数然后可以在Lua中被调用的函数
* C和Lua之间的数据交换，通过对栈上的值进行操作。栈的使用解决：Lua会自动进行垃圾回收，而C要求显示的分配内存单元；Lua中的动态类型和C的静态类型。
* **压入元素**：  
```C
void lua_pushnil(lua_State *L);										//插入空值
void lua_pushboolean(lua_State *L, int bool);						//插入布尔值
void lua_pushnumber(lua_State *L, double n);						//插入double
void lua_pushlstring(lua_State *L, const char* s, size_t length);	//插入任意字符串
void lua_pushstring(lua_State *L, const char* s);					//插入带'\0'的字符串
```  
* **查询元素**  
1表示第一个被压栈的元素；-1表示栈顶元素；当一个C函数返回后，Lua会清理他的栈，所以，有一个原则：永远不要将指向Lua字符串的指针保存到访问他们的外部函数中。
```C
int lua_is*(lua_State *L, int index);		//检查一个元素是否指定类型(number,string,boolean,table)

int lua_toboolean(lua_State *L, int index);
double lua_tonumber(lua_State *L, int index);
const char* lua_tostring(lua_State *L, int index);
size_t lua_strlen(lua_State *L, int index);
```
* **其他堆栈操作**
```C
int lua_gettop(lua_State *L);					//返回堆栈中的元素个数
void lua_settop(lua_State *L, int index);		//设置栈顶为一个指定的值，多余值被抛弃，否则压入nil值
void lua_pop(lua_State *L, int n);				//lua_settop(L, -n - 1),从堆栈中弹出n个元素
void lua_pushvalue(lua_State *L, int index);	//压入堆栈上指定一个索引的拷贝到栈顶
void lua_remove(lua_State *L, int index);		//移除指定索引位置的元素
void lua_insert(lua_State *L, int index);		//移动栈顶元素到指定索引的位置
void lua_replace(lua_State *L, int index);		//从栈顶中弹出元素并将其设置到指定索引位置
```
* **错误处理**  
应用程序中(调用Lua的C代码)的错误处理：当Lua遇到类似内存分配失败的情况，大部分会抛出异常，调用panic函数退出应用；其余情况会忽略异常，在保护模式下运行代码(Lua通过调用`lua_pcall`来运行)。  
类库(被Lua调用的C函数)中的错误处理：C函数发现错误只要调用`luaL_error`函数，清理所有在Lua中需要被清理的，然后和错误信息一起回到最初执行`lua_pcall`的地方。
* **表操作**  
```C
void lua_gettable(lua_State *L, int idx);					//以栈顶元素为key值，获取指定索引的表的值到栈顶
void lua_getfield(lua_State *L, int idx, const char *k);	//获取指定索引的表对应key的值到栈顶
void lua_getglobal(lua_State *L, const char *name);			//等于lua_getfield(L, LUA_GLOBALSINDEX, (name))。获取全局表的变量到栈顶
void lua_settable(lua_State *L, int idx);					//以栈顶元素为value，栈顶下一元素为key，设置指定索引的表的值
void lua_setfield(lua_State *L, int idx, const char *k);	//弹出栈顶元素，并设置为指定索引的表对应key的值
void lua_setglobal(lua_State *L, const char *name);			//等于lua_setfield(L, LUA_GLOBALSINDEX, (name))。设置全局变量的值
void lua_rawgeti(lua_State *L, int idx, int n);				//获得idx索引的表以n为key的值
void lua_rawget(lua_State *L, int idx);						//获得idx索引的表以栈顶为key的值
void lua_rawseti(lua_State *L, int idx, int n);				//设置idx索引的表以n为key的值
void lua_rawset(lua_State *L, int idx);						//设置idx索引的表以栈顶下一个元素为key的值
```
* **调用函数**  
使用API调用函数的方法是很简单的：首先，将被调用的函数入栈；第二，依次将所有参数入栈；第三，使用`lua_pcall`调用函数；最后，从栈中获取函数执行返回的结果。  
在将结果入栈之前，`lua_pcall`会将栈内的函数和参数移除。如果`lua_pcall`运行时出现错误，`lua_pcall`会返回一个非0的结果，并将错误信息入栈(依然会先移除栈内函数和参数)  
错误处理函数需要在被调用函数和参数之前入栈，参数errfunc为错误函数在栈中的索引。一般错误返回LUA_ERRRUN。内存分配错误返回LUA_ERRMEM；在错误处理函数中出错返回LUA_ERRERR，这两种情况并不会调用错误处理函数。
```C
int  lua_pcall(lua_State *L, int nargs, int nresults, int errfunc);		//调用栈顶函数，指定参数格式nargs，返回结果个数，nresults，和错误函数
```
* **调用C函数**  
`Lua`调用`C`函数，使用栈进行交互，用来交互的栈不是全局变量，每一个函数都有他自己的私有栈，第一个参数总是在这个私有栈的`index = 1`的位置。  
一个`Lua`库实际上是一个定义了一系列`Lua`函数的chunk，并将这些函数保存在适当的地方，通常作为`table` 的域来保存。`Lua`的`C`库就是这样实现的。  
在宿主程序中调用C函数
```C
//注册被Lua调用的C函数的格式，以a+b为例
static int func(lua_State *L)
{
	//从栈中获取函数参数并检查合法性，1表示Lua调用时的第一个参数，以此类推
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);
	
	//将函数结果入栈，如果有多个返回值，可以多次入栈
	lua_pushnumber(L, arg1 + arg2);
	
	//返回值表示该函数的返回值的数量
	return 1;
}

int main()
{
	lua_State* L = luaL_newstate();
	luaL_openlibs(L);
	
	//注册被Lua调用的C函数，参数"add"表示Lua调用时使用的全局函数名，func为被调用的C函数
	lua_register(L, "add", func);
	luaL_dostring("print(add(1, 2))");
	
	lua_close(L);
	return 0;
}
```
C函数库
```C
//注册被Lua调用的C函数的格式，以a+b为例，函数必须以C的形式被导出
extern "C" int func(lua_State *L)
{
	//从栈中获取函数参数并检查合法性，1表示Lua调用时的第一个参数，以此类推
	double arg1 = luaL_checknumber(L, 1);
	double arg2 = luaL_checknumber(L, 2);
	
	//将函数结果入栈，如果有多个返回值，可以多次入栈
	lua_pushnumber(L, arg1 + arg2);
	
	//返回值表示该函数的返回值的数量
	return 1;
}

static luaL_Reg mylibs[] = 
{
	{"add", func},
	{NULLL, NULL},
};

//注册mylibs库，Lua中使用该库的用法：testlibs.add(1, 2)
extern "C" __declspec(dllexport)
int luaopen_testlibs(lua_State* L) 
{
	luaL_newlib(L, mylibs);
}
```
* **字符串处理**  
当`C`函数接受一个来自`lua`的字符串作为参数时，有两个规则必须遵守：当字符串正在被访问的时候不要将其出栈；永远不要修改字符串。  
当`C`函数需要创建一个字符串返回给`lua`的时候，`C`代码负责缓冲区的分配和释放，负责处理缓冲溢出等情况。
```C
void lua_concat(lua_State *L, int n);		//连接栈顶开始的n个字符串，弹出这n个字符串并压栈结果
const char *lua_pushfstring(lua_State *L, const char *fmt, ...);	//根据格式串fmt的要求创建一个新的字符串。
```