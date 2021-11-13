Shader "Unlit/Chapter7_TangentSpaceNormalMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Normal("Normal", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_NormalScale("NormalScale", Float) = 1.0
		_Gloss("Gloss", Range(8.0, 256)) = 20

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;

				float3 normal: NORMAL;
				//	tangent.w分量来决定切线空间中第三个坐标轴-副切线的方向性
				float4 tangent: TANGENT;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir:TESSFACTOR1;
				float3 viewDir:TEXCOORD2;

			};

			sampler2D _MainTex;
			sampler2D _Normal;
			float4 _Normal_ST;
			float4 _MainTex_ST;

			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;
			float _NormalScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex).xy;
				o.uv.zw = TRANSFORM_TEX(v.uv, _Normal).xy;

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				float3x3 worldToTangent = float3x3(worldTangent, worldBinormal, worldNormal);

				o.lightDir = mul(worldToTangent, WorldSpaceLightDir(v.vertex));
				o.viewDir = mul(worldToTangent, WorldSpaceViewDir(v.vertex));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_Normal, i.uv.zw);

				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _NormalScale;
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
}
