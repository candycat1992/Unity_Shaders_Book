using UnityEngine;
using System.Collections;

public class BurnHelper : MonoBehaviour {

	public Material material;

	[Range(0.01f, 1.0f)]
	public float burnSpeed = 0.3f;

	private float burnAmount = 0.0f;

	// Use this for initialization
	void Start () {
		if (material == null) {
			Renderer renderer = gameObject.GetComponentInChildren<Renderer>();
			if (renderer != null) {
				material = renderer.material;
			}
		}

		if (material == null) {
			this.enabled = false;
		} else {
			material.SetFloat("_BurnAmount", 0.0f);
		}
	}
	
	// Update is called once per frame
	void Update () {
		burnAmount = Mathf.Repeat(Time.time * burnSpeed, 1.0f);
		material.SetFloat("_BurnAmount", burnAmount);
	}
}
