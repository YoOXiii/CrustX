using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Analytics;

public class LonLatCameraController : MonoBehaviour
{
  public float speed = 1.0f; // 控制玩家移动速度
  public Transform planet; // 球形网格的引用
  public Camera mainCamera; // 主摄像机的引用
  public float cameraDistance = 0.5f; // 摄像机与玩家之间的距离

  private Vector3 currentDirection;
  private Vector3 vectorToPlanet;
  private Vector3 objXAxis, objYAxis, objZAxis;

  private void SetObjAxis()
  {
    objZAxis = vectorToPlanet;

    if (objZAxis == new Vector3(0, 1f, 0))
    {
      Debug.Log("You are in the north pole!");
      objYAxis = new Vector3(-1f, 0, 0);
      objXAxis = new Vector3(0, 0, -1f);
    }
    else if (objZAxis == new Vector3(0, -1f, 0))
    {
      Debug.Log("You are in the south pole!");
      objYAxis = new Vector3(1f, 0, 0);
      objXAxis = new Vector3(0, 0, 1f);
    }
    else
    {
      objXAxis = Vector3.Cross(objZAxis, Vector3.up).normalized;
      objYAxis = Vector3.Cross(objZAxis, objXAxis).normalized;
      objXAxis = -objXAxis;
      objYAxis = -objYAxis;
    }
  }

  private void Start() // 在游戏开始时调用
  {
    transform.position = planet.position + Vector3.forward * (planet.localScale.x * 1.2f);
    transform.LookAt(planet.position);

    vectorToPlanet = planet.position - transform.position;
    vectorToPlanet = vectorToPlanet.normalized;

    mainCamera.transform.position = transform.position - vectorToPlanet * cameraDistance;
    mainCamera.transform.LookAt(transform);
    SetObjAxis();
  }
  private void Update()
  {
    // 获取玩家输入
    float horizontal = Input.GetAxis("Horizontal");
    float vertical = Input.GetAxis("Vertical");
    // 根据输入计算移动方向
    currentDirection = (horizontal * objXAxis + vertical * objYAxis).normalized;
    //Debug.Log(objXAxis + " " + objYAxis + " " + objZAxis);
    //Debug.Log(currentDirection);
    if (currentDirection != Vector3.zero)
    {

      vectorToPlanet = planet.position - transform.position;
      vectorToPlanet = vectorToPlanet.normalized;
      transform.position = planet.position - vectorToPlanet.normalized * (planet.localScale.x * 1.2f);
      transform.LookAt(planet.position);
      SetObjAxis();

      transform.rotation = Quaternion.LookRotation(vectorToPlanet, currentDirection);
      transform.position += transform.up * speed * Time.deltaTime;

    }
    mainCamera.transform.position = transform.position - vectorToPlanet * cameraDistance;
    mainCamera.transform.LookAt(transform);
  }
}