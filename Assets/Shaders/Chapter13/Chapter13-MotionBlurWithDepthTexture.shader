Shader "Unity Shaders Book/Chapter 13/Motion Blur With Depth Texture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;
		
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};
		
		v2f vert(appdata_img v) {
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = v.texcoord;
			
			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
				uv.y = 1 - uv.y;
			#endif
					 
			return o;
		}
		
		fixed4 frag(v2f i) : SV_Target {
			float zOverW = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, zOverW, 1);
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			float4 worldPos = D / D.w;
			
			float4 currentPos = H;
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			previousPos /= previousPos.w;
			
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;
			
			float2 uv = i.uv;
			float4 color = tex2D(_MainTex, uv);
			uv += velocity * _BlurSize;
			int iterations = 3;
			for (int i = 1; i < iterations; i++, uv += velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				color += currentColor;
			}
			color /= iterations;
			
			return fixed4(color.rgb, 1.0);
		}
		
		ENDCG
        
        Pass {          	
            CGPROGRAM  
            
            #pragma vertex vert  
            #pragma fragment frag  
              
            ENDCG  
        }
	} 
	FallBack "Diffuse"
}
