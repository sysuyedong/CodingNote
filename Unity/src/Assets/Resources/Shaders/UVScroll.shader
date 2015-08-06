Shader "Custom/UVScroll" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_ScrollSpeedX ("Scroll Speed X", Float) = 0
		_ScrollSpeedY ("Scroll Speed Y", Float) = 0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _MainTex;
		float _ScrollSpeedX;
		float _ScrollSpeedY;

		struct Input {
			float2 uv_MainTex;
			float3 worldRefl;
		};

		//UV滚动
		void surf (Input IN, inout SurfaceOutput o) {
			float scrollU = _ScrollSpeedX * _Time;
			float scrollV = _ScrollSpeedY * _Time;
			float2 scrollUV = IN.uv_MainTex + float2(scrollU, scrollV);

			half4 tex = tex2D(_MainTex, scrollUV);

			o.Albedo = tex.rgb;
			o.Alpha = tex.a;
		}
		
		ENDCG
	} 
	FallBack "Diffuse"
}
