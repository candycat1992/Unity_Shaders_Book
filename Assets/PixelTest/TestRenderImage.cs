using UnityEngine;  
using System.Collections;  

//[ExecuteInEditMode]  
public class TestRenderImage : MonoBehaviour {  
	
	#region Variables  
	public Shader curShader;  
//	public float grayScaleAmount = 1.0f;  
	private Material curMaterial; 
	public Texture2D RampTex;
	public int scale = 2;
	public bool useOrthographic = true;
	public float orthographicSize = 5; 
	public Color backColor = Color.gray;

	GameObject Chindcam;
	RenderTexture rt;


	#endregion  
	
	#region Properties  
	public Material material {  
		get {  
			if (curMaterial == null) {  
				curMaterial = new Material(curShader);  
				curMaterial.hideFlags = HideFlags.HideAndDontSave;  
			}  
			return curMaterial;  
		}  
	}  
	#endregion  
	
	// Use this for initialization  
	void Start () {  
		if (SystemInfo.supportsImageEffects == false) {  
			enabled = false;  
			return;  
		}  
		
		if (curShader != null && curShader.isSupported == false) {  
			enabled = false;  
		}
		rt = new RenderTexture (Screen.width / scale, Screen.height / scale, 1);
		rt.filterMode = FilterMode.Point;
		rt.name = "cam";
//		Chindcam = new GameObject ();
//		Chindcam.transform.parent = this.transform;
//		Chindcam.transform.localPosition = new Vector3 (0, 0, 0);
//		Chindcam.transform.localRotation = new Quaternion (0, 0, 0, 0);
//		Chindcam.AddComponent<Camera>();
//		maincamera = Chindcam.gameObject.GetComponent<Camera> ();
//		maincamera.targetTexture = rt;
//		maincamera.orthographic = useOrthographic;
//		maincamera.orthographicSize = orthographicSize;
//		maincamera.depth = 0;
//		maincamera.clearFlags = CameraClearFlags.SolidColor;
//		maincamera.backgroundColor = backColor;
	}  
	
	void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture){
		if (curShader != null) {  
			material.SetTexture("_Ramp", RampTex);

			Graphics.Blit(sourceTexture, destTexture, material);  
		} else {  
			Graphics.Blit(rt, destTexture);  
		}  
	}  
	
	// Update is called once per frame  
	void Update () {
//		maincamera.orthographicSize = orthographicSize;
	}  
	
	void OnDisable () {  
		if (curMaterial != null) {  
			DestroyImmediate(curMaterial);  
		} 
	}  
}  