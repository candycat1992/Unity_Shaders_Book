

Shader "Unlit/Chapter5_SimpleShader"
{
	Properties
	{
		//	声明一个Color类型的属性
		_Color("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#include"UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			//	使用结构体定义顶点着色器的输入(Application to vertex)
			struct a2v
			{
				//	模型空间顶点坐标，使用POSITION语义告诉Unity,这里用模型空间的顶点坐标填充vertex变量
				float4 vertex:POSITION;
				//	模型空间法线方向，使用NORMAL语义告诉Unity，这里用模型空间的法线方向填充normal变量
				float3 normal:NORMAL;
				//	模型的第一套纹理坐标，使用TEXCOORD0语义告诉Unity，这里用模型的第一套纹理坐标填充uv变量
				float4 uv:TEXCOORD0;
			};

			//	使用结构体定义顶点着色器的输出(Vertex to fragment)
			struct v2f
			{
				//	顶点的裁剪空间坐标，使用SV_POSITION语义告诉Unity，pos包含了顶点在裁剪空间中的位置信息
				float4 pos:SV_POSITION;
				//	顶点颜色，使用COLOR语义告诉Unity，color存储了颜色信息(也可以根据自己需求存储其他信息)
				fixed3 color:COLOR;
			};

			//	定义一个与声明类型完全匹配的变量
			fixed4 _Color;

			v2f vert(a2v i)
			{
				//	声明输出结构
				v2f o;

				//	首先把模型空间坐标，转换成齐次裁剪空间坐标（MVP矩阵*vertex）
				//	Unity内置的MVP矩阵（模型*视图*投影矩阵）乘以模型空间坐标
				//	return mul(UNITY_MATRIX_MVP,v);
				o.pos = UnityObjectToClipPos(i.vertex);

				//	normal存储了顶点的法线方向，范围 [-1, 1]
				//	下边代码把分量范围映射到 [0, 1]
				//	存储到color中，传递给片元着色器
				o.color = i.normal * 0.5 + fixed3(0.5,0.5,0.5);

				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				//	这里的color是三角形面片3个顶点颜色插值计算后的颜色
				//	将插值后的颜色，显示到屏幕上
				//	与声明的颜色相乘
				return fixed4(i.color*_Color.rgb, 1);
			}

			ENDCG
		}
	}	
}
