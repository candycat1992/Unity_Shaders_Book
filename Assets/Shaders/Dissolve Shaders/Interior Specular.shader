Shader "TestBed/Dissolve/Interior Specular"
{
	Properties
	{
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125

		_Burn("Burn Amount", Range(-0.25, 1.25)) = 0.0
		_LineWidth("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor("Burn Color", Color) = (1.0, 0.0, 0.0, 1.0)
		
		_MainTex("Main Texture", 2D) = "white"{}
		_BurnMap("Burn Map", 2D) = "white"{}
	}
	
    SubShader 
    {
    Cull off
     	Tags { "Queue" = "Transparent" }
     	Blend SrcAlpha OneMinusSrcAlpha
     	CGPROGRAM
     	#pragma surface surf BlinnPhong
     	
		sampler2D _MainTex;
		sampler2D _BurnMap;
			
		float4 _BurnColor;
		float _LineWidth;
		float _Burn;
		float _Shininess;
		
		struct Input 
     	{
     		half2 uv_MainTex;
     		half2 uv_BurnMap;
    	};
      
      	void surf (Input IN, inout SurfaceOutput o) 
      	{
      		half4 tex = tex2D(_MainTex, IN.uv_MainTex);
        	o.Albedo = tex.rgb;
        	half4 burn = tex2D(_BurnMap, IN.uv_BurnMap);
        	half4 clear = half4(0.0);
        	int isClear = max(0.0, int(burn.r - (_Burn+_LineWidth) + 0.99));
        	clear = lerp(_BurnColor, clear, isClear);
			o.Albedo = lerp(o.Albedo, clear, max(0.0,int(burn.r - _Burn + 0.99)));					
			
			o.Gloss = lerp(tex.a, 0.0, isClear);
        	
        	o.Alpha = lerp(1.0, 0.0, int(burn.r - (_Burn+_LineWidth) + 0.99));
        	
        	o.Specular = lerp(_Shininess, 0.0, isClear);

     	}
     	
     	ENDCG
    }
    Fallback "VertexLit"

}	
