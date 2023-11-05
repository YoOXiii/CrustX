using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent(typeof(Renderer))]
public class ShaderTextureController : MonoBehaviour
{
    private Renderer rend;
    private int currentIndex = 0;
    private const int MaxIndex = 372; 
    private float lastUpdateTime = 0;
    private const float RefreshRate = 0.1f;

    void Start()
    {
        rend = GetComponent<Renderer>();
        LoadTexture();

        #if UNITY_EDITOR
        UnityEditor.EditorApplication.update += EditorUpdate;
        #endif
    }

    void OnDestroy()
    {
        #if UNITY_EDITOR
        UnityEditor.EditorApplication.update -= EditorUpdate;
        #endif
    }

    #if UNITY_EDITOR
    void EditorUpdate()
    {
        if (Time.realtimeSinceStartup - lastUpdateTime > RefreshRate)
        {
            currentIndex = (currentIndex + 1) % (MaxIndex + 1);
            LoadTexture();
            lastUpdateTime = Time.realtimeSinceStartup;
        }
    }
    #endif

    private void LoadTexture()
    {
        Texture texture = Resources.Load<Texture>($"bin_color/bin_color_{currentIndex}");
        if (texture)
        {
            rend.material.SetTexture("_VTKTex", texture);
        }
        else
        {
            Debug.LogError($"Failed to load bin_color_{currentIndex}.png");
        }
    }
}
