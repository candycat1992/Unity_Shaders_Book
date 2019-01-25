Shader "Z/VertexAndFragment/Lit/Simple Diffuse"
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
    }
}
