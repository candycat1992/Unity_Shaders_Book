Shader "Z/Tessellation/Distance-based"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Spec Color", Color) = (.5, .5, .5, .5)
        [NoScaleOffset]  _NormalMap ("Normalmap", 2D) = "bump" { }
        [Header(Tessellation)]
        _Tess ("Tessellation", Range(1, 32)) = 4
        [NoScaleOffset]  _DispTex ("Disp Texture (r)", 2D) = "gray" { }
        _Displacement ("Displacement", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300
        
        CGPROGRAM
        
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp tessellate:tessDistance nolightmap
        #pragma target 4.6
        #include "Tessellation.cginc"


        struct appdata
        {
            float4 vertex: POSITION;
            float4 tangent: TANGENT;
            float3 normal: NORMAL;
            float2 texcoord: TEXCOORD0;
        };

        float _Tess;

        float4 tessDistance(appdata v0, appdata v1, appdata v2)
        {
            float minDist = 10.0;
            float maxDist = 25.0;

            return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
        }

        sampler2D _DispTex;
        float _Displacement;

        void disp(inout appdata v)
        {
            float d = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0)).r * _Displacement;
            v.vertex.xyz += v.normal * d;
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        sampler2D _NormalMap;
        fixed4 _Color;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Specular = 0.2;
            o.Gloss = 1;
            o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
