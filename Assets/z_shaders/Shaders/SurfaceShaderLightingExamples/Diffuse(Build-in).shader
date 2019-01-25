Shader "Z/Surface Shader Lighting/Diffuse (Build-in Lambert)"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        
        CGPROGRAM
        
        #pragma surface surf Lambert
        #pragma target 3.0


        struct Input
        {
            float2 uv_MainTex;
        };
        sampler2D _MainTex;

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
