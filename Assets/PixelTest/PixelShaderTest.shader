// Shader created with Shader Forge v1.16 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.16;sub:START;pass:START;ps:flbk:,iptp:0,cusa:True,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,ofsf:0,ofsu:0,f2p0:False;n:type:ShaderForge.SFN_Final,id:3138,x:33495,y:32773,varname:node_3138,prsc:2|emission-717-RGB;n:type:ShaderForge.SFN_Tex2d,id:20,x:31684,y:32658,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_20,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Tex2d,id:717,x:32732,y:32808,varname:node_717,prsc:2,tex:7a5f22fc6b7d94d599a544ecd9eb1bf3,ntxv:0,isnm:False|UVIN-1247-OUT,TEX-2201-TEX;n:type:ShaderForge.SFN_Append,id:1247,x:32414,y:32762,varname:node_1247,prsc:2|A-5582-OUT,B-5582-OUT;n:type:ShaderForge.SFN_Add,id:9835,x:31870,y:32681,varname:node_9835,prsc:2|A-20-R,B-20-G,C-20-B;n:type:ShaderForge.SFN_Divide,id:5582,x:32201,y:32742,varname:node_5582,prsc:2|A-9835-OUT,B-4482-OUT;n:type:ShaderForge.SFN_Vector1,id:4482,x:31870,y:32853,varname:node_4482,prsc:2,v1:3;n:type:ShaderForge.SFN_Tex2dAsset,id:2201,x:32414,y:32974,ptovrint:False,ptlb:Ramp,ptin:_Ramp,varname:node_2201,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,tex:7a5f22fc6b7d94d599a544ecd9eb1bf3,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Multiply,id:3443,x:32940,y:32744,varname:node_3443,prsc:2|A-20-RGB,B-717-RGB;proporder:20-2201;pass:END;sub:END;*/

Shader "Shader Forge/PixelShaderTest" {
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _Ramp ("Ramp", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
            "CanUseSpriteAtlas"="True"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma exclude_renderers gles3 metal d3d11_9x xbox360 xboxone ps3 ps4 psp2 
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform sampler2D _Ramp; uniform float4 _Ramp_ST;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
/////// Vectors:
////// Lighting:
////// Emissive:
				float2 uv = TRANSFORM_TEX(i.uv0, _MainTex);
				uv = uv * _ScreenParams.xy;
//                o.uv0 = (floor(o.uv0 + 0.5) + 0.5);
                uv = floor(uv / 3.0) * 3.0 + 0.5;
                uv = uv /_ScreenParams.xy;
                float4 _MainTex_var = tex2D(_MainTex,uv);
                float node_5582 = ((_MainTex_var.r+_MainTex_var.g+_MainTex_var.b)/3.0);
                float2 node_1247 = float2(node_5582,node_5582);
                float4 node_717 = tex2D(_Ramp,TRANSFORM_TEX(node_1247, _Ramp));
                float3 emissive = node_717.rgb;
                float3 finalColor = emissive;
//                return fixed4(uv.x);
                return fixed4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
