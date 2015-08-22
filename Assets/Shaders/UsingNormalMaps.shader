Shader "OpenGL Cookbook/UsingNormalMaps" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Specular ("Specular", Range(1.0, 500.0)) = 250.0
        _Gloss ("Gloss", Range(0.0, 1.0)) = 0.2
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
				fixed3 viewDir : TEXCOORD2;
				LIGHTING_COORDS(3,4)
			};
			
			v2f vert(a2v v) {
				v2f o;
							
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv = TRANSFORM_TEX (v.texcoord, _MainTex);
				
				//Create a rotation matrix for tangent space
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
				
				// pass lighting information to pixel shader
  				TRANSFER_VERTEX_TO_FRAGMENT(o);
				return o;
			}
			
			fixed4 frag(v2f i) : COLOR {
				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 norm = UnpackNormal(tex2D(_Bump, i.uv));
				
				fixed atten = LIGHT_ATTENUATION(i);
				
				fixed3 ambi = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diff = _LightColor0.rgb * saturate (dot (normalize(norm),  normalize(i.lightDir)));
				
				fixed3 refl = reflect(-i.lightDir, norm);
				fixed3 spec = _LightColor0.rgb * pow(saturate(dot(normalize(refl), normalize(i.viewDir))), _Specular) * _Gloss;
				
				fixed4 fragColor;
				fragColor.rgb = float3((ambi + (diff + spec) * atten) * texColor);
				fragColor.a = 1.0f;
				
				return fragColor;
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
