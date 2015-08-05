// Unlit shader. Simplest possible textured shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "XiaoWanDou/FadeOut" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Amount ("Amount", Range (0, 1)) = 0.5
}

SubShader {
	//Tags { "RenderType"="Opaque" }
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	Blend SrcAlpha OneMinusSrcAlpha 
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _Amount;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				float alpha = 1 - _Amount;

				if (alpha < 0)
				{
					alpha = 0;
				}

				fixed4 col = tex2D(_MainTex, i.texcoord);
				col.a = alpha;
				return col;
			}
		ENDCG
	}
}

}
