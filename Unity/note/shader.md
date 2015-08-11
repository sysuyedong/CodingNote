# Unity Shader  
--------------
> 参考:  
> 1. [Unity ShaderLab 学习总结](http://www.jianshu.com/p/7b9498e58659)  
> 2. [Unity Shaders and Effects Cookbook](http://book.douban.com/subject/24835416/)  
> 3. [Unity4.x 从入门到精通](http://book.douban.com/subject/25808326/)  
> 4. [Cg Tutorial](http://book.douban.com/subject/1783861/)  

## 基础知识

### 渲染管线
[渲染管线](http://www.cnblogs.com/alonecat06/archive/2012/09/24/2700747.html)
渲染管线的基本构成由3个阶段组成：应用程序，几何和光栅化。每一个阶段都可能是一个管线，或者是并行的阶段。

## 类型  
* 表面着色器(Surface Shaders)：可以与灯光、阴影、投射器进行交互。表面着色器的抽象层次较高，可以容易地以简洁方式实现复杂的着色器效果。可同时工作在前向渲染(Forward Shading)以及延迟渲染(Deferred Shading)模式下。以Cg/HLSL语言编写。
* 顶点和片段着色器(Vertex and fragment Shaders)：处理一些表面着色器无法处理的酷炫效果，或者不需要与灯光进行交互，或者是全屏图像效果。它能灵活地实现需要的效果，但是很难与Unity的渲染管线完美集成。用Cg/HLSL语言编写。
* 固定功能管线着色器(Fixed Function Shaders)：在不支持可编程管线的硬件下使用。完全以ShaderLab语言编写。

## ShaderLab结构  

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

### Properties属性定义：
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

### SubShader子着色器：
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

#### Tags
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

#### Pass
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

### Fallback备用着色器：
一般指定一个对硬件要求最低的Shader，当所有子着色器不能运行时，会使用备用着色器进行渲染

## 表面着色器(Surface Shaders)
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

## 顶点和片段着色器(Vertex And Fragment Shaders)
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
