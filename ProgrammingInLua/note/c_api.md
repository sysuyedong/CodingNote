## C API
* C读取和调用Lua文件的库：lua.h, lauxlib.h, lualib.h
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
1表示第一个被压栈的元素；-1表示栈顶元素；当一个C函数返回后，Lua会清理他的栈，所以，有一个原则：永远不要将指向Lua字
符串的指针保存到访问他们的外部函数中。
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
void lua_pop(lua_State *L, int n)				//lua_settop(L, -n - 1),从堆栈中弹出n个元素
void lua_pushvalue(lua_State *L, int index);	//压入堆栈上指定一个索引的拷贝到栈顶
void lua_remove(lua_State *L, int index);		//移除指定索引位置的元素
void lua_insert(lua_State *L, int index);		//移动栈顶元素到指定索引的位置
void lua_replace(lua_State *L, int index);		//从栈顶中弹出元素并将其设置到指定索引位置
```