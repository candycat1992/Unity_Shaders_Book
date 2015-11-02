// Simplified Skybox shader. Differences from regular Skybox one:
// - no tint color

Shader "Mobile/Skybox" {
Properties {
	_FrontTex ("Front (+Z)", 2D) = "white" {}
	_BackTex ("Back (-Z)", 2D) = "white" {}
	_LeftTex ("Left (+X)", 2D) = "white" {}
	_RightTex ("Right (-X)", 2D) = "white" {}
	_UpTex ("Up (+Y)", 2D) = "white" {}
	_DownTex ("Down (-Y)", 2D) = "white" {}
}

SubShader {
	Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
	Cull Off ZWrite Off Fog { Mode Off }
	Pass {
		SetTexture [_FrontTex] { combine texture }
	}
	Pass {
		SetTexture [_BackTex]  { combine texture }
	}
	Pass {
		SetTexture [_LeftTex]  { combine texture }
	}
	Pass {
		SetTexture [_RightTex] { combine texture }
	}
	Pass {
		SetTexture [_UpTex]    { combine texture }
	}
	Pass {
		SetTexture [_DownTex]  { combine texture }
	}
}
}
