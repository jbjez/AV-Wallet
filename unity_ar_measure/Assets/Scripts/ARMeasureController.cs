using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;
using System.Collections.Generic;
using TMPro;

public class ARMeasureController : MonoBehaviour
{
    [Header("AR Components")]
    [SerializeField] private ARRaycastManager raycastManager;
    [SerializeField] private ARSessionOrigin sessionOrigin;
    
    [Header("UI Components")]
    [SerializeField] private TextMeshProUGUI distanceText;
    [SerializeField] private GameObject measurePointPrefab;
    
    [Header("Measurement")]
    [SerializeField] private LineRenderer lineRenderer;
    [SerializeField] private Material lineMaterial;
    
    private List<ARRaycastHit> hits = new List<ARRaycastHit>();
    private List<GameObject> measurePoints = new List<GameObject>();
    private Vector3? firstPoint;
    private Vector3? secondPoint;
    private float currentDistance = 0f;
    
    void Start()
    {
        if (lineRenderer != null)
        {
            lineRenderer.material = lineMaterial;
            lineRenderer.startWidth = 0.02f;
            lineRenderer.endWidth = 0.02f;
            lineRenderer.positionCount = 0;
        }
        
        if (distanceText != null)
        {
            distanceText.text = "Tapez sur l'écran pour mesurer";
        }
    }
    
    void Update()
    {
        if (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began)
        {
            Vector2 touchPosition = Input.GetTouch(0).position;
            
            if (raycastManager.Raycast(touchPosition, hits, TrackableType.PlaneWithinPolygon))
            {
                Vector3 hitPoint = hits[0].pose.position;
                ProcessTouch(hitPoint);
            }
        }
    }
    
    private void ProcessTouch(Vector3 hitPoint)
    {
        if (firstPoint == null)
        {
            // Premier point
            firstPoint = hitPoint;
            CreateMeasurePoint(hitPoint);
            UpdateLineRenderer();
        }
        else if (secondPoint == null)
        {
            // Deuxième point - calculer la distance
            secondPoint = hitPoint;
            CreateMeasurePoint(hitPoint);
            CalculateDistance();
            UpdateLineRenderer();
        }
        else
        {
            // Reset pour une nouvelle mesure
            ResetMeasurement();
            firstPoint = hitPoint;
            CreateMeasurePoint(hitPoint);
            UpdateLineRenderer();
        }
    }
    
    private void CreateMeasurePoint(Vector3 position)
    {
        if (measurePointPrefab != null)
        {
            GameObject point = Instantiate(measurePointPrefab, position, Quaternion.identity);
            measurePoints.Add(point);
        }
    }
    
    private void CalculateDistance()
    {
        if (firstPoint.HasValue && secondPoint.HasValue)
        {
            currentDistance = Vector3.Distance(firstPoint.Value, secondPoint.Value);
            UpdateDistanceText();
        }
    }
    
    private void UpdateDistanceText()
    {
        if (distanceText != null)
        {
            distanceText.text = $"Distance: {currentDistance:F2}m";
        }
    }
    
    private void UpdateLineRenderer()
    {
        if (lineRenderer == null) return;
        
        if (firstPoint.HasValue)
        {
            lineRenderer.positionCount = 1;
            lineRenderer.SetPosition(0, firstPoint.Value);
            
            if (secondPoint.HasValue)
            {
                lineRenderer.positionCount = 2;
                lineRenderer.SetPosition(1, secondPoint.Value);
            }
        }
    }
    
    public void ResetMeasurement()
    {
        firstPoint = null;
        secondPoint = null;
        currentDistance = 0f;
        
        // Supprimer tous les points de mesure
        foreach (GameObject point in measurePoints)
        {
            if (point != null)
                Destroy(point);
        }
        measurePoints.Clear();
        
        // Réinitialiser la ligne
        if (lineRenderer != null)
        {
            lineRenderer.positionCount = 0;
        }
        
        // Réinitialiser le texte
        if (distanceText != null)
        {
            distanceText.text = "Tapez sur l'écran pour mesurer";
        }
    }
    
    public void GoHome()
    {
        Debug.Log("GoHome appelé - retour à l'accueil");
        // TODO: Intégrer avec Flutter plus tard
    }
}
