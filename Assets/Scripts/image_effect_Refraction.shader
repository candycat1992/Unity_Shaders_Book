
Shader "PengLu/image effect/Refraction" {
Properties {
	_MainTex ("BaseTex ", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
	_SatCount("SatCount",Range(0.0, 1.0)) = 0
}

SubShader {
	Tags { "Queue"="Transparent" "RenderType"="Opaque" }
     ZWrite off
     ZTest  Always


CGPROGRAM
#pragma surface surf Lambert nolightmap nodirlightmap
#pragma target 3.0
#pragma debug


uniform sampler2D _BumpMap;
uniform sampler2D _MainTex;
uniform float _SatCount;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
};


void surf (Input IN, inout SurfaceOutput o) {
	fixed3 nor = UnpackNormal (tex2D(_BumpMap, IN.uv_BumpMap*float3(1,0.7,1)));
	fixed4 trans = tex2D(_MainTex,IN.uv_MainTex+nor.xy*0.1);
//	fixed3 lum = dot(trans.rgb,fixed3(0.299,0.587, 0.114)); 	
	fixed lum = trans; 
	fixed3 satColor = lerp (trans, lum, _SatCount); 
	o.Albedo = 0;
	o.Emission = satColor;	
}
ENDCG
}

FallBack "Transparent/VertexLit"
}