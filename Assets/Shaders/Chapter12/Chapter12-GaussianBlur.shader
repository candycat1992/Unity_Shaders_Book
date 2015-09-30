Shader "Unity Shaders Book/Chapter 12/Gaussian Blur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0
	}
	SubShader {
		CGINCLUDE
		
		ENDCG
		
		Pass {
			NAME "GAUSSIAN_BLUR_VERTICAL"
			
            CGPROGRAM  
            #pragma vertex vert_img  
            #pragma fragment fragBlurVertical  
              
            #include "UnityCG.cginc"  
              
            sampler2D _MainTex;  
            uniform half4 _MainTex_TexelSize;
            float _BlurSize;
              
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
              
            ENDCG  
        }
        
        Pass {  
        	NAME "GAUSSIAN_BLUR_HORIZONTAL"
        	
            CGPROGRAM  
            #pragma vertex vert_img  
            #pragma fragment fragBlurHorizontal  
              
            #include "UnityCG.cginc"  
              
            sampler2D _MainTex;  
            uniform half4 _MainTex_TexelSize;
            float _BlurSize;
              
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
        }
	} 
	FallBack "Diffuse"
}
