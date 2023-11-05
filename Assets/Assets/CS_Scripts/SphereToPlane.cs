using System.Collections.Generic;
using System.Text;
using System.Collections;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.Diagnostics;
using UnityEngine.UIElements;

[RequireComponent(typeof(MeshFilter))]
public class SphereToPlane : MonoBehaviour
{
  public Mesh mesh;
  public Camera playerCamera;
  [Range(0f, 1f)]
  public float planePercentage = 0f;
  public Vector3 spherePos = new(0f, 0f, 1f);
  private Vector3[] originalVertices = new Vector3[0];
  private Vector3[] uvVertices = new Vector3[0];
  Vector3 lastPosition = new(0f, 0f, 1f);
  private int southPoleIndex = -1;
  private int northPoleIndex = -1;
  private float scale = 1;
  private void Start()//初始化 读取网格信息
  {
    spherePos = lastPosition = new(0f, 0f, 1f);
    mesh = GetComponent<MeshFilter>().sharedMesh;
    originalVertices = mesh.vertices;
    uvVertices = new Vector3[originalVertices.Length];
  }

  private void OnValidate()//每帧更新
  {
    if (mesh == null || originalVertices.Length == 0 || uvVertices.Length == 0) // 初始化
    {
      mesh = GetComponent<MeshFilter>().sharedMesh;
      originalVertices = mesh.vertices;
      uvVertices = new Vector3[originalVertices.Length];
    }
    if (southPoleIndex == -1) // 找到南北极
    {
      Debug.Log(originalVertices.Length);
      for (int i = 0; i < originalVertices.Length; i++)
      {
        if (originalVertices[i] == new Vector3(0f, 1f, 0f)) southPoleIndex = i;
        if (originalVertices[i] == new Vector3(0f, -1f, 0f)) northPoleIndex = i;
      }
    }

    Vector3 panning = new(float.NaN, float.NaN, float.NaN);
    spherePos = spherePos.normalized;
    float distance = 10f;

    for (int i = 0; i < originalVertices.Length; i++)
    {
      uvVertices[i] = SphereToUVMapping(originalVertices[i]);//球面坐标转UV坐标
      uvVertices[i] = RotateToCurrentPerspective(uvVertices[i], spherePos);//旋转到当前视角
      if (Vector3.Distance(originalVertices[i], spherePos) < distance)//找到最近的点
      {
        distance = Vector3.Distance(originalVertices[i], spherePos);
        panning = spherePos - uvVertices[i];
      }
    }

    Vector3[] newVertices = new Vector3[originalVertices.Length];

    for (int i = 0; i < originalVertices.Length; i++)
    {
      newVertices[i] = planePercentage * uvVertices[i] + (1f - planePercentage) * originalVertices[i];//渐变
      newVertices[i] = newVertices[i] + panning * planePercentage;//平移
    }

    Quaternion straighten = Straighten(spherePos, (newVertices[southPoleIndex] - newVertices[northPoleIndex]).normalized);//将平面旋转为正位
    
    for (int i = 0; i < originalVertices.Length; i++)
    {
      newVertices[i] = straighten * newVertices[i];//旋转
      if (1f - planePercentage <= 1e-6) newVertices[i] = ScaleZoom(spherePos, newVertices[i], scale);//缩放
    }

    mesh.vertices = newVertices;
    if ((spherePos == new Vector3(0, 0, -1) || lastPosition == new Vector3(0, 0, -1)) && lastPosition != spherePos)//判断是否需要翻转
    {
      int[] newtriangles = mesh.triangles;
      for (int i = 0; i < newtriangles.Length; i++)
      {
        newtriangles[i] = mesh.triangles[newtriangles.Length - 1 - i];
      }
      mesh.triangles = newtriangles;
      mesh.RecalculateNormals();
    }
    lastPosition = spherePos;//更新上一帧的位置
  }
  void Update()//游戏中的操作
  {
    spherePos = playerCamera.transform.position;
    spherePos = spherePos.normalized;
    if (Input.GetKeyDown(KeyCode.T))//按T缓慢切换为平面
    {
      StartCoroutine(TransitionToPlane());
    }
  }

  IEnumerator TransitionToPlane()
  {
    planePercentage = 0f;
    scale = 1f;
    for (int i = 0; i < 50; i++)
    {
      planePercentage += 0.02f;
      OnValidate();
      yield return new WaitForSeconds(0.01f);
    }
    
    for (int i = 0; i < 90; i++)
    {
      scale += 0.1f;
      OnValidate();
      yield return new WaitForSeconds(0.01f);
    }
  }

  Vector3 SphereToUVMapping(Vector3 spherePos)
  {
    float u = 0.5f + Mathf.Atan2(spherePos.z, spherePos.x) / (2f * Mathf.PI);
    float v = 0.5f - Mathf.Asin(spherePos.y) / Mathf.PI;
    u -= 0.5f;
    if (u < 0f) u += 1f;
    return new Vector3(-u, -v, 0f);
  }

  Vector3 RotateToCurrentPerspective(Vector3 UVPos, Vector3 spherePos)
  {
    Vector3 rotationAxis = Vector3.Cross(spherePos, Vector3.forward).normalized;
    float angle = -1f * Vector3.Angle(spherePos, Vector3.forward);
    Quaternion rotation = Quaternion.AngleAxis(angle, rotationAxis);
    return rotation * UVPos;
  }

  Vector3 ProjectionToPlane(Vector3 normal, Vector3 projectVector)
  {
    float projectionMagnitude = Vector3.Dot(projectVector, normal) / normal.sqrMagnitude;
    projectVector -= normal * projectionMagnitude;
    return projectVector;
  }

  Quaternion Straighten(Vector3 spherePos, Vector3 curUpOnPlane)
  {
    Vector3 worldUpOnPlane = ProjectionToPlane(spherePos, Vector3.up);
    if (worldUpOnPlane == Vector3.zero)
    {
      worldUpOnPlane = Vector3.forward;
    }
    worldUpOnPlane = worldUpOnPlane.normalized;
    float angle = Vector3.Angle(worldUpOnPlane, curUpOnPlane);
    if (spherePos.y > 0f) angle = -angle;
    if (spherePos.x > 0f) angle = -angle;
    return Quaternion.AngleAxis(angle, spherePos);
  }

  Vector3 ScaleZoom(Vector3 spherePos, Vector3 UVPos, float scale)
  {
    Vector3 relativePos = UVPos - spherePos;
    relativePos *= scale;
    return relativePos + spherePos;
  }
}