using UnityEngine;
using UnityEditor;

public class ResetIsometricView
{
    [MenuItem("Tools/Reset To Isometric View")]
    static void SetIsometricView()
    {
        SceneView sceneView = SceneView.lastActiveSceneView;
        if (sceneView != null)
        {
            sceneView.orthographic = false; // 确保我们处于透视模式
            sceneView.rotation = Quaternion.Euler(30, 45, 0); // 一个典型的 Isometric 视角
            sceneView.size = 10f; // 这里你可以根据需要调整摄像机的距离/大小
            sceneView.Repaint();
        }
    }
}
