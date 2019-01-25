Shader "Z/VertexAndFragmentu/Mesh Normal"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            struct v2f
            {
                float4 pos: SV_POSITION;
                half3 worldNormal: TEXCOORD0;
            };

            fixed4 _Color;

            v2f vert(float4 vertex: POSITION, half3 nor: NORMAL)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.worldNormal = UnityObjectToWorldNormal(nor);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                return fixed4(i.worldNormal * 0.5 + 0.5, 0);
            }
            ENDCG
            
        }
    }
}
