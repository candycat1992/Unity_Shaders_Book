Shader "TestBed/Dissolve/Dissolve Detail"
{
	Properties
	{

		_Burn("Burn Amount", Range(-0.25, 1.25)) = 0.0
		_LineWidth("Burn Line Size", Range(0.0, 0.2)) = 0.1
		_BurnColor("Burn Color", Color) = (1.0, 0.0, 0.0, 1.0)
		
		_MainTex("Main Texture", 2D) = "white"{}
		
		_BumpMap("Bump Map", 2D) = "bump"{}
		
		_BurnMap("Burn Map", 2D) = "white"{}
		
		_BurnBump("Burn Bump Map", 2D) = "bump"{}
	}
	
	 SubShader 
    {
    
     	Tags { "Queue" = "Transparent" }
//     	ZWrite Off
//     	Blend SrcAlpha OneMinusSrcAlpha
     	CGPROGRAM
     	#pragma surface surf Lambert alpha:blend
     	
		sampler2D _MainTex;
		sampler2D _BurnMap;
		sampler2D _BumpMap;
		sampler2D _BurnBump;
			
		float4 _BurnColor;
		float _LineWidth;
		float _Burn;
		
		struct Input 
     	{
     		half2 uv_MainTex;
     		half2 uv_BurnMap;
     		half2 uv_BumpMap;
     		half2 uv_BurnBump;
    	};
      
      	void surf (Input IN, inout SurfaceOutput o) 
      	{
     	 	half4 tex = tex2D(_MainTex, IN.uv_MainTex);  
        	o.Albedo = tex.rgb;
        	half3 burn = tex2D(_BurnMap, IN.uv_BurnMap).rgb;
        	half3 clear = half3(0.0);
        	        	
          	int isClear = int(burn.r - (_Burn+_LineWidth) + 0.99);

        	clear = lerp(_BurnColor, clear, isClear);
			
			o.Albedo = lerp(o.Albedo, clear, int(burn.r - _Burn + 0.99));					
       		o.Normal = lerp(UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap)), UnpackNormal (tex2D (_BurnBump, IN.uv_BurnBump)),int(burn.r - _Burn + 0.99));
        	o.Alpha = lerp(1.0, 0.0, int(burn.r - (_Burn+_LineWidth) + 0.99));
        	
     	}
     	
     	ENDCG
    }
    Fallback "VertexLit"

}