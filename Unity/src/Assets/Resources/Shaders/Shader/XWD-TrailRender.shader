// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "XiaoWanDou/TrailRender" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Brightness("Brightness", float) = 1.5
}

SubShader {
	Tags {"Queue"="Transparent+20" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	Blend SrcAlpha One
	Cull Off 
	Lighting Off 
	ZWrite Off 

	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D _MainTex;
			float _Brightness;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord = v.texcoord;
				o.color = v.color;
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.texcoord) * i.color;
				return col * _Brightness;
			}
		ENDCG
	}
}

}
