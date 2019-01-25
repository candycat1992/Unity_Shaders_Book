Shader "Custom/BarWithSegments"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" { }
        [Header(Settings)]
        _Segments ("Segments", Float) = 40

        _BorderColor ("Border color", Color) = (0.1, 0.1, 0.1, 1)
        _BorderWidth ("Border width", Float) = 1

        _ImageSize ("Image Size", Vector) = (100, 100, 0, 0)
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "PreviewType" = "Plane" "CanUseSpriteAtlas" = "True" }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex: POSITION;
                float4 color: COLOR;
                float2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex: SV_POSITION;
                fixed4 color: COLOR;
                half2 texcoord: TEXCOORD0;
            };

            //fixed4 _Color;
            half _Segments;

            fixed4 _BorderColor;
            half _BorderWidth;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                o.color = v.color;
                //OUT.vertex = UnityPixelSnap(OUT.vertex);
                return o;
            }

            sampler2D _MainTex;
            float4 _ImageSize;

            fixed4 frag(v2f IN): SV_Target
            {
                fixed4 c = tex2D(_MainTex, IN.texcoord);
                if ((IN.texcoord.x * _ImageSize.x) % (_ImageSize.x / _Segments) < _BorderWidth)
                {
                    c *= _BorderColor;
                }
                c.rgb *= c.a;
                c.a = IN.color.a;
                return c;
            }
            ENDCG
            
        }
    }
}