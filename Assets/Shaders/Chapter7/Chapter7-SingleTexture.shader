Shader "Unity Shaders Book/Chapter7/SingleTexture" {
	Properties {
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
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
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 position : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPosition : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	// Transform the vertex from object space to projection space
			 	o.position = mul(UNITY_MATRIX_MVP, v.vertex);
			 	
			 	// Transform the normal fram object space to world space
			 	o.worldNormal = mul(v.normal, (float3x3)_World2Object);
			 	
			 	// Transform the vertex from object spacet to world space
			 	o.worldPosition = mul(_Object2World, v.vertex).xyz;
			 	
			 	o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	// Or just call the built-in function
//			 	o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				// Get ambient term
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPosition));
				
				// Use the texture to sample the diffuse color
				fixed3 diffuseColor = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				// Compute diffuse term
			 	fixed3 diffuse = _LightColor0.rgb * diffuseColor * max(0, dot(worldNormal, worldLightDir));

				// Get the view direction in world space
			 	fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPosition));
				// Get the half direction in world space
			 	fixed3 halfDir = normalize(worldLightDir + viewDir);
			 	// Compute specular term
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
			 	
				return fixed4(ambient + diffuse + specular, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
