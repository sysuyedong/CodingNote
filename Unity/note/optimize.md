# Unity优化
--------------
> 参考:  
> 1. [深入浅出聊优化：从Draw Calls到GC](http://www.cnblogs.com/murongxiaopifu/p/4284988.html)  
> 2. [【Unity技巧】Unity中的优化技术](http://blog.csdn.net/candycat1992/article/details/42127811)  
> 3. [Unity3D占用内存太大的解决方法](http://www.cnblogs.com/88999660/archive/2013/03/15/2961663.html)  
> 4. [Optimizing Graphics Performance](http://docs.unity3d.com/Manual/OptimizingGraphicsPerformance.html)  

## Unity性能影响因素  
影响Unity游戏运行性能的因素主要有三部分：内存、CPU和GPU，其中各个部分的有其主要的性能瓶颈：  
* **内存**
	* Unity引擎对象内存
	* Unity资源内存

* **CPU**
	* 过多的Draw Call
	* 复杂的物理计算
	* GC

* **GPU**
	* overdraw
	* 像素光照
	* 网格顶点数量
  
## 内存优化  
### Unity内存管理
* Unity的两种动态加载机制：一个是Resources.Load，另外一个通过AssetBundle。区别不大
* Assets加载:用AssetBundle.Load(同Resources.Load) 这才会从AssetBundle的内存镜像里读取并创建一个Asset对象，创建Asset对象同时也会分配相应内存用于存放(反序列化)。异步读取用AssetBundle.LoadAsync，也可以一次读取多个用AssetBundle.LoadAll
* AssetBundle的释放：AssetBundle.Unload(flase)是释放AssetBundle文件的内存镜像，不包含Load创建的Asset内存对象。AssetBundle.Unload(true)是释放那个AssetBundle文件内存镜像和并销毁所有用Load创建的Asset内存对象。
* 所以你Load出来的Assets其实就是个数据源，用于生成新对象或者被引用，生成的过程可能是复制（clone)也可能是引用（指针）。当你Destroy一个实例时，只是释放那些Clone对象，并不会释放引用对象和Clone的数据源对象，Destroy并不知道是否还有别的object在引用那些对象。
* 等到没有任何 游戏场景物体在用这些Assets以后，这些assets就成了没有引用的游离数据块了，是UnusedAssets了，这时候就可以通过Resources.UnloadUnusedAssets来释放,Destroy不能完成这个任 务，AssetBundle.Unload(false)也不行，AssetBundle.Unload(true)可以但不安全，除非你很清楚没有任何 对象在用这些Assets了。

### Unity内存种类  
实际上Unity游戏使用的内存一共有三种：程序代码、托管堆（Managed Heap）以及本机堆（Native Heap）。  
* **程序代码**包括了所有的Unity引擎，使用的库，以及你所写的所有的游戏代码。 这部分内存实际上是没有办法去“管理”的，它们将在内存中从一开始到最后一直存在。
	* 剥离不需要用到的Mono库和第三方库
* **托管堆**是被Mono使用的一部分内存。托管堆用来存放类的实例（比如用new生成的列表，实例中的各种声明的变量等）。“托管”的意思是Mono“应该”自动地改变堆的大小来适应你所需要的内存，并且定时地使用垃圾回收（Garbage Collect）来释放已经不需要的内存。
	* 尽可能早的时间将不需要的引用去除掉，以便回收机制将其清除
	* 对于频繁创建销毁的对象，使用Object Pool
* **本机堆**是Unity引擎进行申请和操作的地方，比如贴图，音效，关卡数据等。Unity使用了自己的一套内存管理机制来使这块内存具有和托管堆类似的功能。
	* 对象实例化完成后，调用AssetBundle.Unload(false)将内存镜像清除掉
	* 使用Resource.UnloadUnusedAssets将内存中无用的资源清除掉
	* 减少随场景依赖加载的资源，使用动态加载和卸载的方式代替，能减少内存占用
	* 场景Texture资源的mip map关掉，可以节省约1/3的内存
	* UI的贴图的颜色和Alpha通道分离，在Android下可以压缩(ETC1)
  
## CPU优化  
CPU通常受渲染批次(Draw Call)所限制  
* 网格优化：手动合并网格或者使用Unity静态(动态)批处理
* 材质、纹理：共享材质，使用更少的材质，将多个纹理合并成一个大纹理
* 尽量不使用反射，阴影，像素光等会导致物体多次渲染的功能
* 少使用物理组件，不用使用网格碰撞器
* 合理控制GC的频率
  
## GPU优化  
GPU通常受填充率(fillrate)和显存带宽所限制  
* 顶点数和vertex shaders：通常情况下，移动设备上顶点数不超过10万个，PC上不超过300万个。
* 不要使用多余的三角面
* 尽可能减少UV贴图接缝和硬边（顶点增多了一倍）的数量
* 写更高性能的shaders：
	* 使用系统自带的mobile版本；
	* 避免使用复杂的数学函数：比如pow、exp、log、cos、sin、tan等，alpha测试（裁剪discard）操作会使你的片段更慢
	* 浮点运算的精度：float - 32位浮点数格式，适合用于顶点变换，但是性能最慢；half - 减半的16位浮点数格式，适合用于纹理UV坐标，性能大约是float的2倍。；fixed - 10位顶点格式，适合用于颜色、光照计算和其它高性能操作，比float大约快4倍。
  
## 光照性能
优化光照能同时有减少CPU和GPU的开销：CPU需要处理的批次(Draw Calls)减少了；GPU需要处理的光照额外的顶点和像素也少了。  
* 使用Lightmap烘焙静态光，会比实时光的运行速度更快
* 使用shder的技巧代替关照效果，例如边缘光
* 避免使用多于1个的像素光，因为这样会使得被光照的物体渲染多次
* 使用投影阴影代替实时阴影
* 动态物体使用Lightprobes代替实时光照
  
## 纹理
* 使用压缩纹理会减少纹理的大小，这会加快加载速度和减少内存占用，并且能大幅提高渲染性能
* 使用mip map(多重纹理)能允许GPU使用更低分辨率的纹理，但是同时会增加内存消耗
  
## LOD、遮挡剔除、每层剔除距离
使用LOD、遮挡剔除和每层剔除距离来减少CPU和GPU负担  

## 像素优化
overdraw指的就是一个像素被绘制了多次，像素优化的重点在于减少overdraw，关键在于控制绘制顺序。
* 控制渲染顺序：
* 警惕透明物体：透明物体的渲染队列为Alpha Test或Alpha Blending，并且是从后到前的渲染顺序。
* 减少实时光照
  