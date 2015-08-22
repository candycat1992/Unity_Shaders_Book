//Copyright (c) 2014 Kyle Halladay
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in
//all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//THE SOFTWARE.


Shader "FresnelPack/Unlit Rim Color" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Scale ("Frensel Scale", Range(0.0, 1.0)) = 1.0
		_Color ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader 
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _Bias;
			uniform float _Power;
			uniform float _Scale;

			struct vIN
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct vOUT
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float reflectionFactor : TEXCOORD1;
				
			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;

				float3 posWorld = mul(_Object2World, v.vertex).xyz;
				float3 normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);

				float3 I = posWorld - _WorldSpaceCameraPos.xyz;
				o.reflectionFactor = _Scale * pow(1.0 + dot(normalize(I), normWorld), 1.4);

				return o;
			}

			float4 frag(vOUT i) :  COLOR
			{  
				float4 col = tex2D(_MainTex, i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				return lerp(col,_Color, i.reflectionFactor);
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}
