Shader "Unity Shaders Book/Chapter 11/Scrolling Sky" {
	Properties {
		_MainTex ("Base layer (RGB)", 2D) = "white" {}
		_DetailTex ("2nd layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll speed X", Float) = 1.0
		_ScrollY ("Base layer Scroll speed Y", Float) = 0.0
		_Scroll2X ("2nd layer Scroll speed X", Float) = 1.0
		_Scroll2Y ("2nd layer Scroll speed Y", Float) = 0.0
		_AMultiplier ("Layer Multiplier", Float) = 0.5
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			Cull Off
		
			CGPROGRAM
			
			// Apparently need to add this declaration 
            #pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			sampler2D _DetailTex;

			float4 _MainTex_ST;
			float4 _DetailTex_ST;
			
			float _ScrollX;
			float _ScrollY;
			float _Scroll2X;
			float _Scroll2Y;
			float _AMultiplier;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};
			
			v2f vert (a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex) + frac(float2(_ScrollX, _ScrollY) * _Time);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_DetailTex) + frac(float2(_Scroll2X, _Scroll2Y) * _Time);
				o.color = fixed4(_AMultiplier, _AMultiplier, _AMultiplier, _AMultiplier);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target {
				fixed4 o;
				fixed4 tex = tex2D (_MainTex, i.uv.xy);
				fixed4 tex2 = tex2D (_DetailTex, i.uv.zw);
				
				o = (tex * tex2) * i.color;
				
				return o;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
