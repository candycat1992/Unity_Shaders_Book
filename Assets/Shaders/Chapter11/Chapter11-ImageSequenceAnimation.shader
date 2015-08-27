Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation" {
	Properties {
		_TintColor ("Tint Color", Color) = (1, 1, 1, 1)  
		_MainTex ("Image Sequence", 2D) = "white" {}
    	_SizeX ("SizeX", Float) = 4  
    	_SizeY ("SizeY", Float) = 4  
    	_Speed ("Speed", Float) = 200  
	}
	SubShader {  
        Pass {
        	Tags { "LightMode"="ForwardBase" }
        	
           	Blend SrcAlpha One
           
            CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
            #pragma multi_compile_particles  
 
            #include "UnityCG.cginc"  
  
            sampler2D _MainTex;  
            float4 _MainTex_ST;
            fixed4 _TintColor;  
            fixed _SizeX;  
            fixed _SizeY;  
            fixed _Speed;  
              
            struct appdata_t {  
                float4 vertex : POSITION;  
                fixed4 color : COLOR;  
                float2 texcoord : TEXCOORD0;  
            };  
  
            struct v2f {  
                float4 pos : SV_POSITION;  
                fixed4 color : COLOR;  
                float2 uv : TEXCOORD0;  
            };  
            
            v2f vert (appdata_t v) {  
                v2f o;  
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);  
                o.color = v.color;  
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  
                return o;
            }  

            fixed4 frag (v2f i) : SV_Target {  
                int indexX=fmod (_Time.x * _Speed, _SizeX);  
                int indexY=fmod ((_Time.x * _Speed) / _SizeX, _SizeY);  
  
                fixed2 seqUV = float2((i.uv.x) /_SizeX, (i.uv.y)/_SizeY);  
                seqUV.x += indexX/_SizeX;  
                seqUV.y -= indexY/_SizeY;  
                return _TintColor * tex2D(_MainTex, seqUV);  
            }  
            ENDCG   
        }  
	} 
	FallBack "Diffuse"
}
