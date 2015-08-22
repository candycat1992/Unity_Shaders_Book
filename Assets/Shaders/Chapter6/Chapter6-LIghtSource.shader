Shader "Unity Shader Book/Chapter6-LightSource" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.position = mul(UNITY_MATRIX_MVP, v.vertex);
			 	
			 	// Transform the normal fram object space to world space
			 	o.worldNormal = mul(v.normal, (float3x3)_World2Object);
			 	
			 	// Transform the vertex from object spacet to world space
			 	o.worldPosition = mul(_Object2World, v.vertex);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				
				// Get the light direction and attenuation
			 	fixed3 worldLightDir;
			 	float atten;
			 	
			 	if (_WorldSpaceLightPos0.w == 0.0) { // Directional light
			 		worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			 		atten = 1.0;
			 	} else {
			 		worldLightDir = _WorldSpaceLightPos0.xyz - i.worldPosition;
					float distance = length(worldLightDir);
					atten = 1.0 / distance;
					worldLightDir = normalize(worldLightDir);
			 	}
				
				// Compute diffuse term
			 	fixed3 diffuse = _LightColor0.rgb * atten * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
			 	
			 	fixed3 color = ambient + diffuse;
			 	
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
		Pass { 
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float4 worldPosition : TEXCOORD1;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.position = mul(UNITY_MATRIX_MVP, v.vertex);
			 	
			 	// Transform the normal fram object space to world space
			 	o.worldNormal = mul(v.normal, float3x3(_World2Object));
			 	
			 	// Transform the vertex from object spacet to world space
			 	o.worldPosition = mul(_Object2World, v.vertex);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				
				// Get the light direction and attenuation
			 	fixed3 worldLightDir;
			 	float atten;
			 	
			 	if (_WorldSpaceLightPos0.w == 0.0) { // Directional light
			 		worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			 		atten = 1.0;
			 	} else {
			 		worldLightDir = _WorldSpaceLightPos0.xyz - i.worldPosition;
					float distance = length(worldLightDir);
					
					atten = 1.0 / distance;
					worldLightDir = normalize(worldLightDir);
			 	}
				
				// Compute diffuse term
			 	fixed3 diffuse = _LightColor0.rgb * atten * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
			 	
			 	fixed3 color = ambient + diffuse;
			 	
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
