# Unity Shader  
--------------
> 参考:  
> 1. [Unity ShaderLab 学习总结](http://www.jianshu.com/p/7b9498e58659)  
> 2. [Unity Shaders and Effects Cookbook](http://book.douban.com/subject/24835416/)  
> 3. [Unity4.x 从入门到精通](http://book.douban.com/subject/25808326/)  
> 4. [Cg Tutorial](http://book.douban.com/subject/1783861/)  
> 5. [用JavaScript玩转计算机图形学(一)光线追踪入门](http://www.cnblogs.com/miloyip/archive/2010/03/29/1698953.html#!comments)  
> 6. [炼瓜研究所](http://zhuanlan.zhihu.com/alchemelon)

## 1 渲染管线
[渲染管线](http://www.cnblogs.com/alonecat06/archive/2012/09/24/2700747.html)  
渲染管线的基本构成由3个阶段组成：应用程序，几何和光栅化。每一个阶段都可能是一个管线，或者是并行的阶段。应用程序阶段是由应用程序驱动并且其由运行在通用CPU的软件代码所实现，包括碰撞检测，全局加速算法，动画，物理模拟等各种。几何阶段，处理几何变换，投影等。这个阶段计算绘制什么，如何绘制及在那里绘制。几何阶段通常运行在图形处理器(GPU)中。光栅阶段应用前阶段产生的数据绘制（渲染）图片，并且进行逐象素的计算。整个光栅阶段都在GPU上运行。

### 1.1 应用程序阶段
因为应用程序阶段运行于CPU上，开发者可以对其全面掌控。可以进行修改以提高运行效率。如通过优化减少将被渲染的多边形数。  
应用程序的最后步骤是将被渲染的几何体(点，线和三角形)输入到几何阶段。

### 1.2 几何阶段
几何阶段负责大多数的逐多边形和逐顶点的操作。分为下面的功能阶段：模型和视图的变换，顶点着色，投影，裁剪及屏幕映射，功能阶段可能与管线阶段(并行运行)相等，亦可能不同。，  

![几何阶段](https://github.com/sysuyedong/CodingNote/raw/master/Unity/img/geometry_stage.png)  
#### 1.2.1 模型和视图变换(Model & View Transform)
模型变换是指将对象从模型坐标系转换到世界坐标系。模型上的顶点和法向量会被模型变换所变换。  
摄像机位于世界空间，有方向和位置，为了进行投影和裁剪，摄像机和所有的模型会进行视图变换。进视图变换的目的是将摄像机的坐标移动到坐标原点，并且将观察方向指向z轴负方向，这样能提高后续操作(裁剪和投影)的效率。  
![几何阶段](https://github.com/sysuyedong/CodingNote/raw/master/Unity/img/view_transform.png)  

#### 1.2.2 顶点着色
决定光和材质特效的操作称为着色，它包括了计算不同点的着色方程。通常一部分方程运行在几何阶段的模型顶点数组上；另一部分则运行在逐像素的光栅化阶段。顶点着色的结果(颜色，向量，纹理坐标或其它着色数据)会被送进光栅化阶段去插值。

#### 1.2.3 投影
着色完成后，渲染系统开始进行投影，即将可视体转换到位于(-1, -1, -1)到(1, 1, 1)的单位立方体上(规则观察体)。有两种常用的投影方法：正投影和透视投影。

#### 1.2.4 裁剪
只有完全或部分处于可视体中的图元才会被传递到光栅阶段，该阶段将在屏幕绘制这些图元。在单位立方体外的图元将被丢弃而完全在内的图元将被保留。与单位立方体相交的图元会被单位立方体裁剪，新的顶点会生成而旧的会被丢弃。裁剪阶段（以及接下来的屏幕映射阶段）通常是运行在固定操作的硬件上。

#### 1.2.5 屏幕映射
在屏幕映射阶段，图元的x, y坐标被变换到屏幕坐标系中。新的x, y坐标与z坐标(-1 <= z <= 1)一并进入光栅阶段。

### 1.3 光栅阶段
得到已变换及投影后的顶点及与之相关联的着色数据（所有均来自几何阶段），光珊阶段的目标是计算并设置像素的颜色。这个过程叫光珊化或扫描变换，即从二维顶点所处的屏幕空间（所有顶点都包含Z值即深度值，及各种与相关的着色信息）到屏幕上的像素的转换。  
![光栅阶段](https://github.com/sysuyedong/CodingNote/raw/master/Unity/img/rasterize_stage.png)  
#### 1.3.1 三角形建立
在这个阶段微分及其它关于三角形表面的数据会被计算。这些数据用于扫描转换及几何阶段产生的各种着色数据的插值。这个过程运行在专门为其设计的硬件上。

#### 1.3.2 三角形遍历(扫描转换)
在这个阶段像素将被检查三解形是否覆盖其中心，而对于与三角形部分重合的像素，其重合部分将生成片段(fragment)。

#### 1.3.3 像素着色
所有逐像素的着色计算都在这阶段进行，使用插值得来的着色数据作为输入，最终的结果为将被传送到下一阶段的颜色。像素着色阶段在可编程GPU内核上运行，大量的技术可以在这里使用，其中最重要的技术之一为纹理贴图。

#### 1.3.4 融合
融合阶段的任务是合成现储存于缓冲器的由着色阶段产生片段的颜色。不像其它着色阶段，典型的运行该阶段的GPU子单元并非完全可编程的。但它是高度可配置支持多种特效的。  
可见性计算由Z缓存(深度缓存)算法完成。  
alpha管道与颜色缓存相关并且储存每个像素对应的透明值。可选的alpha测试可在深度测试执行前在传入片段上运行。片段的alpha值与参考值作某些特定的测试（如等于，大于等），如果片断未能通过测试，它将不再进行进一步的处理。这种测试经常用于不影响深度缓存的全透明片段。

## 2 类型  
* 表面着色器(Surface Shaders)：可以与灯光、阴影、投射器进行交互。表面着色器的抽象层次较高，可以容易地以简洁方式实现复杂的着色器效果。可同时工作在前向渲染(Forward Shading)以及延迟渲染(Deferred Shading)模式下。以Cg/HLSL语言编写。
* 顶点和片段着色器(Vertex and fragment Shaders)：处理一些表面着色器无法处理的酷炫效果，或者不需要与灯光进行交互，或者是全屏图像效果。它能灵活地实现需要的效果，但是很难与Unity的渲染管线完美集成。用Cg/HLSL语言编写。
* 固定功能管线着色器(Fixed Function Shaders)：在不支持可编程管线的硬件下使用。完全以ShaderLab语言编写。

## 3 ShaderLab结构  

```shader
	Shader "Custom/NewShader" {		//Shader的名称
		Properties {
			_MainTex ("Base (RGB)", 2D) = "white" {}
			//在这里定义Shader中使用的属性，如颜色，向量，纹理
		}
		//子着色器
		SubShader {
		} 
		SubShader {
		}
		FallBack "Diffuse"		//备选Shader
	}
```

### 3.1 Properties属性定义：
用来定义着色器中使用的贴图资源或者数值参数。这些属性会在Inspector中显示以方便修改。属性定义如下：  

```
	名称("显示名称", Vector) = 默认向量值				定义一个四维向量属性
	名称("显示名称", Color) = 默认颜色值				定义一个颜色(取值为0~1的四维向量)
	名称("显示名称", Float) = 默认浮点数值				定义一个浮点数属性
	名称("显示名称", Range(min, max)) = 默认浮点数值	定义一个浮点数范围属性，取值为min~max
	名称("显示名称", 2D) = 默认贴图名称{选项}			定义一个2D纹理属性
	名称("显示名称", Rect) = 默认贴图名称{选项}			定义一个矩形纹理属性(非2的n次幂)
	名称("显示名称", Cube) = 默认贴图名称{选项}			定义一个立方体纹理属性
	
	选项指的是一些纹理的可选参数：
	TexGen：纹理生成模式，包括ObjectLinear、EyeLinear、SphereMap、CubeReflect、CubeNormal
	LightmapMode：如果使用该选项，纹理将受渲染器的光照贴图参数影响
```

### 3.2 SubShader子着色器：
从上到下遍历子着色器，并使用第一个能被用户设备支持的子着色器进行渲染。  
子着色器由标签(可选)、通用状态(可选)、Pass列表组成，语法结构为：  

```
SubShader {
	[Tags标签]
	[CommonState通用状态]
	Passdef
	[Passdef ...Pass定义]
}
```

#### 3.3 Tags
* `"Queue"`标签，定义渲染顺序，内置的值为：
	* `"Background"`值为1000，比如用于天空盒。
	* `"Geometry"`值为2000，大部分物体在这个队列。队列内部物体的渲染顺序还会有进一步优化(应该是从近到远，early-z test可以剔除不需经过FS处理的片元)。其他队列的物体都是按空间位置的从远到近进行渲染。
	* `"AlphaTest"`值为2450。已进行AlphaTest的物体在这个队列。
	* `"Transparent"`值为3000。透明物体。
	* `"Overlay"`值为4000。比如镜头光晕。
	* 自定义值，如`"Overlay + 1"`
* `"RenderType"`标签，运行时替换符合特性RenderType的所有Shader。内置值为：
	* `"Opaque"`：绝大部分不透明的物体都使用这个
	* `"Transparent"`：绝大部分透明的物体、包括粒子特效都使用这个
	* `"Background"`：天空盒都使用这个
	* `"Overlay"`：GUI、镜头光晕都使用这个
* `"ForceNoShadowCasting"`标签，值为`"true"`表示不接受阴影
* `"IgnoreProjector"`标签，值为`"true"`表示不接受Projector组件的投影

#### 3.4 Pass
对于每个Pass，对象的几何体都被渲染一次。定义Pass的语法如下：  

```
Pass{
	[Name and Tags名称和标签]
	[RenderSetup渲染设置]
	[TextureSetup纹理设置]
}
```

* 名称和标签：定义Pass的名称和标签。可以在别的着色器中通过Pass名称来重用它。标签(键-值对)可以用来向渲染管线说明Pass的意图。
* 渲染设置：设置图形硬件的各种状态，例如开启Alpha混合、开启雾效等。
* 纹理设置：指定一些要使用的纹理及其混合模式。语法为`SetTexture纹理属性 {[命令选项]}`

### 3.5 Fallback备用着色器：
一般指定一个对硬件要求最低的Shader，当所有子着色器不能运行时，会使用备用着色器进行渲染

## 4 表面着色器(Surface Shaders)
表面着色器的实现代码需要放在`CGPROGRAM .. ENDCG`代码块中，它会自己编译到各个Pass中。  
使用`#pragma surface...`命令来指明它是一个表面着色器，如：  

```shader
// #pragma surface 表面函数 光照模型 [可选参数]
// 光照模型可以为Lambert和BlinnPhong，或者是自定义光照模型
// 表面函数表示哪个Cg函数包含表面着色器的代码，形式如下：
void surf(Input IN, inout SurfaceOutput o)
// 接收输入的UV或者附加数据，进行处理，最后将结果填充到输出结构体SurfaceOutput中
// 纹理坐标的命名规则为uv加纹理名称(uv_MainTex)

//附加数据
float3 viewDir			//视角方向
float4 COLOR			//每个顶点的插值颜色
float4 screenPos		//屏幕坐标
float3 worldPos			//世界坐标
float3 worldRefl		//世界坐标系中的反射向量
float3 worldNormal		//世界坐标系中的法线向量
INTERNAL_DATA			//当输入结构包含worldRefl或worldNormal且便面函数会写入输出结构的Normal字段时需包含此声明
```

SurfaceOutput描述了表面的各种参数，其结构为：  

```shader
struct SurfaceOutput{
	half3 Albedo;		//反射光
	half3 Normal;		//法线
	half3 Emission;		//自发光
	half3 Specular;		//高光
	half3 Gloss;		//光泽度
	half3 Alpha;		//透明度
}
```

自定义光照模型函数：  

```shader
half4 LightingName(SurfaceOutput s, half3 lightDir, half atten);			//不需要视角方向的前向着色
half4 LightingName(SurfaceOutput s, half3 lightDir, half3 viewDir half atten);		//需要视角方向的前向着色
half4 LightingName(SurfaceOutput s, half4 light);			//用于需要使用延时着色的项目
```

## 5 顶点和片段着色器(Vertex And Fragment Shaders)
顶点和片段着色器运行在具有可编程渲染管线的硬件上，包括顶点程序(Vertex Programs)和片段程序(Fragment Programs)。固定功能管线将会关闭，编写的顶点程序会替换固定管线中的3D变换、光照、纹理坐标生成能功能；片段程序会替换掉SetTexture命令中的纹理混合模式。结构如下：  

```shader
Pass{
	//通道设置
	CGPROGRAM
	//编译指令
	#pragma vertex vert
	#pragma fragment frag
	//Cg代码
	ENDCG
	//其他通道设置
}
```
