Shader "TestBed/Dissolve/Interior Diffuse Texture"
{
	Properties
	{
		_Burn("Burn Amount", Range(-0.25, 1.25)) = 0.0
		_LineWidth("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor("Burn Color", Color) = (1.0, 0.0, 0.0, 1.0)
		
		_MainTex("Main Texture", 2D) = "white"{}
		_BurnTex("Burn Texture", 2D) = "white"{}
		_BurnMap("Burn Map", 2D) = "white"{}
	}
	
    SubShader 
    {
    
    	Cull off
     	Tags { "Queue" = "Transparent" }
     	Blend SrcAlpha OneMinusSrcAlpha
     	CGPROGRAM
     	#pragma surface surf Lambert
     	
		sampler2D _MainTex;
		sampler2D _BurnMap;
		sampler2D _BurnTex;
			
		float4 _BurnColor;
		float _LineWidth;
		float _Burn;
			
		struct Input 
     	{
     		half2 uv_MainTex;
     		half2 uv_BurnMap;
    		half2 uv_BurnTex;
    	};
      
      	void surf (Input IN, inout SurfaceOutput o) 
      	{
        	o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
        	half4 burn = tex2D(_BurnMap, IN.uv_BurnMap);
        	half4 clear = half4(0.0);
        	half4 burnTex = tex2D(_BurnTex, IN.uv_MainTex);
        	
        	clear = lerp(burnTex*_BurnColor, clear, max(0.0, int(burn.r - (_Burn+_LineWidth) + 0.99)));
			o.Albedo = lerp(o.Albedo, clear, max(0.0,int(burn.r - _Burn + 0.99)));					
        					
        	o.Alpha = lerp(1.0, 0.0, int(burn.r - (_Burn+_LineWidth) + 0.99));
     	}
     	
     	ENDCG
    }
    Fallback "VertexLit"

}	
