Shader "Z/VertexAndFragment/Lit/Shadow"
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
            #include "Lighting.cginc"

            #include "AutoLight.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            struct v2f
            {
                float2 uv: TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos: SV_POSITION;
                fixed4 diff: COLOR0; // diffuse lighting color;
                fixed3 ambient: COLOR1;
            };


            v2f vert(appdata_base v)
            {
                v2f o;

                //
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;

                half3 wNormal = UnityObjectToWorldNormal(v.normal);

                half nl = max(0, dot(wNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0;
                o.ambient = ShadeSH9(half4(wNormal, 1));
                // compute shadows data
                TRANSFER_SHADOW(o)
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed shadow = SHADOW_ATTENUATION(i);
                fixed3 lighting = i.diff * shadow + i.ambient;
                col.rgb *= lighting;

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
