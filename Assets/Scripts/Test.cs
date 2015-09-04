using UnityEngine;
using System.Collections;

public class Test : MonoBehaviour {
	
	public float x  = 80.0f;
	public float z = 40.0f;
	
	// Use this for initialization
	void Start () {
		//		transform.Rotate(new Vector3(0, 0, z));  
		//		transform.Rotate(new Vector3(0, 90, 0));  
		//		transform.Rotate(new Vector3(y, 0, 0)); 
	}
	
	// Update is called once per frame
	void Update () {
		transform.rotation = Quaternion.identity;
		transform.Rotate(new Vector3(0, 0, z));  
		transform.Rotate(new Vector3(0, 90, 0));  
		transform.Rotate(new Vector3(x, 0, 0)); 
	}
}
