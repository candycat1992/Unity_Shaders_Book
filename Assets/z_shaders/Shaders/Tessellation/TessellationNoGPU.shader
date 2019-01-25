Shader "Z/Tessellation/NoGPU"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        [Space]
        _Color ("Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Spec Color", Color) = (.5, .5, .5, .5)
        [NoScaleOffset]  _NormalMap ("Normalmap", 2D) = "bump" { }
        [Header(Tessellation)]
        [NoScaleOffset]  _DispTex ("Disp Texture (r)", 2D) = "gray" { }
        _Displacement ("Displacement", Range(0, 1)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300
        
        CGPROGRAM
        
        #pragma surface surf BlinnPhong addshadow fullforwardshadows vertex:disp nolightmap

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 4.6


        struct appdata
        {
            float4 vertex: POSITION;
            float4 tangent: TANGENT;
            float3 normal: NORMAL;
            float2 texcoord: TEXCOORD0;
        };

        sampler2D _DispTex;
        fixed _Displacement;

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
