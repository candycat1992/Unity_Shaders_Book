Shader "Unity Shaders Book/Chapter 12/Edge Detection Normals And Depth" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Float) = 1.0
		_EdgeColor ("Edge Color", Color) = (0, 0, 0, 1)
		_BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
		_Sensitivity ("Sensitivity", Vector) = (1, 1, 1, 1)
	}
	SubShader {
		CGINCLUDE
		
		#include "UnityCG.cginc"
		
        sampler2D _MainTex;  
        uniform half4 _MainTex_TexelSize;
        fixed _EdgeOnly;
        fixed4 _EdgeColor;
        fixed4 _BackgroundColor;
        half4 _Sensitivity;
    
        sampler2D _CameraDepthNormalsTexture;
        uniform half4 _CameraDepthNormalsTexture_TexelSize;
        
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
        
        half CheckSame(half4 center, half4 sample) {
        	half2 centerNormal = center.xy;
        	float centerDepth = DecodeFloatRG(center.zw);
        	
			// difference in normals
			// do not bother decoding normals - there's no need here
			half2 diffNormal = abs(centerNormal - sample.xy) * _Sensitivity.x;
			int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;
			// difference in depth
			float sampleDepth = DecodeFloatRG(sample.zw);
			float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
			// scale the required threshold by the distance
			int isSameDepth = diffDepth < 0.1 * centerDepth;
		
			// return:
			// 1 - if normals and depth are similar enough
			// 0 - otherwise
			
			return isSameNormal * isSameDepth ? 1.0 : 0.0;
		}	
	
        fixed4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target {
        	half2 uv[4];
        	uv[0] = i.uv + _CameraDepthNormalsTexture_TexelSize.xy * half2(1, 1);
			uv[1] = i.uv + _CameraDepthNormalsTexture_TexelSize.xy * half2(-1, -1);
			uv[2] = i.uv + _CameraDepthNormalsTexture_TexelSize.xy * half2(-1, 1);
			uv[3] = i.uv + _CameraDepthNormalsTexture_TexelSize.xy * half2(1, -1);
        	
        	half4 sample1 = tex2D(_CameraDepthNormalsTexture, uv[0]);
			half4 sample2 = tex2D(_CameraDepthNormalsTexture, uv[1]);
			half4 sample3 = tex2D(_CameraDepthNormalsTexture, uv[2]);
			half4 sample4 = tex2D(_CameraDepthNormalsTexture, uv[3]);

			half edge = 1.0;
			
			edge *= CheckSame(sample1, sample2);
			edge *= CheckSame(sample3, sample4);

			fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv), edge);
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
        }
		
		ENDCG
		
		Pass { 
            CGPROGRAM      
   
            #pragma vertex vert  
            #pragma fragment fragRobertsCrossDepthAndNormal
 
            ENDCG  
        }
	} 
	FallBack "Diffuse"
}
