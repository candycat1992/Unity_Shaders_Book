Shader "Unity Shaders Book/Chapter 12/Bloom" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom (RGB)", 2D) = "black" {}
		_LuminanceThreshold ("Luminance Threshold", Float) = 0.5
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		uniform half4 _MainTex_TexelSize;
		sampler2D _Bloom;
		float _LuminanceThreshold;
		float _BlurSize;
		
		fixed luminance(fixed4 color) {
 			return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
		}
		
		fixed4 fragExtractBright(v2f_img i) : SV_Target {
			fixed4 c = tex2D(_MainTex, i.uv);
			fixed val = clamp(luminance(c) - _LuminanceThreshold, 0.0, 1.0);
			return c * val;
		}
		
		struct v2f {
			float4 pos : SV_POSITION; 
			half4 uv : TEXCOORD0;
		};	
		
		v2f vertBloom(appdata_img v) {
			v2f o;
			
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
        	o.uv.xy = v.texcoord;		
        	o.uv.zw = v.texcoord;
        	
        #if UNITY_UV_STARTS_AT_TOP			
        	if (_MainTex_TexelSize.y < 0.0)
        		o.uv.w = 1.0 - o.uv.w;
        #endif
        	        	
			return o; 
		}
		
		fixed4 fragBloom(v2f i) : SV_Target {	
        	#if UNITY_UV_STARTS_AT_TOP
			
			fixed4 color = tex2D(_MainTex, i.uv.zw);
			return color + tex2D(_Bloom, i.uv.xy);
			
			#else

			fixed4 color = tex2D(_MainTex, i.uv.zw);
			return color + tex2D(_Bloom, i.uv.xy);
						
			#endif
		} 
		
		ENDCG
		
		Pass {  
            CGPROGRAM  
            #pragma vertex vert_img  
            #pragma fragment fragExtractBright  
   
            ENDCG  
        }
        
        UsePass "Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"
        
        UsePass "Unity Shaders Book/Chapter 12/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"
        
        Pass {  
            CGPROGRAM  
            #pragma vertex vertBloom  
            #pragma fragment fragBloom  
   
            ENDCG  
        }
	} 
	FallBack "Diffuse"
}
