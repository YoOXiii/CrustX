using UnityEngine;
using UnityEngine.UIElements;
using System.Collections.Generic;
using Unity.VisualScripting;
using TMPro;

public class IcosahedronMesh
{
  [Range(1, 6)]
  public int subdivisions = 1;
  [Range(0, 5)]
  public float radius = 1;
  private Mesh mesh;
  private int nodeNum, triangleNum, edgeNum;

  public IcosahedronMesh(int subdivisions, float radius, Mesh mesh)
  {
    this.subdivisions = subdivisions;
    this.radius = radius;
    this.mesh = mesh;
  }

  public void GenerateIcosahedron()
  {
    mesh.Clear();
    nodeNum = 12;
    triangleNum = 20;
    edgeNum = 30;
    float t = (1.0f + Mathf.Sqrt(5.0f)) / 2.0f;

    mesh.vertices = new Vector3[]
    {
            new Vector3(-1, t, 0).normalized * radius,
            new Vector3(1, t, 0).normalized * radius,
            new Vector3(-1, -t, 0).normalized * radius,
            new Vector3(1, -t, 0).normalized * radius,
            new Vector3(0, -1, t).normalized * radius,
            new Vector3(0, 1, t).normalized * radius,
            new Vector3(0, -1, -t).normalized * radius,
            new Vector3(0, 1, -t).normalized * radius,
            new Vector3(t, 0, -1).normalized * radius,
            new Vector3(t, 0, 1).normalized * radius,
            new Vector3(-t, 0, -1).normalized * radius,
            new Vector3(-t, 0, 1).normalized * radius
    };

    mesh.triangles = new int[]
    {
            0, 11, 5,
            0, 5, 1,
            0, 1, 7,
            0, 7, 10,
            0, 10, 11,
            1, 5, 9,
            5, 11, 4,
            11, 10, 2,
            10, 7, 6,
            7, 1, 8,
            3, 9, 4,
            3, 4, 2,
            3, 2, 6,
            3, 6, 8,
            3, 8, 9,
            4, 9, 5,
            2, 4, 11,
            6, 2, 10,
            8, 6, 7,
            9, 8, 1
    };
    Vector2 []uv = new Vector2[mesh.vertices.Length];
    for (int i = 0; i < mesh.vertices.Length; ++i)
    {
      Vector3 vertex = mesh.vertices[i].normalized;
      float u = Mathf.Atan2(vertex.x, vertex.z) / (2f * Mathf.PI) + 0.5f;
      float v = vertex.y * 0.5f + 0.5f;
      uv[i] = new Vector2(u, v);
    }
    mesh.uv = uv;
    mesh.RecalculateNormals();
  }

  public void SubdivideIcosahedron()
  {
    Dictionary<(int, int), int> edgeNodeMap = new Dictionary<(int, int), int>();// 记录每条边的中点索引
    Vector3[] newVertices = new Vector3[nodeNum + edgeNum];// 新顶点数组
    int[] newTriangles = new int[triangleNum * 4 * 3];// 新三角形数组

    mesh.vertices.CopyTo(newVertices, 0);
    mesh.triangles.CopyTo(newTriangles, 0);

    // 新顶点索引从nodeNum开始, 新三角形索引从0开始
    int newVertIndex = nodeNum;
    int newTriIndex = 0;

    // 细分每个三角形
    for (int triIndex = 0; triIndex < triangleNum; triIndex++)
    {
      // 获取三角形的三个顶点索引, 以及三条边的中点
      int vertIndex1 = mesh.triangles[triIndex * 3];
      int vertIndex2 = mesh.triangles[triIndex * 3 + 1];
      int vertIndex3 = mesh.triangles[triIndex * 3 + 2];
      Vector3 center12 = (mesh.vertices[vertIndex1] + mesh.vertices[vertIndex2]) / 2f;
      Vector3 center23 = (mesh.vertices[vertIndex2] + mesh.vertices[vertIndex3]) / 2f;
      Vector3 center31 = (mesh.vertices[vertIndex3] + mesh.vertices[vertIndex1]) / 2f;
      center12 = center12.normalized * radius;
      center23 = center23.normalized * radius;
      center31 = center31.normalized * radius;
      if (!edgeNodeMap.ContainsKey((vertIndex1, vertIndex2)))
      {
        edgeNodeMap.Add((vertIndex1, vertIndex2), newVertIndex);
        edgeNodeMap.Add((vertIndex2, vertIndex1), newVertIndex);
        newVertices[newVertIndex] = center12;
        newVertIndex++;
      }
      if (!edgeNodeMap.ContainsKey((vertIndex2, vertIndex3)))
      {
        edgeNodeMap.Add((vertIndex2, vertIndex3), newVertIndex);
        edgeNodeMap.Add((vertIndex3, vertIndex2), newVertIndex);
        newVertices[newVertIndex] = center23;
        newVertIndex++;
      }
      if (!edgeNodeMap.ContainsKey((vertIndex3, vertIndex1)))
      {
        edgeNodeMap.Add((vertIndex3, vertIndex1), newVertIndex);
        edgeNodeMap.Add((vertIndex1, vertIndex3), newVertIndex);
        newVertices[newVertIndex] = center31;
        newVertIndex++;
      }
      // 更新新三角形
      newTriangles[newTriIndex] = vertIndex1;
      newTriangles[newTriIndex + 1] = edgeNodeMap[(vertIndex1, vertIndex2)];
      newTriangles[newTriIndex + 2] = edgeNodeMap[(vertIndex3, vertIndex1)];

      newTriangles[newTriIndex + 3] = edgeNodeMap[(vertIndex1, vertIndex2)];
      newTriangles[newTriIndex + 4] = vertIndex2;
      newTriangles[newTriIndex + 5] = edgeNodeMap[(vertIndex2, vertIndex3)];

      newTriangles[newTriIndex + 6] = edgeNodeMap[(vertIndex3, vertIndex1)];
      newTriangles[newTriIndex + 7] = edgeNodeMap[(vertIndex2, vertIndex3)];
      newTriangles[newTriIndex + 8] = vertIndex3;

      newTriangles[newTriIndex + 9] = edgeNodeMap[(vertIndex1, vertIndex2)];
      newTriangles[newTriIndex + 10] = edgeNodeMap[(vertIndex2, vertIndex3)];
      newTriangles[newTriIndex + 11] = edgeNodeMap[(vertIndex3, vertIndex1)];
      newTriIndex += 12;
    }
    mesh.vertices = newVertices;
    mesh.triangles = newTriangles;
    nodeNum = mesh.vertices.Length;
    triangleNum = mesh.triangles.Length / 3;
    edgeNum = triangleNum * 3 / 2;

    Vector2 []uv = new Vector2[mesh.vertices.Length];
    for (int i = 0; i < mesh.vertices.Length; ++i)
    {
      Vector3 vertex = mesh.vertices[i].normalized;
      float u = 1 - Mathf.Atan2(vertex.x, vertex.z) / (2f * Mathf.PI) + 0.5f;
      float v = vertex.y * 0.5f + 0.5f;
      uv[i] = new Vector2(u, v);
      mesh.vertices[i] *= radius;
    }
    mesh.uv = uv;
    mesh.RecalculateNormals();
  }
}