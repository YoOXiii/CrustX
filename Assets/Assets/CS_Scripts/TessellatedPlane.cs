using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class TesselatedPlane : MonoBehaviour
{
  // plot radius
  public float radius = 1.0f;

  // created tessellated rectangular plain with length_km and width_km values
  public float length = 1.0f;
  public float width = 1.0f;

  public int lengthResolution = 10;
  public int widthResolution = 10;

  private void OnValidate() // Called when the script is loaded or a value is changed in the inspector (Called in the editor only).
  {
    Initialize();
  }

  private void Initialize()
  {
    Mesh mesh = new Mesh();
    GetComponent<MeshFilter>().mesh = mesh;

    Vector3[] vertices = new Vector3[(lengthResolution + 1) * (widthResolution + 1)];
    Vector2[] uv = new Vector2[vertices.Length];
    int[] triangles = new int[lengthResolution * widthResolution * 6];

    for (int triIndex = 0, verIndex = 0, y = 0; y <= widthResolution; y++)
    {
      for (int x = 0; x <= lengthResolution; x++, verIndex++)
      {
        Vector2 percent = new(
            x * 1.0f / lengthResolution,
            y * 1.0f / widthResolution
            );
        Vector3 pointOnUnitSquare = new(
            percent.x - 0.5f,
            percent.y - 0.5f,
            0.0f
            );
        // vertices[verIndex] = new(
        //     pointOnUnitSquare.x * length_km, 
        //     pointOnUnitSquare.y * width_km, 
        //     0.0f
        //     );

        // scale the point on the unit square to the length and width of the plain
        pointOnUnitSquare.x *= length;
        pointOnUnitSquare.y *= width;


        // vertices[verIndex] = new(
        //     pointOnUnitSquare.x * lengthRatio + radius * Mathf.Sin(theta) * Mathf.Cos(phi) * radiusRatio,
        //     pointOnUnitSquare.y * widthRatio + radius * Mathf.Cos(theta) * radiusRatio,
        //     radius * Mathf.Sin(theta) * Mathf.Sin(phi) * radiusRatio
        //     );

        // Convert localPosition to global position
        //Vector3 globalPosition = transform.rotation * pointOnUnitSquare;

        // Apply the offset
        // vertices[verIndex] = globalPosition + new Vector3(
        //     radius * Mathf.Sin(theta) * Mathf.Cos(phi) * radiusRatio,
        //     radius * Mathf.Cos(theta) * radiusRatio,
        //     radius * Mathf.Sin(theta) * Mathf.Sin(phi) * radiusRatio
        //     );
        vertices[verIndex] = pointOnUnitSquare;

        uv[verIndex] = percent;

        if (x != lengthResolution && y != widthResolution)
        {
          triangles[triIndex] = verIndex;
          triangles[triIndex + 1] = verIndex + lengthResolution + 1;
          triangles[triIndex + 2] = verIndex + 1;

          triangles[triIndex + 3] = verIndex + 1;
          triangles[triIndex + 4] = verIndex + lengthResolution + 1;
          triangles[triIndex + 5] = verIndex + lengthResolution + 2;
          triIndex += 6;
        }
      }
    }
    mesh.Clear();
    mesh.vertices = vertices;
    mesh.uv = uv;
    mesh.triangles = triangles;
    mesh.RecalculateNormals();
  }
}
