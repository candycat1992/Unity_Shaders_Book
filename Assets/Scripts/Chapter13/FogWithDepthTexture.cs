using UnityEngine;
using System.Collections;

public class FogWithDepthTexture : PostEffectsBase {

	public Shader fogShader;
	private Material fogMaterial = null;

	public Material Material {  
		get {
			fogMaterial = CheckShaderAndCreateMaterial(fogShader, fogMaterial);
			return fogMaterial;
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

	private Transform myCameraTransform;
	public Transform CameraTransform {
		get {
			if (myCameraTransform == null) {
				myCameraTransform = MyCamera.transform;
			}

			return myCameraTransform;
		}
	}

	[Range(0.0f, 3.0f)]
	public float fogDensity = 1.0f;

	public Color fogColor = Color.white;

	public float fogStart = 0.0f;
	public float fogEnd = 2.0f;

	void OnEnable() {
		MyCamera.depthTextureMode |= DepthTextureMode.Depth;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (Material != null) {
			Matrix4x4 frustumCorners = Matrix4x4.identity;

			float fov = MyCamera.fieldOfView;
			float near = MyCamera.nearClipPlane;
			float aspect = MyCamera.aspect;

			float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
			Vector3 toRight = CameraTransform.right * halfHeight * aspect;
			Vector3 toTop = CameraTransform.up * halfHeight;

			Vector3 topLeft = CameraTransform.forward * near + toTop - toRight;
			float scale = topLeft.magnitude / near;

			topLeft.Normalize();
			topLeft *= scale;

			Vector3 topRight = CameraTransform.forward * near + toRight + toTop;
			topRight.Normalize();
			topRight *= scale;

			Vector3 bottomLeft = CameraTransform.forward * near - toTop - toRight;
			bottomLeft.Normalize();
			bottomLeft *= scale;

			Vector3 bottomRight = CameraTransform.forward * near + toRight - toTop;
			bottomRight.Normalize();
			bottomRight *= scale;

			frustumCorners.SetRow(0, bottomLeft);
			frustumCorners.SetRow(1, bottomRight);
			frustumCorners.SetRow(2, topRight);
			frustumCorners.SetRow(3, topLeft);

			Material.SetMatrix("_FrustumCornersRay", frustumCorners);

			Material.SetFloat("_FogDensity", fogDensity);
			Material.SetColor("_FogColor", fogColor);
			Material.SetFloat("_FogStart", fogStart);
			Material.SetFloat("_FogEnd", fogEnd);

			Graphics.Blit (src, dest, Material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
