Shader "Custom/UsingDefaultNormal" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
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
			
			#pragma multi_compile_fwbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			sampler2D _MainTex;
			float _Specular;
			float _Gloss;
			samplerCUBE _Cubemap;
			float _ReflAmount;
			
			float4 _MainTex_ST;
			
			struct a2v {
				float4 vertex : POSITION;
                fixed3 normal : NORMAL;
                fixed4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
				LIGHTING_COORDS(4,5)
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				//Transform the vertex to projection space
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				//Get the UV coordinates
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex); 
				// If the model matrix is orthogonal (no scaling)
				// We can use _Object2World;
				o.worldNormal = mul((float3x3)_Object2World, v.normal);
				// Or if the matrix is orthogonal
				// We can use transpose instead of the inverse
				o.worldNormal = mul(v.normal, (float3x3)_World2Object);
				
				o.lightDir = mul((float3x3)_Object2World, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul((float3x3)_Object2World, ObjSpaceViewDir(v.vertex));
				
				// pass lighting information to pixel shader
  				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			float4 frag(v2f i) : COLOR {
				fixed3 texColor = tex2D(_MainTex, i.uv);	
				
				//Based on the ambient light
				fixed3 ambi = UNITY_LIGHTMODEL_AMBIENT.xyz;
				ambi = fixed3(0);

				fixed3 lightColor = fixed3(1.0);
				//Work out this distance of the light
				fixed atten = LIGHT_ATTENUATION(i);
				//Angle to the light
				fixed3 diff = lightColor * saturate (dot (normalize(i.worldNormal),  normalize(i.lightDir))); 
				
				fixed3 lightRefl = reflect(-i.lightDir, i.worldNormal);
				fixed3 spec = lightColor * pow(saturate(dot(normalize(lightRefl), normalize(i.viewDir))), _Specular) * _Gloss; 
				
				fixed3 worldRefl = reflect(-i.viewDir, i.worldNormal);
				fixed3 reflCol = texCUBE(_Cubemap, worldRefl).rgb * _ReflAmount;
				 
				 //Product the final color
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
