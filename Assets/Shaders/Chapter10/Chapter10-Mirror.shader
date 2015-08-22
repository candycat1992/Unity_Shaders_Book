Shader "Unity Shader Book/Chapter10/Mirror" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler2D _MainTex;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	
			 	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

			 	o.texcoord = v.texcoord;
			 	// Mirror needs to filp x
			 	o.texcoord.x = 1 - o.texcoord.x;
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float2 uv = i.texcoord;
			 	fixed4 tex = tex2D(_MainTex, uv);
			 	
				return tex;
			}
			
			ENDCG
		}
	} 
 	FallBack Off
}
