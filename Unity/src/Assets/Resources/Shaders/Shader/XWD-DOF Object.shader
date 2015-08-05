
Shader "XiaoWanDou/Dof Object" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
	Tags {"Queue"="Background+1" "RenderType"="Transparent"}
	Blend SrcAlpha OneMinusSrcAlpha 
	LOD 200
	
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
				float4 texcoord[3] : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.texcoord[0].xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord[0].z = o.vertex.z * _ProjectionParams.w;
				o.texcoord[1].xy = o.texcoord[0].xy + float2(0.005, 0.005);
				o.texcoord[1].zw = o.texcoord[0].xy + float2(0.005, -0.005);
				o.texcoord[2].xy = o.texcoord[0].xy + float2(-0.005, 0.005);
				o.texcoord[2].zw = o.texcoord[0].xy + float2(-0.005, -0.005);
				return o;
			}
			
			half4 frag (v2f i) : COLOR
			{
				half4 col = tex2D(_MainTex, i.texcoord[0].xy);
				half4 sum = tex2D(_MainTex, i.texcoord[1].xy);
				sum += tex2D(_MainTex, i.texcoord[1].zw);
				sum += tex2D(_MainTex, i.texcoord[2].xy);
				sum += tex2D(_MainTex, i.texcoord[2].zw);

				col.rgb = col.rgb * (1 - i.texcoord[0].z) + sum * i.texcoord[0].z;

				return col;
			}
		ENDCG
	}
}

}
