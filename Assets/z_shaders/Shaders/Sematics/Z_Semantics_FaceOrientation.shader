Shader "Z/Semantics/Face Orientation"
{
    Properties
    {
        _ColorFront ("Front Color", Color) = (1, 0, 0, 1)
        _ColorBack ("Back Color", Color) = (0, 1, 0, 1)
    }

    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            float4 vert(float4 vertex: POSITION): SV_POSITION
            {
                return  UnityObjectToClipPos(vertex);
            }

            fixed4 _ColorFront;
            fixed4 _ColorBack;

            fixed4 frag(fixed facing: VFACE): SV_Target
            {
                return facing > 0? _ColorFront: _ColorBack;
            }
            ENDCG
            
        }
    }
}
