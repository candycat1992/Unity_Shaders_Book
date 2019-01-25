using Sirenix.OdinInspector;

using UnityEngine;

public class NameByMat : MonoBehaviour {
    [SerializeField, Bind(true)] Renderer _renderer;

    void Reset() { Name(); }

    [Button]
    void Name() {
        if (_renderer != null && _renderer.sharedMaterial != null) {
            gameObject.name = _renderer.sharedMaterial.name;
        }
    }
}
