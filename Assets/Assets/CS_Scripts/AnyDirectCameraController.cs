using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;

public class AnyDirectCameraController : MonoBehaviour
{
  public float moveSpeed = 1.0f; // 控制玩家移动速度
  public float turnSpeed = 50f; // 控制玩家转向速度
  public Transform planet; // 球形网格的引用
  public Camera playerCamera; // 主摄像机的引用
  public float cameraDistance = 0.5f; // 摄像机与玩家之间的距离
  private float totalAngle = 0f;
  private Vector3 vectorToPlanet;
  public bool DirectLocated = true;
  private void Start() // 在游戏开始时调用
  {
    playerCamera.targetDisplay = 1;
    transform.position = planet.position + Vector3.forward * (planet.localScale.x * 1.2f);
    transform.LookAt(planet.position);

    vectorToPlanet = planet.position - transform.position;
    vectorToPlanet = vectorToPlanet.normalized;

    playerCamera.transform.position = transform.position - vectorToPlanet * cameraDistance;
    playerCamera.transform.LookAt(transform);
    totalAngle = 0f;
  }
  private void Update()
  {
    // 获取玩家输入
    float horizontal = Input.GetAxis("Horizontal");
    float vertical = Input.GetAxis("Vertical");
    Vector3 LastUpDirect = Quaternion.AngleAxis(totalAngle, vectorToPlanet) * transform.up;
    
    if (Input.GetKeyDown(KeyCode.Y))
    {
      DirectLocated = !DirectLocated;
    }
    if (Input.GetKey(KeyCode.Space) || DirectLocated == false || Input.GetKey(KeyCode.T))
    {
      Straighten();
    }
    if (horizontal != 0)
    {
      transform.RotateAround(transform.position, vectorToPlanet, turnSpeed * Time.deltaTime * horizontal * -1f);
      totalAngle += turnSpeed * Time.deltaTime * horizontal;
    }

    if (vertical != 0)
    {
      transform.position += transform.up * moveSpeed * Time.deltaTime * vertical;
      vectorToPlanet = planet.position - transform.position;
      vectorToPlanet = vectorToPlanet.normalized;
      transform.position = planet.position - vectorToPlanet.normalized * (planet.localScale.x * 1.2f);
      playerCamera.transform.position = transform.position - vectorToPlanet * cameraDistance;
      playerCamera.transform.LookAt(transform, LastUpDirect);
      transform.LookAt(planet.position, transform.up);
    }
  }
  private Vector3 ProjectionToPlane(Vector3 planeA, Vector3 planeB, Vector3 projectVector)
  {
    Vector3 normal = Vector3.Cross(planeA, planeB);
    float projectionMagnitude = Vector3.Dot(projectVector, normal) / normal.sqrMagnitude;
    projectVector -= normal * projectionMagnitude;
    return projectVector;
  }

  private void Straighten()
  {
    playerCamera.transform.LookAt(planet.position);
    Vector3 worldUpOnPlane = ProjectionToPlane(transform.up, transform.right, Vector3.up).normalized;
    totalAngle = Vector3.Angle(worldUpOnPlane, transform.up);
    if (Vector3.Dot(transform.up, playerCamera.transform.right) < 0)
    {
      totalAngle = -totalAngle;
    }
  }

  private void OnGUI() {
    if (DirectLocated) GUI.Label(new Rect(10, 10, 100, 20), "Obverser");
    else GUI.Label(new Rect(10, 10, 100, 20), "Line of Longitude");
  }
}