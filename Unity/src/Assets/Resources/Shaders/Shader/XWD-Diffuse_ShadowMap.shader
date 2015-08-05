Shader "XiaoWanDou/Diffuse_SM" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_myShadow ("Shadow Map", 2D) = "white" {}
		_cameraFar ("CameraFar", Float) = 0
		_shadowValue ("ShadowValue", Float) = 0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}
		LOD 200

		CGPROGRAM
		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;
		sampler2D _myShadow;
		
		fixed4 _Color;
		float4x4 _litMVP;
		
		float _cameraFar;
		
		fixed _shadowValue;

		struct Input 
		{
			float2 uv_MainTex;
			float4 litPos;
		};

		void vert (inout appdata_full v, out Input o) 
		{
			//float4 wVertex = mul(_Object2World, v.vertex);
		    o.litPos = mul(_litMVP, v.vertex);
		}


		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed2 ShadowTexC = 0.5 * IN.litPos.xy / IN.litPos.w + float2(0.5,0.5);
			fixed scene_direct = IN.litPos.z / _cameraFar;
			
			fixed role_direct = tex2D( _myShadow, ShadowTexC );
			
			fixed LightAmount = (role_direct < scene_direct) ? _shadowValue : 1.0f;
			
			//float LightAmount1 = (role_direct > 0 ) ? 0.0f: 1.0f;
			
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb * LightAmount;
			o.Alpha = c.a;
		}
		
		ENDCG
	}

}
