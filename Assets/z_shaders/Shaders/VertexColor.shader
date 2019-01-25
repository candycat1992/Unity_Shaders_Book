Shader "Z/VertexColor"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct v2f{
                fixed4 color : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(float4 vertex: POSITION, fixed4 color: COLOR){
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.color = color;
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET{
                return  i.color;
            }
            ENDCG
        }
    }
}
