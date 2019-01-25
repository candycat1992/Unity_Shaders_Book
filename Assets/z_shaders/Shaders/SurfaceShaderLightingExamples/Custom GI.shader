Shader "Z/Surface Shader Lighting/CustomGI_ToneMapped"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        [Header(Tone Mapped)]
        _Gain ("Lightmap tone-mapping Gain", Float) = 1
        _Knee ("Lightmap tone-mapping Knee", Float) = .5
        _Compress ("Lightmap tone-mapping Compress", Float) = .33
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        
        CGPROGRAM
        
        #pragma surface surf CustomGI
        #include "UnityPBSLighting.cginc"

        half _Gain;
        half _Knee;
        half _Compress;
        inline half3  TonemapLight(half3 i)
        {
            i *= _Gain;
            return(i > _Knee)?(((i - _Knee) * _Compress) + _Knee): 1;
        }

        inline  half4 LightingCustomGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
            return LightingStandard(s, viewDir, gi);
        }

        inline void LightingCustomGI_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
            gi.light.color = TonemapLight(gi.light.color);
            #ifdef DIRLIGHTMAP_SEPARATE
                #ifdef LIGHTMAP_ON
                    gi.light2.color = TonemapLight(gi.light2.color);
                #endif
                #ifdef DYNAMICLIGHTMAP_ON
                    gi.light3.color = TonemapLight(gi.light3.color);
                #endif
            #endif // dir lightmap separate

            gi.indirect.diffuse= TonemapLight(gi.indirect.diffuse);
            gi.indirect.specular= TonemapLight(gi.indirect.specular);
        }

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };


        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
