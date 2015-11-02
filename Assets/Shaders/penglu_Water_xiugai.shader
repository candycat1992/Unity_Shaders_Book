Shader "PengLu/Water/ReflCube-Fast_x" {
	Properties {
		_Color("Main Color", Color) = (0, 0.15, 0.115, 1)
		_MainTex ("BaseTex ", 2D) = "white" {}
		_WaveTex("Wave Texture", 2D) = "bump" {}
		_CubeTex("Reflection Texture", Cube) = "_Skybox" {}
		_WaveSpeed("Wave Speed", Range(0.0, 0.2)) = 0.01
		_Refraction ("Refraction Amount", Range(0.0, 1.0)) = 0.5
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {

			CGPROGRAM
			
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				fixed4 _Color;
				sampler2D _WaveTex;
				sampler2D _MainTex;
				fixed4 _WaveTex_ST;
				fixed4 _MainTex_ST;
				samplerCUBE _CubeTex;
				fixed _WaveSpeed, _Refraction;

				struct a2f {
					float4 vertex : POSITION;
					fixed3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f {
					float4 Pos : SV_POSITION;
					float2 Uv : TEXCOORD0;
					float2 baseuv : TEXCOORD2;
					fixed3 viewDir  : TEXCOORD1;
					fixed3 worldRefl:TEXCOORD1;
//					fixed3 normal : TEXCOORD2;
//					INTERNAL_DATA
				};

				v2f vert (a2f v) {
					v2f o;
					o.Pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.Uv = TRANSFORM_TEX(v.texcoord, _WaveTex);
					o.baseuv = TRANSFORM_TEX(v.texcoord, _MainTex);
					o.viewDir  = mul((float3x3)_Object2World, ObjSpaceViewDir(v.vertex));//不理解
//					o.viewDir.xzy = ObjSpaceViewDir(v.vertex);
//					o.normal = mul( (float3x3)glstate.matrix.mvp, v.normal );
//					o.viewDir .x *= -1;

					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					fixed speed = _Time.y * _WaveSpeed;
					//Fake tangent Space Normals
					fixed4 tex=tex2D(_MainTex, i.baseuv + speed);
					fixed4 bump = tex2D(_WaveTex, i.Uv + speed) + tex2D(_WaveTex, i.Uv - speed);
					bump *=0.5;
					fixed3 normalW = normalize(UnpackNormal(bump).rbg);
					i.viewDir  = normalize(i.viewDir );
//					i.worldRefl = WorldReflectionVector (i, normalW);
					//Reflection
					i.worldRefl=normalize(i.worldRefl);
					fixed3 reflCol = texCUBE(_CubeTex, reflect(i.viewDir ,normalW)).rgb;
					//Refraction
					fixed3 refrCol = texCUBE(_CubeTex, refract(i.viewDir , normalW, 0.66)).rgb;
					//Fresnel term
					fixed EdotN = max(dot(i.viewDir,normalW), 0);
					fixed facing = (1.0 - EdotN);
//					half fresnel = 1 - EdotN * 1.3f;
//					half fresnel = 0.20 + (1.0 - 0.20) - pow(facing, 5.0);
//					half fresnel = 0.02 + 0.97 * pow(facing, 5.0);
					fixed fresnel = 1 / pow(1 + EdotN, 1);

					fixed3 deepCol = (refrCol * _Refraction + _Color * (1 - _Refraction));
					fixed3 waterCol = (_Color * facing + deepCol * (1-facing));
					fixed3 finalColor = fresnel*reflCol + waterCol;
					finalColor*=tex.rgb;
					return fixed4(finalColor*(facing+0.5), 1-facing);
				}
			ENDCG
		}
	} 
	FallBack Off
}