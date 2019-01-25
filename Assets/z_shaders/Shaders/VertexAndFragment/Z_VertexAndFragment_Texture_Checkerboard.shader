Shader "Z/VertexAndFragmentu/Texture/Checkerboard"
{
    Properties
    {
        _ColorA ("Color A", Color) = (1, 1, 0, 1)
        _ColorB ("Color B", Color) = (1, 0, 1, 1)
        [Space]
        _Density ("Density", Range(2, 50)) = 30
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            // #include "UnityCG.cginc"
            struct v2f
            {
                float2 uv: TEXCOORD0;
                float4 pos: SV_POSITION;
            };

            float _Density;
            fixed4 _ColorA;
            fixed4 _ColorB;

            v2f vert(float4 vertex: POSITION, float2 uv: TEXCOORD0)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.uv = uv * _Density;
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                float2 c = i.uv;
                c = floor(c) / 2;
                float checker = frac(c.x + c.y) * 2;

                return lerp(_ColorA, _ColorB, checker);
            }
            ENDCG
            
        }
    }
}
