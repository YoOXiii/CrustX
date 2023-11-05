using UnityEngine;

public class CityMarkerPlacer : MonoBehaviour
{
    public GameObject cityMarkerPrefab; // Your city marker prefab
    public float earthRadius = 1f; // Assuming your sphere (Earth) has a radius of 1 unit

    void Start()
    {
        PlaceCityMarker(40.71f, -74.01f); // Example for New York
    }

    void PlaceCityMarker(float latitude, float longitude)
    {
        // Convert degrees to radians
        float latRad = latitude * Mathf.Deg2Rad;
        float lonRad = longitude * Mathf.Deg2Rad;

        // Calculate position on the sphere
        Vector3 position = new Vector3(
            earthRadius * Mathf.Cos(latRad) * Mathf.Cos(lonRad),
            earthRadius * Mathf.Sin(latRad),
            earthRadius * Mathf.Cos(latRad) * Mathf.Sin(lonRad)
        );

        // Instantiate city marker at the calculated position
        GameObject marker = Instantiate(cityMarkerPrefab, position, Quaternion.identity, transform);

        // Make the marker always face outward from the center of the sphere
        marker.transform.up = marker.transform.position.normalized;
    }
}
