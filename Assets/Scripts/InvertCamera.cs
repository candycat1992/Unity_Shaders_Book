using UnityEngine;
using System.Collections;

// Attach this to a camera.
// Inverts the view of the camera so everything rendered by it, is flipped

public class InvertCamera : MonoBehaviour {

	Camera camera;
	
	void Start() {
		camera = GetComponent<Camera>();
		Debug.Log(camera.projectionMatrix.inverse);
		Debug.Log(camera.projectionMatrix);
	}
	
	void OnPreCull() {
		camera.ResetWorldToCameraMatrix();
		camera.ResetProjectionMatrix();
		camera.projectionMatrix = camera.projectionMatrix * Matrix4x4.Scale(new Vector3(-1, 1, 1));
//		Debug.Log(camera.projectionMatrix);
	}
	
	void OnPreRender() {
		GL.SetRevertBackfacing(true);
	}
	
	void OnPostRender() {
		GL.SetRevertBackfacing(false);
	}
}
