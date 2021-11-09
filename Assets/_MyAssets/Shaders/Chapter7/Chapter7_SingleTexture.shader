Shader "Unlit/Chapter7_SingleTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
		_Specular("Specular",Color)=(1,1,1,1)
		_Gloss("Gloss", Range(8,256)) = 20
	}
	SubShader
	{
		Pass
		{
			
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM
			//	unity内置通用的函数和变量
			#include "UnityCG.cginc"
			//	unity内置光照变量
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 texcoord:TEXCOORD;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float4 worldPos:TEXCOORD1;
				float2 uv:TEXCOORD2;
				
			};

			sampler2D _MainTex;
			//	纹理名_ST (Scale Translation)  _ST.xy 缩放  _ST.zw 偏移
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _Specular;
			float _Gloss;


			v2f vert(a2v v)
			{
				v2f o;

				//	模型空间坐标转换成齐次空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//	模型空间法线转换成世界空间下法线(内置函数)
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				//	模型空间坐标转换成世界空间下坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				//	uv = texcoord * 缩放 + 偏移值
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				//	或者直接调用内置函数
				//o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{

				fixed3 worldNormal = normalize(i.worldNormal);

				//	获取unity内置的世界空间下光照方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				//	纹理采样
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				
				//	获取unity内置的环境光变量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				float lightPower = max(0, dot(worldNormal, worldLightDir));

				//	漫反射 = 光照颜色值*漫反射*光照强度
				fixed3 diffuse = _LightColor0.rgb * albedo * lightPower;

				//	内置函数计算视角
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				//	计算高光强度
				float specularPower = pow(max(0, dot(worldNormal, halfDir)), _Gloss);

				//	计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * specularPower;

				//	最终颜色值 = 环境光颜色 + 漫反射颜色 + 高光
				fixed3 color = ambient + diffuse + specular;

				//	返回颜色
				return fixed4(color.rgb,1);
			}

			ENDCG

		}
	}

	FallBack "Specular"
}
