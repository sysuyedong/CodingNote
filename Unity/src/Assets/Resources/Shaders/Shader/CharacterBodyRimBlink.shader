Shader "XiaoWanDou/Character/Body/RimBlink" 
{  
	//--------------------------------【属性】---------------------------------------- 
	Properties   
    {  
        _MainTex ("Texture", 2D) = "white" {}  
        _RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)  
        _RimPower ("Rim Power", float) = 3.0
        _TimeOnDuration("ON duration",float) = 0.5
		_TimeOffDuration("OFF duration",float) = 0.5
		_BlinkingTimeOffsScale("Blinking time offset scale (seconds)",float) = 5
    }  

	//--------------------------------【子着色器】----------------------------------
    SubShader 
	{  
		//-----------子着色器标签----------  
        Tags { "RenderType"="Opaque" }  
        LOD 200  

        //-------------------开始CG着色器编程语言段-----------------  
        CGPROGRAM  

		//【1】光照模式声明：使用自制的卡通渐变光照模式
        #pragma surface surf QianMoCartoonShader  
		
		//变量声明  
        sampler2D _MainTex;  
        float4 _RimColor;  
        float _RimPower;
       	float _TimeOnDuration;
		float	_TimeOffDuration;
		float _BlinkingTimeOffsScale;

		//【2】实现自制的卡通渐变光照模式
        inline float4 LightingQianMoCartoonShader(SurfaceOutput s, fixed3 lightDir, fixed atten)  
        {  
			//点乘反射光线法线和光线方向
            half NdotL = max(0, dot (s.Normal, lightDir)); 
			//计算出最终结果
            half4 color;
			color.rgb = s.Albedo * _LightColor0.rgb * NdotL *  (atten * 2);
			color.a = s.Alpha;
			return color;
        }  

        //【3】输入结构    
        struct Input   
        {  
            //主纹理的uv值  
            float2 uv_MainTex;  
            //凹凸纹理的uv值  
            float2 uv_BumpMap;  
            //细节纹理的uv值  
            float2 uv_Detail;   
            //当前坐标的视角方向  
            float3 viewDir;  
        };  

		
		//【4】表面着色函数的编写
        void surf (Input IN, inout SurfaceOutput o)  
        {  
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            
            float time = _Time.y + _BlinkingTimeOffsScale;	
            
            half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));  
            
            float fracTime	= fmod(time,_TimeOnDuration + _TimeOffDuration);
            
            float wave = smoothstep(0,_TimeOnDuration * 0.25,fracTime)  * (1 - smoothstep(_TimeOnDuration * 0.75,_TimeOnDuration, fracTime));
            
            o.Emission = _RimColor.rgb * pow (rim, _RimPower) * _RimColor.a * wave;
        }  

        //-------------------结束CG着色器编程语言段------------------
        ENDCG  
    }   
    FallBack "Diffuse"  
}  