////////////////////////////////////////////////////////////////////////////////////
//  CAMERA FILTER PACK - by VETASOFT 2014 //////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[AddComponentMenu ("PengLu/image effect/Refracion")]
public class image_effect_Refraction : MonoBehaviour {
	#region Variables
	public Shader SRefraShader;
	private Material SCMaterial;
	public Texture2D BumpMap;
	[Range(0.0f, 1.0f)]
	public float SatCount = 0.5f;

	public static Texture2D ChangeBumpMap;
	public static float ChangeSatCount;
	#endregion
	
	#region Properties
	Material material
	{
		get
		{
			if(SCMaterial == null)
			{
				SCMaterial = new Material(SRefraShader);
				SCMaterial.hideFlags = HideFlags.HideAndDontSave;	
			}
			return SCMaterial;
		}
	}
	#endregion
	void Start () 
	{
		ChangeBumpMap = BumpMap;
		ChangeSatCount = SatCount;
	
		SRefraShader = Shader.Find("PengLu/image effect/Refraction");

		if(!SystemInfo.supportsImageEffects)
		{
			enabled = false;
			return;
		}
	}
	
	void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
	{
		if (SRefraShader != null)
		{

			material.SetTexture("_BumpMap", BumpMap);
			material.SetFloat("_SatCount", SatCount);

	
			Graphics.Blit(sourceTexture, destTexture, material);
		}
		else
		{
			Graphics.Blit(sourceTexture, destTexture);
		}
		
		
	}
	
	// Update is called once per frame
	void Update () 
	{
		if (Application.isPlaying)
		{
			BumpMap = ChangeBumpMap;
			SatCount = ChangeSatCount;

		}
		#if UNITY_EDITOR
		if (Application.isPlaying!=true)
		{
			SRefraShader = Shader.Find("PengLu/image effect/Refraction");

		}
		#endif

	}
	
	void OnDisable ()
	{
		if(SCMaterial)
		{
			DestroyImmediate(SCMaterial);	
		}
		
	}
	
	
}