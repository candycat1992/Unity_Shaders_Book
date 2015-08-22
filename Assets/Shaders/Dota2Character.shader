Shader "DOTA 2 Character" {
	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale("Bump Scale", Float) = 1.0
		_Mask1 ("Mask 1", 2D) = "white" {}
		_Mask2 ("Mask 2", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
		_Gloss ("Gloss", Range(1.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
	
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			sampler2D _Mask1;
			sampler2D _Mask2;
			float _SpecularScale;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.position = mul(UNITY_MATRIX_MVP, v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				TANGENT_SPACE_ROTATION;	
				// Transform the light direction from object space to tangent space
  				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
  				// Transform the view direction from object space to tangent space
  				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 mask1 = tex2D(_Mask1, i.uv);
				fixed detailMapMask = mask1.r;
				fixed fresnelMask = mask1.g;
				fixed metalness = mask1.b;
			 	fixed selfIllumination = mask1.a;
			 	
			 	fixed4 mask2 = tex2D(_Mask2, i.uv);
			 	fixed specularIntensity = mask2.r;
			 	fixed rimIntensity = mask2.g;
			 	fixed tintSpec = mask2.b;
			 	fixed specularExponent = mask2.a;
			 	
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

			 	float3 tangentLightDir = normalize(i.lightDir);
			 	
				float3 tangentViewDir = normalize(i.viewDir);
				
				// Get the texel in the normal map
				fixed4 packedNormal = tex2D(_BumpMap, i.uv);
				fixed3 tangentNormal;
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				// Use the texture to sample the diffuse color
				fixed3 diffuseColor = tex2D(_MainTex, i.uv).rgb;
				
				// Compute diffuse term
			 	fixed3 diffuse = _LightColor0.rgb * diffuseColor * max(0, dot(tangentNormal, tangentLightDir));
			 	
				// Get the half direction in tangent space
			 	fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
			 	// Compute specular term
			 	fixed3 specularColor = tintSpec * diffuseColor;
			 	fixed3 specular = _LightColor0.rgb * specularColor * pow(max(0, dot(tangentNormal, halfDir)), specularExponent * _Gloss) * specularIntensity * _SpecularScale;
			
				fixed3 emit = selfIllumination * diffuseColor;
				return fixed4(ambient + diffuse + specular + emit, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
