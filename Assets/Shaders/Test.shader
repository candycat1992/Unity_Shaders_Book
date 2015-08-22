Shader "MyToon/Toon-Fragment" {  
    Properties {  
        _MainTex ("Base (RGB)", 2D) = "white" {}  
        _Ramp ("Ramp Texture", 2D) = "white" {}  
        _Outline ("Outline", Range(0,1)) = 0.1  
        _QOffset ("Offset", Vector) = (0,0,0,0)
        _Dist ("Distance", Float) = 100.0
    }  
    SubShader {  
        Tags { "RenderType"="Opaque" }  
        LOD 200  
   
        Pass {  
            Tags { "LightMode"="ForwardBase" }  
              
            Cull Front  
            Lighting Off  
            ZWrite On  
   
            CGPROGRAM  
             
            #pragma vertex vert  
            #pragma fragment frag  
             
            #pragma multi_compile_fwdbase  
  
            #include "UnityCG.cginc"  
              
            float _Outline;  
            float4 _QOffset;
            float _Dist;
   
            struct a2v  
            {  
                float4 vertex : POSITION;  
                float3 normal : NORMAL;  
            };   
   
            struct v2f  
            {  
                float4 pos : POSITION;  
            };  
   
            v2f vert (a2v v)  
            {  
                v2f o;  
  
                float4 pos = mul( UNITY_MATRIX_MV, v.vertex);   
                float zOff = pos.z/_Dist;
                pos += _QOffset*zOff*zOff;
                float3 normal = normalize(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                normal.z = -0.5;  
                pos = pos + float4(normalize(normal),0) * _Outline;  
                o.pos = mul(UNITY_MATRIX_P, pos);  
                  
                return o;  
            }  
   
            float4 frag(v2f i) : COLOR    
            {   
                return float4(0, 0, 0, 1);                 
            }   
   
            ENDCG  
        }  
          
        Pass {  
            Tags { "LightMode"="ForwardBase" }  
              
            Cull Back   
            Lighting On  
  
            CGPROGRAM  
 
            #pragma vertex vert  
            #pragma fragment frag  
             
            #pragma multi_compile_fwdbase  
 
            #include "UnityCG.cginc"  
            #include "Lighting.cginc"  
            #include "AutoLight.cginc"  
            #include "UnityShaderVariables.cginc"  
              
  
            sampler2D _MainTex;  
            sampler2D _Ramp;  
            
            float4 _QOffset;
            float _Dist;
  
            float4 _MainTex_ST;  
  
            float _Tooniness;  
   
            struct a2v  
            {  
                float4 vertex : POSITION;  
                float3 normal : NORMAL;  
                float4 texcoord : TEXCOORD0;  
                float4 tangent : TANGENT;  
            };   
  
            struct v2f  
            {  
                float4 pos : POSITION;  
                float2 uv : TEXCOORD0;  
                float3 normal : TEXCOORD1;  
                LIGHTING_COORDS(2,3)  
            };  
              
            v2f vert (a2v v)  
            {  
                v2f o;  
  
                //Transform the vertex to projection space  
                float4 vPos = mul(UNITY_MATRIX_MV, v.vertex);
                float zOff = vPos.z / _Dist;
                vPos += _QOffset*zOff*zOff;
                o.pos = mul(UNITY_MATRIX_P, vPos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = mul((float3x3)_Object2World, SCALED_NORMAL);  
                //Get the UV coordinates  
                  
                // pass lighting information to pixel shader  
                TRANSFER_VERTEX_TO_FRAGMENT(o);  
                return o;  
            }  
              
            float4 frag(v2f i) : COLOR    
            {   
                //Get the color of the pixel from the texture  
                float4 c = tex2D (_MainTex, i.uv);    
                //Merge the colours  
  
                //Based on the ambient light  
                float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;  
  
                //Work out this distance of the light  
                float atten = LIGHT_ATTENUATION(i);  
                //Angle to the light  
                float diff = dot (normalize(i.normal), normalize(_WorldSpaceLightPos0.xyz));    
                diff = diff * 0.5 + 0.5;   
                //Perform our toon light mapping   
                diff = tex2D(_Ramp, float2(diff, 0.5));  
                //Update the colour  
                lightColor += _LightColor0.rgb * (diff * atten);   
                //Product the final color  
                c.rgb = lightColor * c.rgb * 2;  
                return c;   
  
            }   
  
            ENDCG  
        }  
        
        // Pass to render object as a shadow caster
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			float4 _QOffset;
	        float _Dist;
	        
			struct v2f { 
				V2F_SHADOW_CASTER;
			};

			v2f vert( appdata_base v )
			{
				
				v2f o;
				//Transform the vertex to projection space  
	            float4 vPos = mul(UNITY_MATRIX_MV, v.vertex);
	            float zOff = vPos.z / _Dist;
	            vPos += _QOffset*zOff*zOff;
	            o.pos = mul(UNITY_MATRIX_P, vPos);
	                
	            o.pos = UnityApplyLinearShadowBias(o.pos);
	            
				return o;
			}

			float4 frag( v2f i ) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
    }  
    FallBack "Diffuse"        
} 