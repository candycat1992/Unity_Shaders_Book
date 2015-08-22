using UnityEngine;
using System.Collections;

public class Test : MonoBehaviour {

	// Use this for initialization
	void Start () {
//		Vector4 pos = Camera.main.worldToCameraMatrix * new Vector4(9.0f, 4.0f, 18.072f, 1.0f);
//		Vector3 screenPos = Camera.main.WorldToScreenPoint(new Vector3(9.0f, 4.0f, 18.072f));
//		Debug.Log(Camera.main.aspect + " " + Camera.main.pixelRect);
//		Debug.Log(pos + " " + screenPos);
		Vector4 worldPos = transform.parent.localToWorldMatrix * new Vector4(transform.localPosition.x, transform.localPosition.y, transform.localPosition.z, 1.0f);
		Vector3 pt = Camera.main.projectionMatrix * new Vector4(9f, 8.84f, -27.31f, 1.0f);
//		Debug.Log( transform.position + " " + worldPos);
		Debug.Log(pt);
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
