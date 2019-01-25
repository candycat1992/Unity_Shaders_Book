using System.Collections;
using System.Collections.Generic;

using Sirenix.OdinInspector;

using UnityEngine;
using UnityEngine.SceneManagement;

public class TestSth : MonoBehaviour {
    [SerializeField] string sceneName;

    [Button]
    void OpenScene() { SceneManager.LoadScene(sceneName); }
}

class RuntimeTest {
    [RuntimeInitializeOnLoadMethod]
    static void Test() { Debug.Log($"Loaded0"); }

    [RuntimeInitializeOnLoadMethod]
    static void Test1() { Debug.Log($"Loaded1"); }
}
