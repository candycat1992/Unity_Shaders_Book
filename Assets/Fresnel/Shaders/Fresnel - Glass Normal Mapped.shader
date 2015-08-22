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


Shader "FresnelPack/Glass - Normal Mapped" 
{
	Properties 
	{
		_CubeMap ("Environment Map", Cube) = "white"{}
		_NormalMap("Normal Map", 2D) = "bump"{}
		_Shininess ("Shininess", Range(1.0, 50.0)) = 1.0
		_Refraction ("Refractivity", Range(1.0, 1.8)) = 1.5
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
			#pragma target 3.0
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

			uniform samplerCUBE _CubeMap;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _Scale;

			uniform float _Refraction;
			uniform float _Shininess;
			uniform float3 _LightColor0;

			struct vIN
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD;
			};

			struct vOUT
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 posWorld : TEXCOORD1;
				float3 normWorld : TEXCOORD2;
				float4 tangentWorld : TEXCOORD3;
				float3 vertexLighting : TEXCOORD4;
				LIGHTING_COORDS(5,6)
				float3 lightDir : COLOR;
			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;

				o.normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);
				o.posWorld = mul(_Object2World, v.vertex).xyz;
				
				o.tangentWorld = float4(normalize(float3(mul(_Object2World, float4(v.tangent.xyz, 0.0)).xyz)), v.tangent.w);
				o.lightDir = ObjSpaceLightDir(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);
				
				#ifdef VERTEXLIGHT_ON
	  			
	  			float3 worldN = o.normWorld;
		       	float4 worldPos = float4(o.posWorld, 1.0);
		       	
				float3 I = normalize(o.posWorld - _WorldSpaceCameraPos.xyz);
				float3 R = reflect(I, worldN);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - o.posWorld.xyz);
				o.vertexLighting = float4(0.0,0.0,0.0,0.0);
				
				for (int index = 0; index < 4; index++)
		        {    
	               float4 lightPosition = float4(unity_4LightPosX0[index], 
	                  unity_4LightPosY0[index], 
	                  unity_4LightPosZ0[index], 1.0);
	 
	               float3 vertexToLightSource = (lightPosition - worldPos).xyz;        
	               
	               float3 lightDirection = normalize(vertexToLightSource);
	               
	               float squaredDistance = dot(vertexToLightSource, vertexToLightSource);
	               
	               float attenuation = 1.0 / (1.0  + unity_4LightAtten0[index] * squaredDistance);
	               
	               float3 spec = (attenuation)*float3(unity_LightColor[index].xyz) * max(0.0, dot(-R, viewDirection)) * pow(max(0.0,dot(worldN, lightDirection)), _Shininess);

	               float3 diffuseReflection = attenuation * float3(unity_LightColor[index].xyz) 
	                   * max(0.0, dot(worldN, lightDirection));         
	 
	               o.vertexLighting = o.vertexLighting + float4(spec,0.0);
		        }
		        
		        #endif

				return o;

			}

			float4 frag(vOUT i) : COLOR
			{
				float4 texNormalMap = tex2D(_NormalMap, i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw);
				float3 local = float3(2.0*texNormalMap.ag - float2(1.0, 1.0), 0.0);
				local.z = 1.0;
				float3 binormalWorld = normalize(cross(i.tangentWorld, i.normWorld).xyz * i.tangentWorld.w); 

				float3x3 local2WorldTranspose = float3x3(
				float3(i.tangentWorld.xyz), // muls against x
				binormalWorld,  // against y
				i.normWorld); // against z

				float3 normalDir = normalize(mul(local, local2WorldTranspose));
			
				float3 I = normalize(i.posWorld - _WorldSpaceCameraPos.xyz);
				float3 R = reflect(I, normalDir);
				float3 T = refract(I, normalDir,  1.0 / (_Refraction));
												
				float F = min(1.0, max(0.0, _Scale * (1.0 + pow( dot(I, normalDir), 5.0))));

				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);


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


				float3 spec = (atten*2.0)*(_LightColor0) * max(0.0, dot(-R, viewDirection)) * pow(max(0.0,dot(i.normWorld, lightDir)), _Shininess);

				float4 reflectTex = texCUBE(_CubeMap, R);
				float4 refractTex = texCUBE(_CubeMap, T);
				
				float4 col = lerp(reflectTex,refractTex,F);

				return col *float4(_LightColor0,1.0) + col*(float4(spec+i.vertexLighting,0.0)+ UNITY_LIGHTMODEL_AMBIENT*2.0); 

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
			#pragma target 3.0
			#pragma multi_compile_fwdadd
            
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

			uniform samplerCUBE _CubeMap;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
			uniform float _Scale;

			uniform float _Refraction;
			uniform float _Shininess;
			uniform float3 _LightColor0;

			struct vIN
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float2 texcoord : TEXCOORD;
			};

			struct vOUT
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 posWorld : TEXCOORD1;
				float3 normWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
				LIGHTING_COORDS(5,6)
				float3 lightDir : COLOR;
			};

			vOUT vert(vIN v)
			{
				vOUT o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;

				o.normWorld = normalize(mul(_Object2World, float4(v.normal,0.0)).xyz);
				o.posWorld = mul(_Object2World, v.vertex);
				
				o.tangentWorld = normalize(float3(mul(_Object2World, float4(v.tangent.xyz, 0.0)).xyz));
				o.binormalWorld = normalize(cross(o.tangentWorld, o.normWorld).xyz * v.tangent.w); 
				o.lightDir = ObjSpaceLightDir(v.vertex);
				TRANSFER_VERTEX_TO_FRAGMENT(o);


				return o;

			}

			float4 frag(vOUT i) : COLOR
			{
				float4 texNormalMap = tex2D(_NormalMap, i.uv * _NormalMap_ST.xy + _NormalMap_ST.zw);
				float3 local = float3(2.0*texNormalMap.ag - float2(1.0, 1.0), 0.0);
				local.z = 1.0; 
				float3x3 local2WorldTranspose = float3x3(
				i.tangentWorld,
				i.binormalWorld, 
				i.normWorld); 

				float3 normalDir = normalize(mul(local, local2WorldTranspose));
			
				float3 I = normalize(i.posWorld - _WorldSpaceCameraPos.xyz);
				float3 R = reflect(I, normalDir);
				float3 T = refract(I, normalDir,  1.0 / (_Refraction));
												
				float F = min(1.0, max(0.0, _Scale * (1.0 + pow( dot(I, normalDir), 5.0))));

				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);


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


				float3 spec = (atten*2.0)*_LightColor0 * max(0.0,dot(-R, viewDirection)) * pow(max(0.0,dot(i.normWorld, lightDir)), _Shininess);

				float4 reflectTex = texCUBE(_CubeMap, R);
				float4 refractTex = texCUBE(_CubeMap, T);
				
				float4 col = lerp(reflectTex,refractTex,F);
				
				return col*float4(_LightColor0, 1.0) * (atten)+ col* (float4(spec,0.0)); 
			}

			ENDCG
		}
	} 
	FallBack "Diffuse"
}