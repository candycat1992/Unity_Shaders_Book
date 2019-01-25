using Sirenix.OdinInspector;

using UnityEngine;

[ExecuteInEditMode]
public class ConeTester : MonoBehaviour {
    [SerializeField] Transform _otherTrans;

    [Space]
    [SerializeField]
    Transform _forwardPoint;

    [SerializeField]
    Transform _localForwardPoint;

    [DisplayAsString]
    public Vector3 forward;

    [DisplayAsString] public float forwardMagnitude;
    [DisplayAsString] public float dot;
    [DisplayAsString] public float angle;


    void Update() {
        forward = transform.forward;
        if (_forwardPoint) {
            _forwardPoint.position = forward;
            _localForwardPoint.localPosition = transform.InverseTransformPoint(forward);
        }

        forwardMagnitude = Vector3.Magnitude(forward);
        if (_otherTrans) {
            dot = Vector3.Dot((_otherTrans.forward).normalized, forward);
            angle = Mathf.Acos(dot) * Mathf.Rad2Deg;
        }
    }
}
