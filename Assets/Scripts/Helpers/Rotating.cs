using UnityEngine;
using System.Collections;

public class Rotating : MonoBehaviour {

	public float speed = 10.0f;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		float angle = Time.deltaTime * speed;
		transform.Rotate(new Vector3(angle, angle, angle));
	}
}
