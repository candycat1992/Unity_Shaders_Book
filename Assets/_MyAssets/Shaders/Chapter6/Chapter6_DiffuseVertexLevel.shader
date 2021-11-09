//	逐顶点光照
//	对于细分程度较高的模型，逐顶点光照已经可以得到比较好的光照效果了
//	但是对于一些细分程度较低的模型，就会出现一些视觉问题，特别是背光面和向光面的交界处容易出现锯齿
//	为了解决这些问题，可以使用逐像素的漫反射光照


Shader "Unlit/Chapter6_DiffuseVertexLevel"
{
	Properties
	{
		//	定义一个Color属性，控制漫反射颜色
		_Diffuse("Diffuse", Color) = (1,1,1,1)
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
				fixed3 color:COLOR;
			};

			fixed4 _Diffuse;

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

				//	获取unity内置的环境光变量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//	模型空间法线转换成世界空间法线，并归一化(TODO 这里后续再细看)
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
				//worldNormal = normalize(mul((float3x3)unity_ObjectToWorld, v.normal));

				//	获取unity内置的世界空间下光照方向，并归一化(这里假设只有一个平行光，当环境中有多个光源时，这里要调整)
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				//	顶点法线与光照方向点积，计算当前顶点的光照强度
				//	要计算法线和光照朝向点积，前提是两者处于同一个坐标系下，这样才有意义
				//	所以这里统一选择了世界坐标空间
				float lightPower = my_saturate(dot(worldNormal, worldLight));

				//	漫反射 = 光照颜色值*漫反射*光照强度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightPower;

				//	最终颜色值 = 环境光颜色 + 漫反射颜色
				o.color = ambient + diffuse;

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//	直接返回颜色插值
				return fixed4(i.color.rgb,1);
			}

			ENDCG
		
		}
	}

	FallBack "Diffuse"
}
