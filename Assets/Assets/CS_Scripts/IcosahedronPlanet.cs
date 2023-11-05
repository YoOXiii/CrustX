using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class IcoshedronPlanet : MonoBehaviour
{
  [Range(1, 6)]
  public int subdivisions = 1;
  [Range(0, 5)]
  public float radius = 1;
  [SerializeField, HideInInspector]

  MeshFilter meshFilter;
  IcosahedronMesh icosahedronMesh;
  private void OnValidate()
  {
    Initialize();
    GenerateMesh();
  }
  void Initialize()
  {
    if (meshFilter == null)
    {
      meshFilter = new MeshFilter();
      GameObject meshObj = new GameObject("mesh");
      meshObj.transform.parent = transform;
      meshObj.AddComponent<MeshRenderer>().sharedMaterial = new Material(Shader.Find("Standard"));
      meshFilter = meshObj.AddComponent<MeshFilter>();
      meshFilter.sharedMesh = new Mesh();
    }
    icosahedronMesh = new IcosahedronMesh(subdivisions, radius, meshFilter.sharedMesh);
    
  }
  void GenerateMesh()
  {
    icosahedronMesh.GenerateIcosahedron();
    for (int i = 0; i < subdivisions - 1; ++i)
    {
      icosahedronMesh.SubdivideIcosahedron();
    }
  }
}