
Shader "Custom/Diffuse+Selfluminous1tex"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _Alphapow ("Alphapow", Range(-2, 0)) = 0
        _Selflu ("Self-luminous", Color) = (0, 0, 0, 0)
        _ID01Tex ("FaceID_01 (RGB) SelfiuGloss (A)", 2D) = "Black" { }

        
        _RimColor ("Rim Color", Color) = (0.000, 0.000, 0.000, 1.000)
        _RimPower ("Rim Range", Range(0.5, 15.0)) = 3.0
        _Rimstrong ("Rim Strength", Float) = 1
    }


    SubShader
    {
        Tags { "Queue" = "Transparent+5" "RenderType" = "Transparent" }
        
        CGPROGRAM
        
        #pragma surface surf Lambert

        sampler2D _ID01Tex;

        fixed4 _Color;
        float4 _RimColor;
        float _RimPower;
        float _Rimstrong;


        struct Input
        {
            float2 uv_ID01Tex;
            float3 viewDir;
        };


        void surf(Input IN, inout SurfaceOutput o)
        {
            //	clip (frac((IN.screenPos.x*_sr + IN.screenPos.y)/IN.screenPos.w * (_scrH*0.3)) - _sz);
            fixed4 c1 = tex2D(_ID01Tex, IN.uv_ID01Tex) * _Color;


            half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));

            o.Albedo = c1.rgb;//  + c2.rgb ;
            o.Emission = (((_RimColor.rgb * pow(rim, _RimPower)) * _RimColor.a * _Rimstrong)) ;
        }
        ENDCG
        
    }


    Fallback "VertexLit"
}
