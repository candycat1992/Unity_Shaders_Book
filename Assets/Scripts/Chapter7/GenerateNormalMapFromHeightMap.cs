using UnityEngine;
using System.Collections;

public class GenerateNormalMapFromHeightMap : MonoBehaviour {

	private Texture2D m_heightMap;
	private Texture2D m_normalMap;

	// Use this for initialization
	void Start () {
		Renderer renderer =  gameObject.GetComponent<Renderer>();
		if (renderer == null) {
			return;
		}

		Material material = renderer.material;
		if (material == null) {
			return;
		}

		m_heightMap = material.GetTexture("_HeightMap") as Texture2D;
		if (m_heightMap == null) {
			return;
		}

		m_normalMap = new Texture2D(m_heightMap.width, m_heightMap.height, TextureFormat.ARGB32, false);

		float xLeft = 0.0f;
		float xRight = 0.0f;
		float yUp = 0.0f;
		float yDown = 0.0f;
		float xDelta = 0.0f;
		float yDelta = 0.0f;
		for (int r = 0; r < m_heightMap.height; r++) {
			for (int c = 0; c < m_heightMap.width; c++) {
				xLeft = m_heightMap.GetPixel(r - 1, c).grayscale;
				xRight = m_heightMap.GetPixel(r + 1, c).grayscale;
				yUp = m_heightMap.GetPixel(r, c - 1).grayscale;
				yDown = m_heightMap.GetPixel(r, c + 1).grayscale;
				xDelta = ((xLeft - xRight) + 1.0f) * 0.5f;
				yDelta = ((yUp - yDown) + 1.0f) * 0.5f;
				
				m_normalMap.SetPixel(r, c,new Color(xDelta, yDelta, 1.0f, 1.0f));	
			}
		}
		
		m_normalMap.Apply();
		material.SetTexture("_HeightMap", m_normalMap);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
