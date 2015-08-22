Shader "Unity Shader Book/Chapter10/Fresnel" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_RefractRatio ("Refraction Ratio", Range(0.1, 1)) = 0.5
		_FresnelBias ("Fresnel Bias", Range(0, 1)) = 0.5
		_FresnelScale ("Fresnel Scale", Range(0, 2)) = 1
		_FresnelPower ("Fresnel Power", Range(1, 10)) = 4
		_Cubemap ("Reflection Cubemap", Cube) = "_Skybox" {}
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			// Apparently need to add this declaration 
            #pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			fixed _RefractRatio;
			fixed _FresnelBias;
			float _FresnelScale;
			float _FresnelPower;
			samplerCUBE _Cubemap;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
  				fixed3 worldNormal : TEXCOORD1;
  				fixed3 worldViewDir : TEXCOORD2;
  				fixed3 worldRefl : TEXCOORD3;
  				fixed3 worldRefr : TEXCOORD4;
 	 			SHADOW_COORDS(5)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			 	
			 	// Transform the normal fram object space to world space
			 	o.worldNormal = mul(v.normal, (float3x3)_World2Object);
			 	
			 	o.worldPos = mul(_Object2World, v.vertex).xyz;
			 	
			 	o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
			 	
			 	o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);
			 	
			 	o.worldRefr = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);
  				
  				TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);
			 	
			 	UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
			 	
			 	fixed3 refraction = texCUBE(_Cubemap, i.worldRefr).rgb;
			 	
			 	fixed3 reflection = texCUBE(_Cubemap, i.worldRefl).rgb;
			 	
			 	fixed reflectAmount = _FresnelBias + _FresnelScale * pow(1 - dot(worldViewDir, worldNormal), _FresnelPower);
			 	
			 	fixed3 color = ambient + lerp(refraction, reflection, saturate(reflectAmount)) * atten;
			 	
//			 	return fixed4(reflectAmount);
				return fixed4(color, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Legacy Shaders/Reflective/VertexLit"
}
