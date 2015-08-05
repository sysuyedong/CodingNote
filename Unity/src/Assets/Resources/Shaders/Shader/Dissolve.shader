Shader "XiaoWanDou/Dissolve" 
{
	Properties 
	{
		//_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_Amount ("Amount", Range (0, 1)) = 0.5
		_StartAmount("StartAmount", float) = 0.1
		_Illuminate ("Illuminate", Range (0, 1)) = 0.5
		_Tile("Tile", float) = 1
		_DissColor ("DissColor", Color) = (1,1,1,1)
		_ColorAnimate ("ColorAnimate", vector) = (1,1,1,1)
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
		_DissolveSrc ("DissolveSrc", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 400
		cull off
			
		
Pass { 
		CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members scrPos)
#pragma exclude_renderers d3d11 xbox360

		#pragma vertex vert
		#pragma fragment frag
			
		#include "UnityCG.cginc"



		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _DissolveSrc;
		float4 _DissolveSrc_ST;

		//fixed4 _Color;
		half4 _DissColor;
		half _Shininess;
		half _Amount;
		static half3 Color = float3(1,1,1);
		half4 _ColorAnimate;
		half _Illuminate;
		half _Tile;
		half _StartAmount;



		struct appdata_t {
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
		};

		struct v2f {
			
			float4 pos : SV_POSITION;
			half2 texcoord : TEXCOORD0;
			float4 scrPos;
		};


		v2f vert (appdata_t v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.scrPos = ComputeScreenPos(o.pos);
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}
			
		fixed4 frag (v2f i) : COLOR
		{
			fixed4 col = tex2D(_MainTex, i.texcoord);// * _Color.rgb;
			
			float ClipTex = tex2D (_DissolveSrc, i.texcoord/_Tile).r ;
			//float ClipTex = tex2D (_MainTex, float2(i.scrPos.x,i.scrPos.y)/_Tile).r * tex2D (_MainTex, float2(i.scrPos.y,i.scrPos.z)/_Tile).g;

			float ClipAmount = ClipTex - _Amount;
			float Clip = 0;
			if (_Amount > 0)
			{
				if (ClipAmount <0)
				{
					Clip = 1; //clip(-0.1);
				}
				else
				{
					if (ClipAmount < _StartAmount)
					{
						if (_ColorAnimate.x == 0)
							Color.x = _DissColor.x;
						else
							Color.x = ClipAmount/_StartAmount;
			          
						if (_ColorAnimate.y == 0)
							Color.y = _DissColor.y;
						else
							Color.y = ClipAmount/_StartAmount;
			          
						if (_ColorAnimate.z == 0)
							Color.z = _DissColor.z;
						else
							Color.z = ClipAmount/_StartAmount;

						col.rgb  = (col.rgb *((Color.x+Color.y+Color.z))* Color*((Color.x+Color.y+Color.z)))/(1 - _Illuminate);
					}
			 	}
		 	}
		 	
			
			if (Clip == 1)
			{
				clip(-0.1);
			}
			//////////////////////////////////
			//

			col.a = col.a;// * _Color.a;
			return col;
		}
		
		ENDCG
}
	}

FallBack "XiaoWanDou/Dissolve"
}
