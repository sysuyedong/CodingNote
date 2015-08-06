Shader "Custom/BasicDiffuse" {
	Properties {
		_EmissiveColor ("Emissive Color", Color) = (1, 1, 1, 1)
		_AmbientColor ("Ambient Color", Color) = (1, 1, 1, 1)
		_Power("Power", Range(0, 10)) = 2.5
		_RampTex ("Ramp", 2D) = "white" {}
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Brdf

		float4 _EmissiveColor;
		float4 _AmbientColor;
		float _Power;
		sampler2D _RampTex;
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldRefl;
		};

		//自发光和环境光
		void surf (Input IN, inout SurfaceOutput o) {
			// float4 c;
			// c = pow((_EmissiveColor + _AmbientColor), _Power);

			// o.Albedo = c.rgb;
			// o.Alpha = c.a;

			half4 tex = tex2D(_MainTex, IN.uv_MainTex);

			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
		}

		inline float4 LightingBasicDiffuse(SurfaceOutput s, fixed3 lightDir, fixed atten) {
			float dirLight = max(0, dot(s.Normal, lightDir));
			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * (dirLight * atten * 2);
			col.a = s.Alpha;
			return col;
		}

		//半兰伯特光照模型
		inline float4 LightingHalfLambert(SurfaceOutput s, fixed3 lightDir, fixed atten) {
			float dirLight = max(0, dot(s.Normal, lightDir));
			float halfLambert = dirLight * 0.5 + 0.5;

			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * (halfLambert * atten * 2);
			col.a = s.Alpha;
			return col;
		}

		//渐变纹理控制漫反射着色
		inline float4 LightingRamp(SurfaceOutput s, fixed3 lightDir, fixed atten) {
			float dirLight = max(0, dot(s.Normal, lightDir));
			float halfLambert = dirLight * 0.5 + 0.5;
			float3 ramp = tex2D(_RampTex, float2(halfLambert, halfLambert)).rgb;
			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * ramp;
			col.a = s.Alpha;
			return col;
		}

		//BRDF
		inline float4 LightingBrdf(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
			float dirLight = max(0, dot(s.Normal, lightDir));
			float rimLight = dot(s.Normal, viewDir);
			float halfLambert = dirLight * 0.5 + 0.5;
			float3 ramp = tex2D(_RampTex, float2(halfLambert, rimLight)).rgb;
			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * ramp;
			col.a = s.Alpha;
			return col;
		}

		ENDCG
	} 
	FallBack "Diffuse"
}
