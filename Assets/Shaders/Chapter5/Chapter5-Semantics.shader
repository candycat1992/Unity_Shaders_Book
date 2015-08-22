Shader "Unity Shader Book/Chapter5-Semantics" {
	Properties {
		_MainTex ("h", 2D) = "white" {}
	}
	SubShader {
        Pass {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            sampler2D _MainTex;

			struct a2v {
                float4 vertex : POSITION;
				fixed4 color : COLOR;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                half3 color0 : COLOR0;
                float3 color1 : COLOR1;
            };
            
            v2f vert(a2v v) : SV_POSITION {
            	v2f o;
            	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            	o.color0 = half3(100000, 100000, 100000);
            	o.color1 = float3(0.0, 0.0, 0.0);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(0.0/0.0,0.0/0.0, 0.0/0.0, 1.0);
			}

            ENDCG
        }
    }
}
