Shader "Unity Shaders Book/Chapter 12/Edge Detection" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
        sampler2D _MainTex;  
        uniform half4 _MainTex_TexelSize;
        fixed _EdgeOnly;
        fixed4 _BackgroundColor;
        
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
		
		fixed luminance(fixed4 color) {
 			return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
		}
		
        half Sobel(v2f i) {
        	const half Gx[9] = {-1, -2, -1,
        						   0,  0,  0,
        						   1,  2,  1};
        	const half Gy[9] = {-1,  0,  1,
        						 -2,  0,  2,
        						 -1,  0,  1};		

			half2 uv[9];
			uv[0] = i.uv + _MainTex_TexelSize.xy * half2(-1, -1);
			uv[1] = i.uv + _MainTex_TexelSize.xy * half2(0, -1);
			uv[2] = i.uv + _MainTex_TexelSize.xy * half2(1, -1);
			uv[3] = i.uv + _MainTex_TexelSize.xy * half2(-1, 0);
			uv[4] = i.uv + _MainTex_TexelSize.xy * half2(0, 0);
			uv[5] = i.uv + _MainTex_TexelSize.xy * half2(1, 0);
			uv[6] = i.uv + _MainTex_TexelSize.xy * half2(-1, 1);
			uv[7] = i.uv + _MainTex_TexelSize.xy * half2(0, 1);
			uv[8] = i.uv + _MainTex_TexelSize.xy * half2(1, 1);
			
			// Dark edge
			half texColor;
			half edgeX = 0;
			half edgeY = 0;
			for (int i = 0; i < 9; i++) {
				texColor = luminance(tex2D(_MainTex, uv[i]));
				edgeX += texColor * Gx[i];
				edgeY += texColor * Gy[i];
			}
			
			half edge = 1 - sqrt(edgeX * edgeX + edgeY * edgeY);
			// Or replay with this line for optimization
//			half edge = 1 - abs(edgeX) - abs(edgeY);
	
			return edge;
        }
        
        fixed4 fragSobel(v2f i) : SV_Target {
        	half edge = Sobel(i);
        	return edge * lerp(tex2D(_MainTex, i.uv), _BackgroundColor, _EdgeOnly);
        }
		
		ENDCG
        
        Pass {  
            CGPROGRAM  

            #pragma vertex vert  
            #pragma fragment fragSobel
            
            ENDCG  
        } 
	} 
	FallBack "Diffuse"
}
