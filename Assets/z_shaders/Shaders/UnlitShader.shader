// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Z/UnlitShader"
{
    Properties { 
        _Color("Color", Color) = (1,1,1,1)
        _VertexOffset("Offset",  Range(0,10)) =0
        _AnimationSpeed("_AnimationSpeed", Range(0,10)) =0
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex: POSITION;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
            };

            fixed4 _Color;
            fixed _VertexOffset;
            fixed _AnimationSpeed;

            v2f vert(appdata v)
            {
                v2f o;
                v.vertex.x += sin(_Time.y * _AnimationSpeed + v.vertex.y * _VertexOffset);
                o.pos = UnityObjectToClipPos(v.vertex);
                // o.pos += _VertexOffset2;
                return o;
            }

            float4 frag (v2f i): SV_TARGET{
                return _Color;
            }
            ENDCG
            
        }
    }
}
