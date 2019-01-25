Shader "Z/SimpleSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        [Header(Texture)]
        _MainTex ("Texture", 2D) = "white" { }
        _BumpMap ("Bumpmap", 2D) = "bump" { }
        [Header(Rim)]
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower ("Rim Power", Range(0.5, 8.0)) = 3.0
        _RimStrength ("Rim Strength", Float) = 1
        [Header(Detail)]
        _Detail ("Detail", 2D) = "gray" { }
        [Toggle] _ScreenSpaceDetail ("Screen Space", Float) = 0
        [Header(Cubemap Reflection)]
        _Cube ("Cubemap", CUBE) = "" { }
        [Header(Clip Frac)]
        _Offset ("Offset", Range(0, 1)) = 0.5
        _YScale ("Y Scale", Float) = 5
        _ZScale ("Z Scale", Float) = 0.1
        [Header(Vertex Modifier)]
        _Amount ("Extrusion Amount", Range(-1, 1)) = 0.5
        [Header(FinalColor Modifier)]
        _ColorTint ("Tint", Color) = (1, 1, 1, 1)
        [Header(Fog)]
        _FogColor ("Fog Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        CGPROGRAM
        
        #pragma target 3.0
        #pragma surface surf Lambert exclude_path:prepass noforwardadd nolightmap vertex:vert finalcolor:mycolor
        #pragma multi_compile __ _SCREENSPACEDETAIL_ON
        #pragma multi_compile_fog

        struct Input
        {
            fixed4 color: COLOR0;
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_Detail;
            float3 viewDir;
            float3 worldRefl;
            INTERNAL_DATA
            float3 worldPos;
            #ifdef _SCREENSPACEDETAIL_ON
                float4 screenPos;
            #endif

            float3 customColor;
            half fog;
        };

        fixed4 _Color;
        
        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Detail;
        samplerCUBE _Cube;
        
        fixed4 _RimColor;
        fixed _RimPower;
        fixed _RimStrength;

        fixed _Offset;
        fixed _YScale;
        fixed _ZScale;

        fixed _Amount;

        fixed4 _ColorTint;

        fixed4 _FogColor;
        
        void vert(inout appdata_full v, out Input o)
        {
            v.vertex .xyz += v.normal * _Amount;
            UNITY_INITIALIZE_OUTPUT(Input, o);
            o.customColor = abs(v.normal);
            float4 hpos = UnityObjectToClipPos(v.vertex);
            hpos.xy /= hpos.w;
            o.fog = min(1, dot(hpos.xy, hpos.xy) * 0.5);
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            clip(frac(IN.worldPos.y * _YScale + IN.worldPos.z * _ZScale) - _Offset);
            o.Albedo = _Color * IN.color * tex2D(_MainTex, IN.uv_MainTex).rgb;
            float2 uv;
            #ifdef _SCREENSPACEDETAIL_ON
                uv = IN.screenPos.xy / IN.screenPos.w;
                uv *= float2(8, 6);
            #else
                uv = IN.uv_Detail;
            #endif

            o.Albedo *= tex2D(_Detail, uv).rgb * 2 * IN.customColor;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            half rim = 1. - saturate(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = saturate(_RimColor.rgb * pow(rim, _RimPower) * _RimColor.a * _RimStrength);
            o.Emission *= texCUBE(_Cube, WorldReflectionVector(IN, o.Normal)).rgb;
        }

        void mycolor(Input IN, SurfaceOutput o, inout fixed4 color)
        {
            color *= _ColorTint;
            fixed3 fogColor = _FogColor.rgb;
            #ifdef UNITY_PASS_FORWARDADD
                fogColor = 0;
            #endif
            color.rgb = lerp(color.rgb, fogColor, IN.fog);
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
