Shader "Unlit/Chapter6_SpecularPixelLevel"
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
				float3 worldPos:TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			//	转换成 [0, 1]
			float my_saturate(float x)
			{
				return max(0.0, min(1.0, x));
			}

			v2f vert(a2v v)
			{
				v2f o;

				//	模型空间坐标转换成齐次空间坐标
				o.pos = UnityObjectToClipPos(v.vertex);

				//	模型空间法线转换成世界空间下法线
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);

				//	模型空间坐标转换成世界空间下坐标
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//	获取unity内置的环境光变量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//	模型空间法线转换成世界空间法线，并归一化(TODO 这里后续再细看)
				fixed3 worldNormal = normalize(i.worldNormal);

				//	获取unity内置的世界空间下光照方向，并归一化(这里假设只有一个平行光，当环境中有多个光源时，这里要调整)
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//	顶点法线与光照方向点积，计算当前顶点的光照强度
				//	要计算法线和光照朝向点积，前提是两者处于同一个坐标系下，这样才有意义
				//	所以这里统一选择了世界坐标空间
				float lightPower = my_saturate(dot(worldNormal, worldLightDir));

				//	漫反射 = 光照颜色值*漫反射*光照强度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightPower;


				//////比逐顶点漫反射多了一个高光计算/////

				//	计算世界空间下reflect方向
				//	计算入射光线方向关于表面法线的反射方向reflectDir
				//	由于reflect函数的入射方向要求是由光源指向交点处，因此要对worldLightDir取反后再传给reflect函数
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				//	计算世界空间下视角方向 = (世界空间下相机坐标 - 顶点世界空间下坐标)


				//	通过内置变量_WorldSpaceCameraPos获取世界空间中相机位置
				//	两者相减即可得到世界空间下的视角方向
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);


				//	计算高光强度
				float specularPower = pow(my_saturate(dot(reflectDir, viewDir)), _Gloss);

				//	计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * specularPower;

				/////比逐顶点漫反射多了一个高光计算/////


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
