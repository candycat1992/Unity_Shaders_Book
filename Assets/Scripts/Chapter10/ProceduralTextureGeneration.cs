using UnityEngine;
using System.Collections;

public class ProceduralTextureGeneration : MonoBehaviour {

	public int textureWidth = 512;
	public Material material = null;
	public Color backgroundColor = Color.white;
	public Color circleColor = Color.yellow;

	private Texture2D generatedTexture = null;

	// Use this for initialization
	void Start () {
		if (material == null) {
			Renderer renderer = gameObject.GetComponent<Renderer>();
			if (renderer == null) {
				Debug.LogWarning("Cannot find a renderer.");
				return;
			}

			material = renderer.material;
		}

		if (material != null) {
			generatedTexture = _GenerateProceduralTexture();
			material.SetTexture("_MainTex", generatedTexture);
		}
	}

	private Color _MixColor(Color color0, Color color1, float mixFactor) {
		Color mixColor = Color.white;
		mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
		mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
		mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
		mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
		return mixColor;
	}

	private Texture2D _GenerateProceduralTexture() {
		Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);

		for (int w = 0; w < textureWidth; w++) {
			for (int h = 0; h < textureWidth; h++) {
				Color pixel = backgroundColor;

				for (int i = 0; i < 3; i++) {
					for (int j = 0; j < 3; j++) {
						Vector2 circleCenter = new Vector2(textureWidth / 4.0f * (i + 1), textureWidth / 4.0f * (j + 1));

						float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - textureWidth / 10.0f;

						Color color = _MixColor(circleColor, new Color(backgroundColor.r, backgroundColor.g, backgroundColor.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist/2.0f));
						pixel = _MixColor(pixel, color, color.a);
//						Debug.Log(color);
					}
				}

				proceduralTexture.SetPixel(w, h, pixel);
			}
		}

		proceduralTexture.Apply();

		return proceduralTexture;
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
