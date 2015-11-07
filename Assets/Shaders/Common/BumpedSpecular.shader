Shader "Unity Shaders Book/Common/Bumped Specular" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
		Pass { 
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			#pragma multi_compile_fwdbase	
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
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
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3; 
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				TANGENT_SPACE_ROTATION;
				
				float3 worldPos = mul(_Object2World, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
                
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);  
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);  
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
  				
  				TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
		
		Pass { 
			Tags { "LightMode"="ForwardAdd" }
			
			Blend One One
		
			CGPROGRAM
			
			#pragma multi_compile_fwdadd
			// Use the line below to add shadows for point and spot lights
//			#pragma multi_compile_fwdadd_fullshadows
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
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
				float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
			};
			
			v2f vert(a2v v) {
			 	v2f o;
			 	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			 
			 	o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
			 	o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(_Object2World, v.vertex).xyz;  
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
	
  				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			  	o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			  	o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
			 	
			 	TRANSFER_SHADOW(o);
			 	
			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
			 	
			 	fixed3 halfDir = normalize(lightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
			
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4((diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Specular"
}
