Shader "Unity Shaders Book/Chapter 7/Normal Map In Tangent Space" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir: TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				// Compute the binormal
//				float3 binormal = cross( normalize(v.normal), normalize(v.tangent.xyz) ) * v.tangent.w;
//				// Construct a matrix which transform vectors from object space to tangent space
//				float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
				// Or just use the built-in macro
				TANGENT_SPACE_ROTATION;
				
				// Transform the light direction from object space to tangent space
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				// Transform the view direction from object space to tangent space
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {				
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				
				// Get the texel in the normal map
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;
				// If the texture is not marked as "Normal map"
//				tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
//				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				// Or mark the texture as "Normal map", and use the built-in funciton
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
