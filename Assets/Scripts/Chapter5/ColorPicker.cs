/// <summary>
/// Author: Lele Feng 
/// </summary>

using UnityEngine;
using System.Collections;

public class ColorPicker : MonoBehaviour {
	
	public BoxCollider collider;

	private bool m_grab;
	private Camera m_camera;
	private Texture2D m_screenRenderTexture;
	private static Texture2D m_staticRectTexture;
	private static GUIStyle m_staticRectStyle;

	private static Vector3 _pixelPosition = Vector3.zero;
	private Color _pickedColor = Color.white;

	void Awake() {
		// Get the Camera component
		m_camera = GetComponent<Camera>();
		if (m_camera == null) {
			Debug.LogError("You need to dray this script to a camera!");
			return;
		}

		// Attach a BoxCollider to this camera
		// In order to receive mouse events
		if (collider == null) {
			collider = gameObject.AddComponent<BoxCollider>();
			// Make sure the collider is in the camera's frustum
			collider.center = Vector3.zero;
			collider.center += m_camera.transform.worldToLocalMatrix.MultiplyVector(m_camera.transform.forward) * (m_camera.nearClipPlane + 0.2f);
			collider.size = new Vector3(Screen.width, Screen.height, 0.1f);
		}
	}

	// Draw the color we picked
	public static void GUIDrawRect( Rect position, Color color )
	{
		if( m_staticRectTexture == null )
		{
			m_staticRectTexture = new Texture2D(1, 1);
		}
		
		if( m_staticRectStyle == null )
		{
			m_staticRectStyle = new GUIStyle();
		}
		
		m_staticRectTexture.SetPixel(0, 0, color);
		m_staticRectTexture.Apply();
		
		m_staticRectStyle.normal.background = m_staticRectTexture;
		
		GUI.Box(position, GUIContent.none, m_staticRectStyle);
	}

	// OnPostRender is called after a camera has finished rendering the scene.
	// This message is sent to all scripts attached to the camera.
	// Use it to grab the screen
	// Note: grabing is a expensive operation
	void OnPostRender() {
		if (m_grab) {
			m_screenRenderTexture = new Texture2D(Screen.width, Screen.height);
			m_screenRenderTexture.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
			m_screenRenderTexture.Apply();
			_pickedColor = m_screenRenderTexture.GetPixel(Mathf.FloorToInt(_pixelPosition.x), Mathf.FloorToInt(_pixelPosition.y));
			m_grab = false;
		}
	}
	
	void OnMouseDown() {
		m_grab = true;
		// Record the mouse position to pick pixel
		_pixelPosition = Input.mousePosition;
	}

	void OnGUI() {
		GUI.Box(new Rect(0, 0, 120, 200), "Color Picker");
		GUIDrawRect(new Rect(20, 30, 80, 80), _pickedColor);
		GUI.Label(new Rect(10, 120, 100, 20), "R: " + System.Math.Round((double)_pickedColor.r, 4) + "\t(" + Mathf.FloorToInt(_pickedColor.r * 255)+ ")");
		GUI.Label(new Rect(10, 140, 100, 20), "G: " + System.Math.Round((double)_pickedColor.g, 4) + "\t(" + Mathf.FloorToInt(_pickedColor.g * 255)+ ")");
		GUI.Label(new Rect(10, 160, 100, 20), "B: " + System.Math.Round((double)_pickedColor.b, 4) + "\t(" + Mathf.FloorToInt(_pickedColor.b * 255)+ ")");
		GUI.Label(new Rect(10, 180, 100, 20), "A: " + System.Math.Round((double)_pickedColor.a, 4) + "\t(" + Mathf.FloorToInt(_pickedColor.a * 255)+ ")");
	}
}
