// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Z/Coverage"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _OverlayTex ("Overlay Texture", 2D) = "" { }
        _Direction ("Direction", Vector) = (0, 1, 0)
        _Intensity ("Intensity", Range(0, 1)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            // make fog work
            #pragma multi_compile_fog

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
                float2 uv_Overlay: TEXCOORD1;
                float4 vertex: SV_POSITION;
                float3 normal: NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _OverlayTex;
            float4 _OverlayTex_ST;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_Overlay = TRANSFORM_TEX(v.uv, _OverlayTex);
                o.normal = mul(unity_ObjectToWorld, v.normal);
                return o;
            }


            float3 _Direction;
            fixed _Intensity;

            fixed4 frag(v2f i): SV_Target
            {
                // sample the texture
                fixed dir = dot(normalize(i.normal), _Direction)* _Intensity;
                // if (dir < 1 - _Intensity)
                // {
                //     dir = 0;
                // }

                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 colOverlay = tex2D(_OverlayTex, i.uv);
                return lerp(col, colOverlay,clamp( dir,0,1));
            }
            ENDCG
            
        }
    }
}
