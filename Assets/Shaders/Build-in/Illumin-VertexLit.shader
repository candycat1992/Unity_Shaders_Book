Shader "Legacy Shaders/Self-Illumin/VertexLit" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Spec Color", Color) = (1,1,1,1)
	_Shininess ("Shininess", Range (0.1, 1)) = 0.7
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Illum ("Illumin (A)", 2D) = "white" {}
}

SubShader {
	LOD 100
	Tags { "RenderType"="Opaque" }
	
	Pass {
		Name "BASE"
		Tags {"LightMode" = "Vertex"}
		Material {
			Diffuse [_Color]
			Shininess [_Shininess]
			Specular [_SpecColor]
		}
		SeparateSpecular On
		Lighting On
		SetTexture [_Illum] {
			constantColor [_Color]
			combine constant lerp (texture) previous
		}
		SetTexture [_MainTex] {
			constantColor (1,1,1,1)
			Combine texture * previous, constant // UNITY_OPAQUE_ALPHA_FFP
		}
	}

	// Extracts information for lightmapping, GI (emission, albedo, ...)
	// This pass it not used during regular rendering.
	Pass
	{
		Name "META" 
		Tags { "LightMode" = "Meta" }
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		#include "UnityMetaPass.cginc"

		struct v2f
		{
			float4 pos : SV_POSITION;
			float2 uvMain : TEXCOORD0;
			float2 uvIllum : TEXCOORD1;
		};

		float4 _MainTex_ST;
		float4 _Illum_ST;

		v2f vert (appdata_full v)
		{
			v2f o;
			o.pos = UnityMetaVertexPosition(v.vertex, v.texcoord1.xy, v.texcoord2.xy, unity_LightmapST, unity_DynamicLightmapST);
			o.uvMain = TRANSFORM_TEX(v.texcoord, _MainTex);
			o.uvIllum = TRANSFORM_TEX(v.texcoord, _Illum);
			return o;
		}

		sampler2D _MainTex;
		sampler2D _Illum;
		fixed4 _Color;

		half4 frag (v2f i) : SV_Target
		{
			UnityMetaInput metaIN;
			UNITY_INITIALIZE_OUTPUT(UnityMetaInput, metaIN);

			fixed4 tex = tex2D(_MainTex, i.uvMain);
			fixed4 c = tex * _Color;
			metaIN.Albedo = c.rgb;
			metaIN.Emission = c.rgb * tex2D(_Illum, i.uvIllum).a;
			return UnityMetaFragment(metaIN);
		}
		ENDCG
	}
}

Fallback "Legacy Shaders/VertexLit"
CustomEditor "LegacyIlluminShaderGUI"
}
