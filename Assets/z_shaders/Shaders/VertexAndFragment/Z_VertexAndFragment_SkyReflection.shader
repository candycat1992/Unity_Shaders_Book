// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Z/VertexAndFragmentu/Sky Reflection"
{
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
                half3 worldRefl: TEXCOORD0;
            };

            v2f vert(float4 vertex: POSITION, half3 nor: NORMAL)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                
                // compute world space position of the vertex
                half3 worldPos = mul(unity_ObjectToWorld, vertex).xyz;

                // compute world space view direction
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                // world space normal
                half3 worldNormal = UnityObjectToWorldNormal(nor);

                // world space reflection vector
                o.worldRefl = reflect (-worldViewDir, worldNormal);
                return o;
            }

            fixed4 frag(v2f i): SV_Target
            {
                // sample the default reflection cubemap, using the reflectionvector
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);

                // decode cubemap data into actural color
                half3 skyCol = DecodeHDR (skyData, unity_SpecCube0_HDR);

                // output it
                return fixed4(skyCol, 0);
            }
            ENDCG
            
        }
    }
}
