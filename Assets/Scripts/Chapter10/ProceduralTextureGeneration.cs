using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class ProceduralTextureGeneration : MonoBehaviour {

	public Material material = null;

	#region Material properties
	[SerializeField, SetProperty("textureWidth")]
	private int m_textureWidth = 512;
	public int textureWidth {
		get {
			return m_textureWidth;
		}
		set {
			m_textureWidth = value;
			_UpdateMaterial();
		}
	}

	[SerializeField, SetProperty("backgroundColor")]
	private Color m_backgroundColor = Color.white;
	public Color backgroundColor {
		get {
			return m_backgroundColor;
		}
		set {
			m_backgroundColor = value;
			_UpdateMaterial();
		}
	}

	[SerializeField, SetProperty("circleColor")]
	private Color m_circleColor = Color.yellow;
	public Color circleColor {
		get {
			return m_circleColor;
		}
		set {
			m_circleColor = value;
			_UpdateMaterial();
		}
	}

	[SerializeField, SetProperty("blurFactor")]
	private float m_blurFactor = 2.0f;
	public float blurFactor {
		get {
			return m_blurFactor;
		}
		set {
			m_blurFactor = value;
			_UpdateMaterial();
		}
	}
	#endregion

	private Texture2D m_generatedTexture = null;

	// Use this for initialization
	void Start () {
		if (material == null) {
			Renderer renderer = gameObject.GetComponent<Renderer>();
			if (renderer == null) {
				Debug.LogWarning("Cannot find a renderer.");
				return;
			}

			material = renderer.sharedMaterial;
		}

		_UpdateMaterial();
	}

	private void _UpdateMaterial() {
		if (material != null) {
			m_generatedTexture = _GenerateProceduralTexture();
			material.SetTexture("_MainTex", m_generatedTexture);
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

		// The interval between circles
		float circleInterval = textureWidth / 4.0f;
		// The radius of circles
		float radius = textureWidth / 10.0f;
		// The blur factor
		float edgeBlur = 1.0f / blurFactor;

		for (int w = 0; w < textureWidth; w++) {
			for (int h = 0; h < textureWidth; h++) {
				// Initalize the pixel with background color
				Color pixel = backgroundColor;

				// Draw nine circles one by one
				for (int i = 0; i < 3; i++) {
					for (int j = 0; j < 3; j++) {
						// Compute the center of current circle
						Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));

						// Compute the distance between the pixel and the center
						float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;

						// Blur the edge of the circle
						Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 0.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));

						// Mix the current color with the previous color
						pixel = _MixColor(pixel, color, color.a);
					}
				}

				proceduralTexture.SetPixel(w, h, pixel);
			}
		}

		proceduralTexture.Apply();

		return proceduralTexture;
	}
}
