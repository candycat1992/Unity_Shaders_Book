Shader "Z/Surface Shader Lighting/Toon Ramp"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" { }
        _Ramp ("Toon Ramp", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        
        CGPROGRAM
        
        #pragma surface surf Ramp

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        sampler2D _Ramp;
        half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten)
        {
            half ndotl = dot(s.Normal, lightDir);
            half diff = ndotl * 0.5 + 0.5;
            half3 ramp = tex2D(_Ramp, float2(diff, diff)).rgb;

            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;
            c.a = s.Alpha;
            return c;
        }

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };


        void surf(Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
        }
        ENDCG
        
    }
    FallBack "Diffuse"
}
