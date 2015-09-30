Shader "OpenGL Cookbook/UsingNormalMaps (Unity 5.x)" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Specular ("Specular", Range(1.0, 500.0)) = 250.0
        _Gloss ("Gloss", Range(0.0, 1.0)) = 0.2
        _Cubemap ("Cubemap", CUBE) = ""{}
		_ReflAmount ("Reflection Amount", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass {
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_fwdbase
			 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler2D _MainTex;
			sampler2D _Bump;
			float _Specular;
			float _Gloss;
			samplerCUBE _Cubemap;
			float _ReflAmount;

			float4 _MainTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed4 texcoord : TEXCOORD0;
				fixed4 tangent : TANGENT;
			};
			
			struct v2f {
				float4 pos : POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 lightDir: TEXCOORD1;
				fixed4 TtoW0 : TEXCOORD2;
  				fixed4 TtoW1 : TEXCOORD3;
  				fixed4 TtoW2 : TEXCOORD4;
				LIGHTING_COORDS(5, 6)
			};
			
			v2f vert(a2v v) {
				v2f o;
							
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				
				//Create a rotation matrix for tangent space
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				
				float3 worldPos = mul(_Object2World, v.vertex).xyz;
			  	fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
			  	fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
			  	fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
			  	// Case 1: The codes used by built-in shaders
			  	o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
			  	o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
			  	o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
  
//  				// Case 2: The codes which I think are correct 
//				float3x3 WtoT = mul(rotation, (float3x3)_World2Object);
//				o.TtoW0 = float4(WtoT[0].xyz, worldPos.x);
//				o.TtoW1 = float4(WtoT[1].xyz, worldPos.y);
//				o.TtoW2 = float4(WtoT[2].xyz, worldPos.z);
//				
				// pass lighting information to pixel shader
  				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag(v2f i) : COLOR {
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 norm = UnpackNormal(tex2D(_Bump, i.uv));
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				// Case 1
				half3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, norm), dot(i.TtoW1.xyz, norm), dot(i.TtoW2.xyz, norm)));
				// Case 2
//				worldNormal = normalize(mul(norm, float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz)));
				
				fixed atten = LIGHT_ATTENUATION(i);
				
				fixed3 ambi = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diff = _LightColor0.rgb * saturate (dot (normalize(worldNormal),  normalize(lightDir)));
								
				fixed3 lightRefl = reflect(-lightDir, worldNormal);
				fixed3 spec = _LightColor0.rgb * pow(saturate(dot(normalize(lightRefl), normalize(worldViewDir))), _Specular) * _Gloss;
				
				fixed3 worldView = fixed3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 worldRefl = reflect (-worldViewDir, worldNormal);
				fixed3 reflCol = texCUBE(_Cubemap, worldRefl).rgb * _ReflAmount;
				
				fixed4 fragColor;
				fragColor.rgb = float3((ambi + (diff + spec) * atten) * texColor) + reflCol;
				fragColor.a = 1.0f;
				
				return fragColor;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
