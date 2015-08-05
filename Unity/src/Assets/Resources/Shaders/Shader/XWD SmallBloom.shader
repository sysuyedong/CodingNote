Shader "XiaoWanDou/SmallBloom" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurTex ("BlurTex (RGB)", 2D) = "white" {}
		_BloomParame ("Bloom Parame", Vector) = (1.0, 0.2, 0.01, 0.01)
		_Weight("Blur Weight", Vector) = (0.5,0.5,0,0)
		_MaskTex ("Mask (RGB)", 2D) = "white" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	sampler2D _MainTex;
	sampler2D _BlurTex;
	sampler2D _MaskTex;
	uniform float4 _BloomParame;
	uniform fixed4 _Weight;

	float2 Circle(float Start, float Points, float Point) 
	{
		float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
		return float2(sin(Rad), cos(Rad));
	}
	
	struct v1f
	{
		float4 pos : SV_POSITION;
		float4 uv[8]: TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv[7]: TEXCOORD0;
	};

	struct v3f
	{
		float4 pos : SV_POSITION;
		float2 uv: TEXCOORD0;
	};
	
	v1f BloomSmallVS(appdata_base v)
	{
		v1f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		float Start = 2.0/14.0;
		//float Scale = 0.66 * 4.0 * 2.0;

		o.uv[0].xy = v.texcoord.xy;
		o.uv[0].zw = v.texcoord.xy + Circle(Start, 14.0, 0.0) * _BloomParame.zw;
		o.uv[1].xy = v.texcoord.xy + Circle(Start, 14.0, 1.0)  * _BloomParame.zw;
		o.uv[1].zw = v.texcoord.xy + Circle(Start, 14.0, 2.0)  * _BloomParame.zw;
		o.uv[2].xy = v.texcoord.xy + Circle(Start, 14.0, 3.0)  * _BloomParame.zw;
		o.uv[2].zw = v.texcoord.xy + Circle(Start, 14.0, 4.0)  * _BloomParame.zw;
		o.uv[3].xy = v.texcoord.xy + Circle(Start, 14.0, 5.0)  * _BloomParame.zw;
		o.uv[3].zw = v.texcoord.xy + Circle(Start, 14.0, 6.0)  * _BloomParame.zw;
		o.uv[4].xy = v.texcoord.xy + Circle(Start, 14.0, 7.0)  * _BloomParame.zw;
		o.uv[4].zw = v.texcoord.xy + Circle(Start, 14.0, 8.0)  * _BloomParame.zw;
		o.uv[5].xy = v.texcoord.xy + Circle(Start, 14.0, 9.0)  * _BloomParame.zw;
		o.uv[5].zw = v.texcoord.xy + Circle(Start, 14.0, 10.0)  * _BloomParame.zw;
		o.uv[6].xy = v.texcoord.xy + Circle(Start, 14.0, 11.0)  * _BloomParame.zw;
		o.uv[6].zw = v.texcoord.xy + Circle(Start, 14.0, 12.0)  * _BloomParame.zw;
		o.uv[7].xy = v.texcoord.xy + Circle(Start, 14.0, 13.0)  * _BloomParame.zw;
		o.uv[7].zw = float2(0.0, 0.0);

    	return o;
	}
	
	half4 BloomSmallPS(v1f i) : COLOR0
	{
		half4 OutColor = tex2D(_MainTex, i.uv[0].xy);
		OutColor += tex2D(_MainTex, i.uv[0].zw);
		OutColor += tex2D(_MainTex, i.uv[1].xy);
		OutColor += tex2D(_MainTex, i.uv[1].zw);
		OutColor += tex2D(_MainTex, i.uv[2].xy);
		OutColor += tex2D(_MainTex, i.uv[2].zw);
		OutColor += tex2D(_MainTex, i.uv[3].xy);
		OutColor += tex2D(_MainTex, i.uv[3].zw);
		OutColor += tex2D(_MainTex, i.uv[4].xy);
		OutColor += tex2D(_MainTex, i.uv[4].zw);
		OutColor += tex2D(_MainTex, i.uv[5].xy);
		OutColor += tex2D(_MainTex, i.uv[5].zw);
		OutColor += tex2D(_MainTex, i.uv[6].xy);
		OutColor += tex2D(_MainTex, i.uv[6].zw);
		OutColor += tex2D(_MainTex, i.uv[7].xy);

		OutColor /= 15.0;

		half BloomLuminance = dot(OutColor.rgb, half3(0.3, 0.59, 0.11)) - _BloomParame.y;
		half Amount = saturate(BloomLuminance * 0.5f);
		OutColor.rgb *= Amount;

		return OutColor;
	}

	half4 BloomDownPS(v1f i) : COLOR0
	{
		half4 OutColor = tex2D(_MainTex, i.uv[0].xy);
		OutColor += tex2D(_MainTex, i.uv[0].zw);
		OutColor += tex2D(_MainTex, i.uv[1].xy);
		OutColor += tex2D(_MainTex, i.uv[1].zw);
		OutColor += tex2D(_MainTex, i.uv[2].xy);
		OutColor += tex2D(_MainTex, i.uv[2].zw);
		OutColor += tex2D(_MainTex, i.uv[3].xy);
		OutColor += tex2D(_MainTex, i.uv[3].zw);
		OutColor += tex2D(_MainTex, i.uv[4].xy);
		OutColor += tex2D(_MainTex, i.uv[4].zw);
		OutColor += tex2D(_MainTex, i.uv[5].xy);
		OutColor += tex2D(_MainTex, i.uv[5].zw);
		OutColor += tex2D(_MainTex, i.uv[6].xy);
		OutColor += tex2D(_MainTex, i.uv[6].zw);
		OutColor += tex2D(_MainTex, i.uv[7].xy);

		OutColor /= 15.0;
		OutColor.a = 1.0f;

		return OutColor;
	}


	v2f BloomMergeSmallVS(appdata_base v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

		float Start = 2.0/6.0;

		o.uv[0] = v.texcoord.xy + Circle(Start, 6.0, 0.0)  * _BloomParame.zw;
		o.uv[1] = v.texcoord.xy + Circle(Start, 6.0, 1.0)  * _BloomParame.zw;
		o.uv[2] = v.texcoord.xy + Circle(Start, 6.0, 2.0)  * _BloomParame.zw;
		o.uv[3] = v.texcoord.xy + Circle(Start, 6.0, 3.0)  * _BloomParame.zw;
		o.uv[4] = v.texcoord.xy + Circle(Start, 6.0, 4.0)  * _BloomParame.zw;
		o.uv[5] = v.texcoord.xy + Circle(Start, 6.0, 5.0)  * _BloomParame.zw;
		o.uv[6] = v.texcoord.xy;

    	return o;
	}

	half4 BloomMergeSmallPS(v2f i) : COLOR0
	{
		half3 Bloom1 = tex2D(_MainTex, i.uv[6].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[0].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[1].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[2].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[3].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[4].xy).rgb;
		Bloom1 += tex2D(_MainTex, i.uv[5].xy).rgb;
		Bloom1 /= 7.0f;

		half4 OutColor = 0.0;
		OutColor.rgb = tex2D(_BlurTex, i.uv[6].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[0].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[1].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[2].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[3].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[4].xy).rgb;
		OutColor.rgb += tex2D(_BlurTex, i.uv[5].xy).rgb;
		OutColor.rgb /= 7.0;

		OutColor.rgb *= (0.5 * _BloomParame.x);
		OutColor.rgb += Bloom1 * _BloomParame.x;

		OutColor.rgb *= 2.0 / 3.0;
		OutColor.a = 1.0;

		return OutColor;
	}



	v3f BloomVP(appdata_base v)
	{
		v3f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = v.texcoord.xy;
    	
    	return o;
	}

	half4 BloomFP(v3f i) : COLOR0
	{
		half4 tex0 = tex2D(_MainTex, i.uv.xy);
		half4 tex1 = tex2D(_BlurTex, i.uv.xy);
		return tex0*_Weight.x + tex1 * _Weight.y;
	}
	
	
	ENDCG
	
	SubShader {
	  ZTest Always Cull Off ZWrite Off Blend Off
	  Fog { Mode off }  
	  
	Pass {
		CGPROGRAM
		
		#pragma vertex BloomSmallVS
		#pragma fragment BloomSmallPS
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG
		}

	Pass { 
		CGPROGRAM
		
		#pragma vertex BloomSmallVS
		#pragma fragment BloomDownPS
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG	 
		}

	Pass { 
		CGPROGRAM
		
		#pragma vertex BloomMergeSmallVS
		#pragma fragment BloomMergeSmallPS
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG	 
		}

	Pass { 
		CGPROGRAM
		
		#pragma vertex BloomVP
		#pragma fragment BloomFP
		#pragma fragmentoption ARB_precision_hint_fastest 
		#pragma target 3.0
		ENDCG	 
		}
	}
}
