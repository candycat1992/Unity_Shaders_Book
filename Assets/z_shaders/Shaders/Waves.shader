Shader "Z/Waves"
{
    Properties
    {
        _Color ("Color", Color) = (0, 0, 0, 1)
        _Strength ("Strength", Range(0, 2)) = 1
        _Speed ("Speed", Range(-200, 200)) = 100
    }
    SubShader
    {
        Tags { "RenderType" = "transparent" }

        Pass
        {
            Cull Off
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            fixed4 _Color;

            struct vertexInput
            {
                float2 uv: TEXCOORD0;
                float4 vertex: POSITION;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            float _Strength;
            float _Speed;

            v2f vert(vertexInput v)
            {
                v2f o;
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float displacement = cos(worldPos.y) + cos(worldPos.x + (_Speed * _Time));
                worldPos.y += displacement * _Strength;

                o.pos = mul(UNITY_MATRIX_VP, worldPos);
                o.uv = v.uv;
                // o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i): SV_TARGET
            {
                return _Color ;
            }
            
            ENDHLSL
            
        }
    }

    Fallback "Default"
}
