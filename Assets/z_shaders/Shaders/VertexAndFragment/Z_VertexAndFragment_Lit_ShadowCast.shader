Shader "Z/VertexAndFragment/Lit/Shadow Cast"
{
    Properties
    {
        [NoScaleOffset]  _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
                fixed4 diff: COLOR0; // diffuse lighting color;
            };


            v2f vert(appdata_base v)
            {
                v2f o;

                //
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                half3 wNormal = UnityObjectToWorldNormal(v.normal);

                half nl = max(0, dot(wNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0;

                // the only difference from previous shader:
                o.diff.rgb += ShadeSH9(half4(wNormal, 1));
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= i.diff;
                return col;
            }
            ENDCG
            
        }

        // UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };


            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f i): SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
            
        }
    }
}
