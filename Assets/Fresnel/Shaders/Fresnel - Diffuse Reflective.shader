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


Shader "FresnelPack/Diffuse Reflective" 
{
	Properties 
	{
		_MainTex("Texture", 2D) = "white"{}
		_Color ("Diffuse Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_CubeMap ("Environment Map", Cube) = "white"{}
		_Scale ("Fresnel Scale", Range(0.0, 1.0)) = 1.0
	}
	SubShader 
	{
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
            
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

			uniform samplerCUBE _CubeMap;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _Scale;
			uniform float3 _LightColor0;

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
				float3 posWorld : TEXCOORD1;
				float3 normWorld : TEXCOORD2;
				LIGHTING_COORDS(3,4)
				float3 lightDir : TEXCOORD5;
				float3 vertexLighting : COLOR;

			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				float3 normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);

				o.normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);
				o.posWorld = mul(_Object2World, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				
		        #ifdef VERTEXLIGHT_ON
	  			
	  			float3 worldN = o.normWorld;
		       	float4 worldPos = float4(o.posWorld, 1.0);
				o.vertexLighting = float4(0.0,0.0,0.0,0.0);
				
				for (int index = 0; index < 4; index++)
		        {    
	               float4 lightPosition = float4(unity_4LightPosX0[index], 
	                  unity_4LightPosY0[index], 
	                  unity_4LightPosZ0[index], 1.0);
	 
	               float3 vertexToLightSource = (lightPosition - worldPos).xyz;        
	               
	               float3 lightDirection = normalize(vertexToLightSource);
	               float squaredDistance = dot(vertexToLightSource, vertexToLightSource);

	               float attenuation =  1.0 / (1.0  + unity_4LightAtten0[index] * squaredDistance);
	               
	               float3 diffuseReflection = attenuation*2.0 * float3(unity_LightColor[index].xyz) 
	                  * max(0.0, dot(o.normWorld, lightDirection));         
	 
	               o.vertexLighting = o.vertexLighting + diffuseReflection;
		        }
		        #endif
				
				return o;

			}

			float4 frag(vOUT i) : COLOR
			{
				float3 I = normalize(i.posWorld - _WorldSpaceCameraPos.xyz);
				float3 R = reflect(I, i.normWorld);
				float F = min(1.0, max(0.0, _Scale * (1.0 + pow( dot(I, i.normWorld), 5.0))));
			 	fixed atten = LIGHT_ATTENUATION(i);
			 	float3 lightDir = i.lightDir;
			 	 
			 	if ( _WorldSpaceLightPos0.w > 0.0)
			 	{ 
					if ( atten == 1.0 ) atten = 0;
				}
				else
				{
					atten = 1.0;
				 	lightDir = _WorldSpaceLightPos0.xyz;
				}

				
				float3 diff = (atten*2.0)*_LightColor0 * max(0.0, dot(lightDir, i.normWorld));

				float4 reflectTex = texCUBE(_CubeMap, R); 
				
				float4 col = lerp(reflectTex,tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw)*_Color, F);
				return col * (float4(diff+i.vertexLighting,0.0)+ UNITY_LIGHTMODEL_AMBIENT*2.0); 
			}

			ENDCG
		}
		
		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
            
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

			uniform samplerCUBE _CubeMap;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _Scale;
			uniform float3 _LightColor0;

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
				float3 posWorld : TEXCOORD1;
				float3 normWorld : TEXCOORD2;
				LIGHTING_COORDS(3,4)
				float3 lightDir : TEXCOORD5;

			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;

				o.normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);
				o.posWorld = mul(_Object2World, v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				return o;

			}

			float4 frag(vOUT i) : COLOR
			{
				float3 I = normalize(i.posWorld - _WorldSpaceCameraPos.xyz);
				float3 R = reflect(I, i.normWorld);
				float F = min(1.0, max(0.0, _Scale * (1.0 + pow( dot(I, i.normWorld), 1.4))));
			 	fixed atten = LIGHT_ATTENUATION(i); 
				float3 lightDir = i.lightDir;
			 	 
			 	if ( _WorldSpaceLightPos0.w > 0.0)
			 	{ 
					if ( atten == 1.0 ) atten = 0;
				}
				else
				{
					atten = 1.0;
				 	lightDir = _WorldSpaceLightPos0.xyz;
				}

				float3 diff =(atten*2.0)*_Color*_LightColor0 * max(0.0, dot(lightDir, i.normWorld));

				float4 reflectTex = texCUBE(_CubeMap, R);
				
				float4 col = lerp(reflectTex,tex2D(_MainTex, i.uv * _MainTex_ST.xy + _MainTex_ST.zw)*_Color, F);
				
				return col * float4(diff,0.0);
			}

			ENDCG
		}
	
	} 
	FallBack "Diffuse"
}
