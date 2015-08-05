Shader "XiaoWanDou/BSC" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BrightnessAmount ("Brightness Amount", Range(0.0, 2.0)) = 1.0
		_SaturationAmount ("Saturation Amount", Range(0.0, 2.0)) = 1.0
		_ContrastAmount ("Contrast Amount", Range(0.0, 2.0)) = 1.0
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	uniform float _BrightnessAmount;
    uniform float _SaturationAmount;
    uniform float _ContrastAmount;
	
	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv: TEXCOORD0;
	};
	
	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
    	
    	return o;
	}
	
	half4 Bsc(v2f i) : COLOR0
	{
		half4 renderTex = tex2D(_MainTex, i.uv);
		half3 brtColor = renderTex.rgb * _BrightnessAmount;
		half intensityf = dot(brtColor, half3(0.2125, 0.7154, 0.0721));
		half3 satColor = lerp(half3(intensityf, intensityf, intensityf), brtColor, _SaturationAmount);
		renderTex.rgb = lerp(half3(0.5, 0.5, 0.5), satColor, _ContrastAmount);
		return renderTex;
	}
	
	
	ENDCG
	
	SubShader {
	  ZTest Always Cull Off ZWrite Off Blend Off
	  Fog { Mode off }  
	  
	// 0
	Pass {
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment Bsc
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}
	}

}
