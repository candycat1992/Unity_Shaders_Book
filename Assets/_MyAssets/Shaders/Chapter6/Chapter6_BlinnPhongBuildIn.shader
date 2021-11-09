Shader "Unlit/Chapter6_BlinnPhongBuildIn"
{
	Properties
	{
		//	定义一个Color属性，控制漫反射颜色
		_Diffuse("Diffuse", Color) = (1,1,1,1)

		//	高光颜色
		_Specular("Specular", Color) = (1,1,1,1)

		//	高光区域大小
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}

	SubShader
	{
		Pass
		{

			//	设置光照模式
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
			};
			struct v2f{
				float4 pos:SV_POSITION;
				float3 worldNormal:TEXCOORD0;
				float4 worldPos:TEXCOORD1;
			};

			fixed4 _Diffuse;
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

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//	获取unity内置的环境光变量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//	模型空间法线转换成世界空间法线，并归一化(TODO 这里后续再细看)
				fixed3 worldNormal = normalize(i.worldNormal);

				//	获取unity内置的世界空间下光照方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));


				float lightPower = max(0, dot(worldNormal, worldLightDir));

				//	漫反射 = 光照颜色值*漫反射*光照强度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightPower;

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

	FallBack "Diffuse"
}
