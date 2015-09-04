using UnityEngine;
using System.Collections;

// Attach this to a camera.
// Inverts the view of the camera so everything rendered by it, is flipped

public class InvertCamera : MonoBehaviour {

	private Camera m_camera;
	
	void Start() {
		m_camera = GetComponent<Camera>();
		Debug.Log(m_camera.projectionMatrix.inverse);
		Debug.Log(m_camera.projectionMatrix);
	}
	
	void OnPreCull() {
		m_camera.ResetWorldToCameraMatrix();
		m_camera.ResetProjectionMatrix();
		m_camera.projectionMatrix = m_camera.projectionMatrix * Matrix4x4.Scale(new Vector3(-1, 1, 1));
//		Debug.Log(camera.projectionMatrix);
	}
	
	void OnPreRender() {
		GL.invertCulling = true;
	}
	
	void OnPostRender() {
		GL.invertCulling = false;
	}
}
