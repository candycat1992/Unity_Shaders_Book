/// <summary>
/// Author: Lele Feng 
/// </summary>

using UnityEngine;
using System.Collections;

public class ColorPicker : MonoBehaviour {
	
	public BoxCollider collider;

	private bool _grab;
	private Camera _camera;
	private Texture2D _screenRenderTexture;
	private static Texture2D _staticRectTexture;
	private static GUIStyle _staticRectStyle;

	private static Vector3 _pixelPosition = Vector3.zero;
	private Color _pickedColor = Color.white;

	void Awake() {
		// Get the Camera component
		_camera = GetComponent<Camera>();
		if (_camera == null) {
			Debug.LogError("You need to dray this script to a camera!");
			return;
		}

		// Attach a BoxCollider to this camera
		// In order to receive mouse events
		if (collider == null) {
			collider = gameObject.AddComponent<BoxCollider>();
			// Make sure the collider is in the camera's frustum
			collider.center = Vector3.zero;
			collider.center += _camera.transform.worldToLocalMatrix.MultiplyVector(_camera.transform.forward) * (_camera.nearClipPlane + 0.2f);
			collider.size = new Vector3(Screen.width, Screen.height, 0.1f);
		}
	}

	// Draw the color we picked
	public static void GUIDrawRect( Rect position, Color color )
	{
		if( _staticRectTexture == null )
		{
			_staticRectTexture = new Texture2D(1, 1);
		}
		
		if( _staticRectStyle == null )
		{
			_staticRectStyle = new GUIStyle();
		}
		
		_staticRectTexture.SetPixel(0, 0, color);
		_staticRectTexture.Apply();
		
		_staticRectStyle.normal.background = _staticRectTexture;
		
		GUI.Box(position, GUIContent.none, _staticRectStyle);
	}

	// OnPostRender is called after a camera has finished rendering the scene.
	// This message is sent to all scripts attached to the camera.
	// Use it to grab the screen
	// Note: grabing is a expensive operation
	void OnPostRender() {
		if (_grab) {
			_screenRenderTexture = new Texture2D(Screen.width, Screen.height);
			_screenRenderTexture.ReadPixels(new Rect(0, 0, Screen.width, Screen.height), 0, 0);
			_screenRenderTexture.Apply();
			_pickedColor = _screenRenderTexture.GetPixel(Mathf.FloorToInt(_pixelPosition.x), Mathf.FloorToInt(_pixelPosition.y));
			_grab = false;
		}
	}
	
	void OnMouseDown() {
		_grab = true;
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
