Shader "Z/Semantics/Vertex ID"
{
    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5

            struct v2f
            {
                fixed4 color: TEXCOORD0;
                float4 pos: SV_POSITION;
            };

            v2f vert(float4 vertex: POSITION, uint vid: SV_VERTEXID)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                float f = (float) vid;
                o.color = half4(sin(f / 10), sin(f / 100), sin(f / 1000), 0) * 0.5 + 0.5;
                return o;
            }

            

            fixed4 frag(v2f i): SV_Target
            {
                return i.color;
            }
            ENDCG
            
        }
    }
}
