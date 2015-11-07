Shader "PengLu/Flame_alphablend" {
Properties {
	_ColorTex ("ColorTexture(RGBA)", 2D) = "white" {}
	_NoiseTex ("NoiseTexture(RGB)", 2D) = "white" {}
	_AlphaTex ("AlphaTexture(RGB)", 2D) = "white" {}
	_WindFreqScale("Wind freq scale",float) = 0.5
	_WindPower ("WindPowerDirection", Vector) = (0,0,0,0)
	_FlameColor("FlameColorContral",Vector) = (0.1,-0.33,0.68,0)

}
SubShader {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	LOD 200
	Cull front
	zWrite off
	
	pass {
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

	#include "UnityCG.cginc"
	#include "TerrainEngine.cginc"
	sampler2D _ColorTex;
	sampler2D _NoiseTex;
	sampler2D _AlphaTex;
	fixed4 _WindPower,_FlameColor;
	fixed _WindFreqScale;


	struct ApptoVert {
		half4 uvCoord : TEXCOORD0 ;
		half4 vertex : POSITION ;
		fixed4 vertColor : COLOR ;
		fixed4 inNormal : NORMAL ; 
	};

	struct VerttoFrag{
		half4 outPos : SV_POSITION ;
		half4 uvCoord : TEXCOORD0  ;
		half2 transUV1 : TEXCOORD1 ;
		half2 transUV2 : TEXCOORD2 ;
		half2 transUV3 : TEXCOORD3 ;
		half edgeAlpha : TEXCOORD4 ;
		half displaceV : TEXCOORD5 ;
				
	};

	
	VerttoFrag vert(ApptoVert v)
	{
		VerttoFrag o;
		o.uvCoord = v.uvCoord;

		half3 scrollSpeedY = ((-0.41 * _Time.y),(-0.96 * _Time.y),(-2.36 * _Time.y))*_FlameColor.w;
		half scrollSpeedX =  _Time.z*_FlameColor.w;


		o.transUV1 = v.uvCoord.xy * 1 ;
		o.transUV1.y = o.transUV1.y + scrollSpeedY.x ;
		o.transUV1.x = o.transUV1.x + scrollSpeedX ;

		o.transUV2 = v.uvCoord.xy * 2 ;
		o.transUV2.y = o.transUV2.y + scrollSpeedY.y ;
		o.transUV2.x = o.transUV2.x + (-0.8 * scrollSpeedX) ;

		o.transUV3 = v.uvCoord.xy * 3 ;
		o.transUV3.y = o.transUV3.y + scrollSpeedY.z ;
		o.transUV3.x = o.transUV3.x + (0.37 * scrollSpeedX) ;

		_WindPower.xyz =normalize( mul((float3x3)_World2Object,_WindPower.xyz));
		_WindPower.w *=v.vertColor.r;

		float windTime = _Time.y * _WindFreqScale;

		float4 vWaves = (frac( windTime.xxxx * float4(1.975, 0.793, 0.375, 0.193) ) * 2.0 - 1.0);
		
		vWaves = SmoothTriangleWave( vWaves );
		float2 vWavesSum = vWaves.xz + vWaves.yw;

		fixed bellyGradient = pow(v.uvCoord.y * (1-v.uvCoord.y),1.7);

		v.vertex.xyz += normalize(v.inNormal.xyz) * bellyGradient * vWavesSum.xyx;
		v.vertex.xyz += _WindPower.xyz * _WindPower.w *  (vWavesSum.y+0.5)*(bellyGradient+0.2);

		o.outPos = mul(UNITY_MATRIX_MVP,v.vertex);

		o.displaceV = vWavesSum.y*vWavesSum.x;

		half4 worldPos = mul(_Object2World , v.vertex );		
		fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
		fixed3 normalDir = normalize(mul(_Object2World ,fixed4(v.inNormal.xyz,0) ).xyz);

		o.edgeAlpha = pow(abs(dot(normalDir,viewDir)*1.7),2) * v.vertColor.a;
		
		return o;
	}

	fixed4 frag(VerttoFrag i) : COLOR
	{
		fixed2 noiseColor1 = tex2D(_NoiseTex,i.transUV1.xy).xy;
		fixed2 noiseColor2 = tex2D(_NoiseTex,i.transUV2.xy).xy;
		fixed2 noiseColor3 = tex2D(_NoiseTex,i.transUV3.xy).xy;

		noiseColor1.y *= _FlameColor.x;
		noiseColor2.y *= _FlameColor.y;
		noiseColor3.y *= _FlameColor.z;

		half2 noiseCoords = noiseColor1 + noiseColor2 + noiseColor3;

		noiseCoords += i.uvCoord.xy;

		fixed4 baseColor = tex2D(_ColorTex,clamp(noiseCoords,0.05,0.97));

		fixed4 texColor = baseColor + baseColor * (i.displaceV - 0.2) * 0.2;

		fixed Alpha1 = tex2D(_AlphaTex,i.uvCoord.xy).r;
		fixed Alpha2 = tex2D(_AlphaTex,clamp(noiseCoords,0.05,0.98)).r;

		texColor.a = Alpha1 * Alpha2 * i.edgeAlpha ;  

		return texColor;	
	}
	ENDCG
	}
		
} 
	FallBack "Diffuse"
}
