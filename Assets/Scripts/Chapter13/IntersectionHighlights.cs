using UnityEngine;
using System.Collections;

public class IntersectionHighlights : PostEffectsBase {

	public Shader intersectionHighlightsShader;
	private Material intersectionHighlightstMaterial = null;
	public Material material {  
		get {
			intersectionHighlightstMaterial = CheckShaderAndCreateMaterial(intersectionHighlightsShader, intersectionHighlightstMaterial);
			return intersectionHighlightstMaterial;
		}  
	}
	
	void OnEnable() {
		GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
	}
	
	public override void CheckResources() {
		bool isSupported = CheckSupport();
		
		if (isSupported == false) {
			NotSupported();
		}
	} 
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			Graphics.Blit(src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
