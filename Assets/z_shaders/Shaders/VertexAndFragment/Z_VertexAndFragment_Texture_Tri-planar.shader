Shader "Z/VertexAndFragmentu/Texture/Tri-planar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _OcclusionMap ("Occlusion", 2D) = "white" { }
        [Spcace]
        _Tiling ("Tiling", Float) = 1
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
                half3 objNormal: TEXCOORD0;
                float3 coords: TEXCOORD1;
                float2 uv: TEXCOORD2;
                float4 pos: SV_POSITION;
            };

            float _Tiling;

            v2f vert(float4 vertex: POSITION, half3 normal: NORMAL, float2 uv: TEXCOORD0)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vertex);
                o.coords = vertex.xyz * _Tiling;
                o.objNormal = normal;
                o.uv = uv ;
                return o;
            }
            sampler2D _MainTex;
            sampler2D _OcclusionMap;

            fixed4 frag(v2f i): SV_Target
            {
                // use absolute value of normal as texture weights
                half3 blend = abs(i.objNormal);

                // make sure the weights sum up to 1 (divide by sum of x+y+z)
                blend /= dot(blend, 1.0);

                // read the three texture projections, for x,y,z axes

                fixed4 cx = tex2D(_MainTex, i.coords.yz);
                fixed4 cy = tex2D(_MainTex, i.coords.xz);
                fixed4 cz = tex2D(_MainTex, i.coords.xy);
                
                // blend the textures based on weights
                fixed4 c = cx * blend.x + cy * blend.y + cz * blend.z;

                // modulate by reqular occlusion map
                c *= tex2D(_OcclusionMap, i.uv);
                return c;
            }
            ENDCG
            
        }
    }
}
