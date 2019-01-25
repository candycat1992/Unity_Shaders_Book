Shader "Z/VertexAndFragmentu/Single Color"
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
            
            fixed4 _Color;

            float4 vert(float4 vertex: POSITION): SV_POSITION
            {
                return UnityObjectToClipPos(vertex); ;
            }

            fixed4 frag(): SV_Target
            {
                return _Color;
            }
            ENDCG
            
        }
    }
}
