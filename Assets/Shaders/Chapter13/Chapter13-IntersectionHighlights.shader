Shader "Unity Shaders Book/Chapter 13/Intersection Highlights" {
	Properties {
		_MainColor ("Main Color", Color) = (1, 1, 1, 0.5)
		_HighlightColor ("Highlight Color", Color) = (1, 1, 1, 0.8)
		_HighlightWidth ("Highlight Width", Range(0.01, 1)) = 1.0
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off
			
			CGPROGRAM
			
			#pragma vertex vert  
            #pragma fragment frag
		
			#include "UnityCG.cginc"
				        
	        sampler2D _CameraDepthTexture;
	        fixed4 _MainColor;
	        fixed4 _HighlightColor;
	        float _HighlightWidth;
	        
	        struct v2f {
	        	float4 pos : SV_POSITION;
	        	float4 scrPos : TEXCOORD0;
	        };
	          
	        v2f vert(appdata_img v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
						 
				return o;
			}
		
	        fixed4 frag(v2f i) : SV_Target {
	        	float scrDepth = Linear01Depth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.scrPos));
	        	float ownDepth = Linear01Depth(i.scrPos.z/i.scrPos.w);
	        	
	        	float diff = abs(scrDepth - ownDepth)/_HighlightWidth;
	        	
	        	fixed4 finalColor = _MainColor;
	        	if (diff < 1) {
	        		finalColor = lerp(_HighlightColor, finalColor, pow(diff, 200));
	        	}
	        	
	        	return finalColor;
	        }
			
			ENDCG 
        }
	} 
	FallBack "Transparent/VertexLit"
}
