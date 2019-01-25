// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Z/VertexAndFragmentu/Sky Reflection Per Pixel"
{
    Properties
    {
        [NoScaleOffset]   _BumpMap ("Normal Map", 2D) = "bump" { }
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
                half3 worldPos: TEXCOORD0;

                // these three vectors will hold a 3x3 rotation matrix
                // that transforms from tangent to world space
                half3 tspace0: TEXCOORD1; // tangent.x, bitanget.x, normal.x
                half3 tspace1: TEXCOORD2; // tangent.y, bitanget.y, normal.y
                half3 tspace2: TEXCOORD3; // tangent.z, bitanget.z, normal.z

                // texture coordinate for the normal map
                half2 uv: TEXCOORD4;
            };

            v2f vert(float4 vertex: POSITION, half3 nor: NORMAL, float4 tangent: TANGENT, float2 uv: TEXCOORD0)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                
                // compute world space position of the vertex
                o.worldPos = mul(unity_ObjectToWorld, vertex).xyz;

                // world space normal
                half3 wNormal = UnityObjectToWorldNormal(nor);
                half3 wTangent = UnityObjectToWorldDir(tangent.xyz);

                // compute bitangent from cross product of normal and tangent
                half tangentSign = tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
                o.uv = uv;
                return o;
            }
            
            sampler2D _BumpMap;
            fixed4 frag(v2f i): SV_Target
            {
                // Sample the normal map, and decode from the Unity encoding
                half3 tNormal = UnpackNormal(tex2D(_BumpMap, i.uv));

                // transform normal from tangent to world space
                half3 wNormal;
                wNormal.x = dot(i.tspace0, tNormal);
                wNormal.y = dot(i.tspace1, tNormal);
                wNormal.z = dot(i.tspace2, tNormal);

                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                half3 worldRefl = reflect(-worldViewDir, wNormal);

                // sample the default reflection cubemap, using the reflectionvector
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, worldRefl);

                // decode cubemap data into actural color
                half3 skyCol = DecodeHDR(skyData, unity_SpecCube0_HDR);

                // output it
                return fixed4(skyCol, 0);
            }
            ENDCG
            
        }
    }
}
