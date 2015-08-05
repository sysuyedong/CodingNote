Shader "XiaoWanDou/DOF" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurTex ("Base (RGB)", 2D) = "white" {}
		_Parame("Parame", Vector) = (1,0.2,0,0)
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _BlurTex;
	sampler2D _CameraDepthTexture;
	uniform float4 _Parame;
	
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
	
	half4 Dof(v2f i) : COLOR0
	{
		half4 tex0 = tex2D(_MainTex, i.uv.xy);
		half4 tex1 = tex2D(_BlurTex, i.uv.xy);
		
		half depth = Linear01Depth(UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv.xy)));
		float z = depth * (_Parame.y - _Parame.x) + _Parame.x;
		float blurFactor = saturate((z - _Parame.z)/_Parame.w);
		return lerp(tex0, tex1, blurFactor);
	}

	
	ENDCG
	
	SubShader {
	  ZTest Always Cull Off ZWrite Off Blend Off
	  Fog { Mode off }  
	  
	Pass { 
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment Dof
		#pragma fragmentoption ARB_precision_hint_fastest 
		ENDCG	 
		}	

	}
}
