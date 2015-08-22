Shader "shadertoy/template" { 
	Properties{
		iMouse ("Mouse Pos", Vector) = (100,100,0,0)
		iChannel0("iChannel0", 2D) = "white" {}  
		iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
	}
	  
	CGINCLUDE    
	 	#include "UnityCG.cginc"   
  		#pragma target 3.0      

  		#define vec2 float2
  		#define vec3 float3
  		#define vec4 float4
  		#define mat2 float2x2
  		#define iGlobalTime _Time.y
  		#define mod fmod
  		#define mix lerp
  		#define atan atan2
  		#define fract frac 
  		#define texture2D tex2D
  		// 屏幕的尺寸
  		#define iResolution _ScreenParams
  		// 屏幕中的坐标，以pixel为单位
  		#define gl_FragCoord ((_iParam.scrPos.xy/_iParam.scrPos.w)*_ScreenParams.xy) 
  		
  		#define PI2 6.28318530718
  		#define pi 3.14159265358979
  		#define halfpi (pi * 0.5)
  		#define oneoverpi (1.0 / pi)
  		
  		fixed4 iMouse;
  		sampler2D iChannel0;
  		fixed4 iChannelResolution0;
  		
        struct v2f {    
            float4 pos : SV_POSITION;    
            float4 scrPos : TEXCOORD0;   
        };              
        
        v2f vert(appdata_base v) {  
        	v2f o;
        	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
            o.scrPos = ComputeScreenPos(o.pos);  
            return o;    
        }  
        
        vec4 main(vec2 fragCoord);
        
        fixed4 frag(v2f _iParam) : COLOR0 { 
        	vec2 fragCoord = gl_FragCoord;
        	return main(gl_FragCoord);
        }  
        
        
		vec4 main(vec2 fragCoord) {
			return vec4(1,1,1,1);
		}

    ENDCG    
  
    SubShader {    
        Pass {    
            CGPROGRAM    
  
            #pragma vertex vert    
            #pragma fragment frag    
            #pragma fragmentoption ARB_precision_hint_fastest     
  
            ENDCG    
        }    
    }     
    FallBack Off    
}
