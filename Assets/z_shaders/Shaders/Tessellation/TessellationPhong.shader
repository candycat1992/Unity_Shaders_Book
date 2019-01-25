Shader "Z/Tessellation/Phong"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Color ("Color", Color) = (1, 1, 1, 1)
        [Space]
        [Header(Tessellation)]
        _Phong ("Phong Strengh", Range(0, 1)) = 0.5
        _EdgeLength ("Edge Length", Range(2, 50)) = 15
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300
        
        CGPROGRAM
        
        #pragma surface surf Lambert vertex:dispNone tessellate:tessEdge tessphong:_Phong nolightmap
        #pragma target 4.6
        #include "Tessellation.cginc"


        struct appdata
        {
            float4 vertex: POSITION;
            float4 tangent: TANGENT;
            float3 normal: NORMAL;
            float2 texcoord: TEXCOORD0;
        };

        float _EdgeLength;
        float _Phong;

        float4 tessEdge(appdata v0, appdata v1, appdata v2)
        {
            return UnityEdgeLengthBasedTess(v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
        }

        sampler2D _DispTex;
        float _Displacement;

        void dispNone(inout appdata v)
        {
            
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
            o.Alpha = c.a;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
