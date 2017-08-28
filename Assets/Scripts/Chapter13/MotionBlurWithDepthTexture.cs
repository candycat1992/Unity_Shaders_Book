using UnityEngine;
using System.Collections;

public class MotionBlurWithDepthTexture : PostEffectsBase {

	public Shader motionBlurShader;
	private Material motionBlurMaterial = null;

	public Material Material {  
		get {
			motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
			return motionBlurMaterial;
		}  
	}

	private Camera myCamera;
	public Camera MyCamera {
		get {
			if (myCamera == null) {
				myCamera = GetComponent<Camera>();
			}
			return myCamera;
		}
	}

	[Range(0.0f, 1.0f)]
	public float blurSize = 0.5f;

	private Matrix4x4 previousViewProjectionMatrix;
	
	void OnEnable() {
		MyCamera.depthTextureMode |= DepthTextureMode.Depth;

		previousViewProjectionMatrix = MyCamera.projectionMatrix * MyCamera.worldToCameraMatrix;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (Material != null) {
			Material.SetFloat("_BlurSize", blurSize);

			Material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
			Matrix4x4 currentViewProjectionMatrix = MyCamera.projectionMatrix * MyCamera.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
			Material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit (src, dest, Material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
