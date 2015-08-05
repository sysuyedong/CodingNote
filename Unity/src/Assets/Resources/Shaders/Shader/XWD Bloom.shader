Shader "XiaoWanDou/Bloom" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom factor", Range(0.0, 1.0)) = 0.0
		_BlurTex("Base (RGB)", 2D) = "white" {}
		_MaskTex ("Mask (RGB)", 2D) = "white" {}
		_Weight("Blur Weight", Vector) = (1.0,0.9,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _BlurTex;
	sampler2D _MaskTex;
	uniform fixed _Bloom;
	uniform fixed4 _Weight;
	
	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv: TEXCOORD0;
	};

	struct v3f
	{
		float4 pos : SV_POSITION;
		float2 uv[7]: TEXCOORD0;
	};
	
	v2f vert(appdata_base v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
    	
    	return o;
	}
	
	half4 Bright(v2f i) : COLOR0
	{
		half4 tex = tex2D(_MainTex, i.uv.xy);
		tex *= tex;
		half value = max(max(tex.x,tex.y),tex.z);
		tex *= max(value - _Bloom,0.0f);
		tex.a =  1.0;

		return tex;
	}

	v3f BlurVertV(appdata_base v)
	{
		v3f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		o.uv[0] = v.texcoord.xy + float2(0, -3) * 0.005;
		o.uv[1] = v.texcoord.xy + float2(0, -2) * 0.005;
		o.uv[2] = v.texcoord.xy + float2(0, -1) * 0.005;
		o.uv[3] = v.texcoord.xy + float2(0, 0) * 0.005;
		o.uv[4] = v.texcoord.xy + float2(0, 1) * 0.005;
		o.uv[5] = v.texcoord.xy + float2(0, 2) * 0.005;
		o.uv[6] = v.texcoord.xy + float2(0, 3) * 0.005;
    	
    	return o;
	}

	v3f BlurVertH(appdata_base v)
	{
		v3f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		o.uv[0] = v.texcoord.xy + float2(-3, 0) * 0.005;
		o.uv[1] = v.texcoord.xy + float2(-2, 0) * 0.005;
		o.uv[2] = v.texcoord.xy + float2(-1, 0) * 0.005;
		o.uv[3] = v.texcoord.xy + float2(0, 0) * 0.005;
		o.uv[4] = v.texcoord.xy + float2(1, 0) * 0.005;
		o.uv[5] = v.texcoord.xy + float2(2, 0) * 0.005;
		o.uv[6] = v.texcoord.xy + float2(3, 0) * 0.005;
    	
    	return o;
	}
	
	half4 Blur(v3f i) : COLOR0
	{
		half4 sum = 0;
		
		sum += tex2D(_MainTex, i.uv[0]) * 0.07;
		sum += tex2D(_MainTex, i.uv[1]) * 0.13;
		sum += tex2D(_MainTex, i.uv[2]) * 0.18;
		sum += tex2D(_MainTex, i.uv[3]) * 0.24;
		sum += tex2D(_MainTex, i.uv[4]) * 0.18;
		sum += tex2D(_MainTex, i.uv[5]) * 0.13;
		sum += tex2D(_MainTex, i.uv[6]) * 0.07;
		return sum;
	}
	
	
	half4 Bloom(v2f i) : COLOR0
	{
		half4 tex0 = tex2D(_MainTex, i.uv.xy);
		half4 tex1 = tex2D(_BlurTex, i.uv.xy);
		half4 renderTex = tex0*_Weight.x + tex1 * _Weight.y;
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
		#pragma fragment Bright
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}
	// 1
	Pass { 
		CGPROGRAM
		
		#pragma vertex BlurVertV
		#pragma fragment Blur
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG	 
		}	
	// 2
	Pass {
		CGPROGRAM
		
		#pragma vertex BlurVertH
		#pragma fragment Blur
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG 
		}	
	// 3			
	Pass {
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment Bloom
		#pragma fragmentoption ARB_precision_hint_fastest 
		
		ENDCG
		}

	}
}
