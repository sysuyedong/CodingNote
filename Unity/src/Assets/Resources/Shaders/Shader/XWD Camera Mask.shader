Shader "XiaoWanDou/Camera Mask" {
Properties {
	_MainTex ("Mask Texture", 2D) = "white" {}
	_Color ("Color", Color) = (1,1,1,1)
}

Category {
	Tags { "Queue"="Overlay+1"}
	ZTest Always
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Off 
	Lighting Off 
	ZWrite Off
	Fog { Mode off }
	
	BindChannels {
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	SubShader {
		Pass {
			SetTexture[_MainTex]{
			    ConstantColor[_Color]
				combine texture * Constant
			}
			
		}
	}
}
}
