Shader "Z/Semantics/Screen Pos"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            struct v2f
            {
                float2 uv: TEXCOORD0;
            };


            v2f vert(float4 vertex: POSITION, float2 uv: TEXCOORD0, out float4 outpos: SV_POSITION)
            {
                v2f o;
                outpos = UnityObjectToClipPos(vertex);
                o.uv = uv;
                return o;
            }

            sampler2D _MainTex;
            fixed4 frag(v2f i, UNITY_VPOS_TYPE screenPos: VPOS): SV_Target
            {
                screenPos.xy = floor(screenPos.xy * .25) * 0.5;
                float checker = -frac(screenPos.r + screenPos.g);
                clip(checker);


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
            
        }
    }
}
