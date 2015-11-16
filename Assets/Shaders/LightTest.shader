Shader "Light Test" {
    Properties {
        _Color ("Color", color) = (1.0,1.0,1.0,1.0)
    }
    SubShader {
    	Tags { "RenderType"="Opaque"}
    	
        Pass {
            Tags { "LightMode"="ForwardBase"}	// pass for 4 vertex lights, ambient light & first pixel light (directional light)
            
            CGPROGRAM
            // Apparently need to add this declaration 
            #pragma multi_compile_fwdbase	
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
			#include "AutoLight.cginc"
             
            float4 _Color;
             
            struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
         	struct v2f {
            	float4 pos : SV_POSITION;
            	float4 worldPosition : TEXCOORD0;
            	float3 worldNormal : TEXCOORD1;
            	float3 worldLightDir : TEXCOORD2;
            	float3 worldViewDir : TEXCOORD3;
            	float3 vertexLighting : TEXCOORD4;
            	LIGHTING_COORDS(5, 6)
         	};
			
            v2f vert(a2v v) {
                v2f o;
                
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
               	o.worldPosition = mul(_Object2World, v.vertex);
                o.worldNormal =  UnityObjectToWorldNormal(v.normal);
				o.worldLightDir = WorldSpaceLightDir(v.vertex);
				o.worldViewDir = WorldSpaceViewDir(v.vertex);
				o.vertexLighting = float3(0.0);
				
				 // SH/ambient and vertex lights
  				#ifdef LIGHTMAP_OFF
				float3 shLight = ShadeSH9 (float4(o.worldNormal, 1.0));
				o.vertexLighting = shLight;
				#ifdef VERTEXLIGHT_ON
				float3 vertexLight = Shade4PointLights (
					unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
				    unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
				    unity_4LightAtten0, o.worldPosition, o.worldNormal);
				o.vertexLighting += vertexLight;
				#endif // VERTEXLIGHT_ON
  				#endif // LIGHTMAP_OFF
				
				// pass lighting information to pixel shader
  				TRANSFER_VERTEX_TO_FRAGMENT(o);
  
                return o;
            }
             
            float4 frag(v2f i) : SV_Target {
                float3 worldNormal= normalize(i.worldNormal); 
            	float3 worldViewDir= normalize(UnityWorldSpaceViewDir(i.worldPosition));
            	float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
            	 // Compare to directions computed from vertex
//				worldViewDirection = normalize(i.worldViewDir);
//				worldLightDirection = normalize(i.worldLightDir);
            	
            	// LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
           		float atten = LIGHT_ATTENUATION(i);

                // Because SH lights contain ambient, we don't need to add it to the final result
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                 
                float3 diffuse = atten * _LightColor0.rgb * _Color.rgb * max(0.0, dot(worldNormal, worldLightDir));
                
                float3 specular = atten * _LightColor0.rgb * _Color.rgb * pow(max(0.0, dot(reflect(-worldLightDir, worldNormal), worldViewDir)), 255);
                
                return float4(i.vertexLighting +  diffuse + specular, 1.0);  
            }               
            ENDCG
        }
        
        Pass{
            Tags { "LightMode"="ForwardAdd"}		// pass for additional light sources
            ZWrite Off
            Blend One One	// additive blending
            
            CGPROGRAM
            // Apparently need to add this declaration
            #pragma multi_compile_fwdadd
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
			#include "AutoLight.cginc"
             
            uniform float4 _Color;
             
            struct a2v {
            	float4 vertex : POSITION;
            	float3 normal : NORMAL;
         	};
         	
         	struct v2f {
            	float4 pos : SV_POSITION;
            	float4 worldPosition : TEXCOORD0;
            	float3 worldNormal : TEXCOORD1;
            	float3 worldLightDir : TEXCOORD2;
            	float3 worldViewDir : TEXCOORD3;
            	LIGHTING_COORDS(4, 5)
         	};
             
            v2f vert(a2v v) {
                v2f o;
                
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
               	o.worldPosition = mul(_Object2World, v.vertex);
                o.worldNormal =  UnityObjectToWorldNormal(v.normal);
				o.worldLightDir = WorldSpaceLightDir(v.vertex);
				o.worldViewDir = WorldSpaceViewDir(v.vertex);
				
				// pass lighting information to pixel shader
  				TRANSFER_VERTEX_TO_FRAGMENT(o);
  
                return o;
            }
             
            float4 frag(v2f i):COLOR{
                float3 worldNormal = normalize(i.worldNormal); 
            	float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
            	float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
 
            	// LIGHT_ATTENUATION not only compute attenuation, but also shadow infos
           		float atten = LIGHT_ATTENUATION(i);

                // Because SH lights contain ambient, we don't need to add it to the final result
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT;
                 
                float3 diffuse = atten * _LightColor0.rgb * _Color.rgb * max(0.0, dot(worldNormal, worldLightDir));
                
                float3 specular = atten * _LightColor0.rgb * _Color.rgb * pow(max(0.0, dot(reflect(-worldLightDir, worldNormal), worldViewDir)), 255);
                
                return float4(diffuse + specular, 1.0);  
            }              
            ENDCG
        }
    } 
    FallBack "VertexLit"
}