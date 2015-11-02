Shader "Mobile/Transparent/Vertex Color" {  
    Properties {  
        _Color ("Main Color", Color) = (1,1,1,1)  
        _SpecColor ("Spec Color", Color) = (1,1,1,0)  
        _Emission ("Emmisive Color", Color) = (0,0,0,0)  
        _Shininess ("Shininess", Range (0.1, 1)) = 0.7  
        _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}  
    }  
      
    Category {  
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}  
        ZWrite Off  
        Alphatest Greater 0  
        Blend SrcAlpha OneMinusSrcAlpha   
        SubShader {  
            Material {  
                Diffuse [_Color]  
                Ambient [_Color]  
                Shininess [_Shininess]  
                Specular [_SpecColor]  
                Emission [_Emission]      
            }  
            Pass {  
                ColorMaterial AmbientAndDiffuse  
                Fog { Mode Off }  
                Lighting Off  
                SeparateSpecular On  
                SetTexture [_MainTex] {  
                Combine texture * primary, texture * primary  
            }  
            SetTexture [_MainTex] {  
                constantColor [_Color]  
                Combine previous * constant, previous * constant  
            }    
            }  
        }   
    }  
}  