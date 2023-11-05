using UnityEditor.Playables;
using UnityEngine;

public class CityMarkerGenerator : MonoBehaviour
{
  public float buildingWidth = 1f;
  public float buildingHeight = 3f;
  public float buildingDepth = 1f;

  public float windowWidth = 0.3f;
  public float windowHeight = 0.5f;
  public float windowDepth = 0.05f;

  public float baseWidth = 1f;
  public float baseHeight = 0.1f;
  public float baseDepth = 1f;
  GameObject building;
  GameObject[] windows;

  private GameObject CreateCube(Vector3 position, Vector3 scale, string Name, Material material = null)
  {
    GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
    cube.transform.position = position;
    cube.transform.localScale = scale;

    if (material != null)
    {
      cube.GetComponent<Renderer>().material = material;
    }
    cube.name = Name;
    cube.transform.SetParent(this.transform, true);
    return cube;
  }

  private void DestroyAllChildGameObject()
  {
    int childCount = transform.childCount;
    for (int i = childCount - 1; i >= 0; --i)
    {
      GameObject.Destroy(transform.GetChild(i).gameObject);
    }
  }
  void OnValidate()
  {
    DestroyAllChildGameObject();
    // Create the main building body
    building = CreateCube(transform.position, new Vector3(buildingWidth, buildingHeight, buildingDepth), "Building", null);

    // Calculate the positions for windows based on building and window sizes
    Vector3 windowPosition1 = transform.position + new Vector3(-buildingWidth / 4, buildingHeight / 4, buildingDepth / 2 + windowDepth / 2);
    Vector3 windowPosition2 = transform.position + new Vector3(buildingWidth / 4, buildingHeight / 4, buildingDepth / 2 + windowDepth / 2);
    Vector3 windowPosition3 = transform.position + new Vector3(-buildingWidth / 4, -buildingHeight / 4, buildingDepth / 2 + windowDepth / 2);
    Vector3 windowPosition4 = transform.position + new Vector3(buildingWidth / 4, -buildingHeight / 4, buildingDepth / 2 + windowDepth / 2);

    // Create windows
    windows = new GameObject[4];
    windows[0] = CreateCube(windowPosition1, new Vector3(windowWidth, windowHeight, windowDepth), "Window1", null);
    windows[1] = CreateCube(windowPosition2, new Vector3(windowWidth, windowHeight, windowDepth), "Window2", null);
    windows[2] = CreateCube(windowPosition3, new Vector3(windowWidth, windowHeight, windowDepth), "Window3", null);
    windows[3] = CreateCube(windowPosition4, new Vector3(windowWidth, windowHeight, windowDepth), "Window4", null);

    Vector3 basePosition4 = transform.position + new Vector3(0, -buildingHeight / 2, buildingDepth / 2 + windowDepth / 2);
  }
}
