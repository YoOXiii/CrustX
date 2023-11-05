using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class SingleTriangle : MonoBehaviour
{
  public float height = 0.1f;
  public float width = 0.05f;
  public Material material;
  private void Awake() // Called when the script instance is being loaded.
  {
    Initialize();
  }
  private void OnValidate() {
    Initialize();
  }
  private void Initialize()
  {
    Mesh mesh = new Mesh();
    Vector3[] vertices = new Vector3[]
    {
      new Vector3(0, height, 0),
      new Vector3(-width/2f, 0f, 0),
      new Vector3(width/2f, 0f, 0)
    };
    int[] triangles = new int[3]{0, 1, 2};
    float[] uvs = new float[6]{0, 0, 1, 0, 0, 1};
    mesh.Clear();
    mesh.vertices = vertices;
    mesh.triangles = triangles;
    mesh.RecalculateNormals();
    GetComponent<MeshFilter>().mesh = mesh;
    GetComponent<MeshRenderer>().sharedMaterial = material;
  }
}