Shader "Unity Shaders Book/Chapter 12/Gaussian Blur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;  
        uniform half4 _MainTex_TexelSize;
        float _BlurSize;
          
        struct v2f {
        	float4 pos : SV_POSITION;
        	half2 uv: TEXCOORD0;
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
		
        fixed4 fragBlurVertical(v2f_img i) : SV_Target {
         	float pixelOffset[3] = {0.0, 1.0, 2.0};
			float weight[3] = {0.4026, 0.2442, 0.0545};
		
			float2 uv = i.uv;
            fixed3 sum = tex2D(_MainTex, uv).rgb * weight[0];
			
            for (int i = 1; i < 3; i++) {
            	sum += tex2D(_MainTex, uv + float2(0.0, _MainTex_TexelSize.y * pixelOffset[i]) * _BlurSize).rgb * weight[i];
            	sum += tex2D(_MainTex, uv - float2(0.0, _MainTex_TexelSize.y * pixelOffset[i]) * _BlurSize).rgb * weight[i];
            }
            
            return fixed4(sum, 1.0);
        }
        
        fixed4 fragBlurHorizontal(v2f_img i) : SV_Target {
         	float pixelOffset[3] = {0.0, 1.0, 2.0};
			float weight[3] = {0.4026, 0.2442, 0.0545};
		
			float2 uv = i.uv;
            fixed3 sum = tex2D(_MainTex, uv).rgb * weight[0];
			
            for (int i = 1; i < 3; i++) {
            	sum += tex2D(_MainTex, uv + float2( _MainTex_TexelSize.y * pixelOffset[i], 0.0) * _BlurSize).rgb * weight[i];
            	sum += tex2D(_MainTex, uv - float2(_MainTex_TexelSize.y * pixelOffset[i], 0.0) * _BlurSize).rgb * weight[i];
            }
            
            return fixed4(sum, 1.0);
        } 
            
		ENDCG
		
		Pass {
			NAME "GAUSSIAN_BLUR_VERTICAL"
			
            CGPROGRAM
              
            #pragma vertex vert  
            #pragma fragment fragBlurVertical  
              
            ENDCG  
        }
        
        Pass {  
        	NAME "GAUSSIAN_BLUR_HORIZONTAL"
        	
            CGPROGRAM  
            
            #pragma vertex vert  
            #pragma fragment fragBlurHorizontal  

            ENDCG  
        }
	} 
	FallBack "Diffuse"
}
