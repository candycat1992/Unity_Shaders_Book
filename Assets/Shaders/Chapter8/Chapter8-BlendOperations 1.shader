// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 8/Blend Operations 1" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			
//			// Normal
//			Blend SrcAlpha OneMinusSrcAlpha
//			
//			// Soft Additive
//			Blend OneMinusDstColor One
//			
//			// Multiply
			Blend DstColor Zero
//			
//			// 2x Multiply
//			Blend DstColor SrcColor
//			
//			// Darken
//			BlendOp Min
//			Blend One One	// When using Min operation, these factors are ignored
//			
//			//  Lighten
//			BlendOp Max
//			Blend One One // When using Max operation, these factors are ignored
//			
//			// Screen
//			Blend OneMinusDstColor One
			// Or
//			Blend One OneMinusSrcColor
//			
//			// Linear Dodge
			Blend One One
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _AlphaScale;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = UnityObjectToClipPos(v.vertex);

			 	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {				
				fixed4 texColor = tex2D(_MainTex, i.uv);
			 	
				return fixed4(texColor.rgb * _Color.rgb, texColor.a * _AlphaScale);
			}
			
			ENDCG
		}
	} 
	FallBack "Transparent/VertexLit"
}
