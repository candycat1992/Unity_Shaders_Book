Shader "Unity Shaders Book/Chapter 3/MyShader" {
	Properties {
		// Numbers and Sliders
		_Int ("Int", Int) = 2
		_Float ("Float", Float) = 1.5
		_Range("Range", Range(0.0, 5.0)) = 3.0
		// Colors and Vectors
		_Color ("Color", Color) = (1,1,1,1)
		_Vector ("Vector", Vector) = (2, 3, 6, 1)
		// Textures
		_2D ("2D", 2D) = "" {}
		_Cube ("Cube", Cube) = "white" {}
		_3D ("3D", 3D) = "black" {}
	}

	SubShader {				
		Pass {
		}
	}

	FallBack "Diffuse"
}
