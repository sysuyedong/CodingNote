Shader "XiaoWanDou/BscAndMask" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Mask (RGB)", 2D) = "white" {}
		_BSCParame("BSCParame Amount", Vector) = (1.0,1.0,1.0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _MaskTex;
	uniform float4 _BSCParame;
	
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
	
	half4 BscAndMask(v2f i) : COLOR0
	{
		half4 renderTex = tex2D(_MainTex, i.uv);
		half3 brtColor = renderTex.rgb * _BSCParame.x;
		half intensityf = dot(brtColor, half3(0.2125, 0.7154, 0.0721));
		half3 satColor = lerp(half3(intensityf, intensityf, intensityf), brtColor, _BSCParame.y);
		renderTex.rgb = lerp(half3(0.5, 0.5, 0.5), satColor, _BSCParame.z);

		half4 mask = tex2D(_MaskTex, i.uv);
		renderTex.rgb = (1 - mask.a) * renderTex.rgb + mask.a * mask.rgb;
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
		#pragma fragment BscAndMask
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}
	}

}
