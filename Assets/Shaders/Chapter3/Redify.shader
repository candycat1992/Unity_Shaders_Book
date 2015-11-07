Shader "Unity Shaders Book/Chapter 3/Redify" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma surface surf Lambert addshadow
        #pragma shader_feature REDIFY_ON

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            #if REDIFY_ON
            o.Albedo.gb *= 0.5;
            #endif
        }
        ENDCG
    } 
    CustomEditor "CustomShaderGUI"
}