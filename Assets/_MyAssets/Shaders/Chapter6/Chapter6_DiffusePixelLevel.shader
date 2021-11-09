//	逐像素光照可以得到更平滑的光照效果。但是，即便如此，有一个问题仍然存在
//	在光照无法到达的区域，模型的外观通常是全黑的，并没有任何明暗变化，这会使模型的背光区域看起来像一个平面一样
//	实际上我们可以通过添加环境光来得到非全黑的效果，但无法解决背光面明暗一样的缺点
//	为此，有一种改善技术被提出来，这就是半兰伯特（Half Lambert）光照模型

Shader "Unlit/Chapter6_DiffusePixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			Tags {"LightMode"="ForwardBase"}

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct v2f{
				float4 pos:SV_POSITION;
				fixed3 worldNormal:TEXCOORD0;
			};

			fixed4 _Diffuse;

			float my_saturate(float x)
			{
				return max(0.0, min(1.0, x));
			}

			v2f vert(a2v i)
			{
			
				v2f o;

				o.pos = UnityObjectToClipPos(i.vertex);

				//	光照模型放在片元着色器计算，只需要计算世界空间下法线传给片元着色器
				o.worldNormal = mul(i.normal, (float3x3)unity_WorldToObject);

				return o;
			}

			//	在片元着色器计算光照模型
			fixed4 frag(v2f i):SV_Target
			{
				//	获取内置的环境光
				fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				//	像素世界空间下法线归一化
				fixed3 worldNormal = normalize(i.worldNormal);

				//	世界空间下平行光朝向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				//	计算光照强度，并转换到[0,1]
				float lightPower = my_saturate(dot(worldNormal, worldLightDir));

				//	漫反射 = 光照颜色值*漫反射*光照强度
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * lightPower;

				//	最终颜色值 = 环境光颜色 + 漫反射颜色
				fixed3 color = ambient + diffuse;

				return fixed4(color,1);
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
