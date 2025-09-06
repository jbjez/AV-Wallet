using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.ARFoundation;
using UnityEngine.XR.ARSubsystems;

public class ObjectManager : MonoBehaviour
{
    [Header("AR Managers")]
    public ARRaycastManager raycastManager;
    public ARPlaneManager planeManager;
    
    [Header("Object Prefabs")]
    public GameObject measurePointPrefab;
    public GameObject projectorPrefab;
    public GameObject screenPrefab;
    public GameObject speakerPrefab;
    
    [Header("Materials")]
    public Material measurePointMat;
    public Material projectorMat;
    public Material screenMat;
    public Material speakerMat;
    
    private GameObject pointA;
    private GameObject pointB;
    private LineRenderer line;
    private Camera mainCam;
    private readonly List<ARRaycastHit> hits = new();
    private List<GameObject> placedObjects = new List<GameObject>();
    private string selectedObjectType = "measure_point";
    
    void Awake()
    {
        mainCam = Camera.main;
    }
    
    void Start()
    {
        // LineRenderer pour relier A ↔ B
        var lineObj = new GameObject("MeasureLine");
        line = lineObj.AddComponent<LineRenderer>();
        line.positionCount = 2;
        line.startWidth = 0.005f;
        line.endWidth = 0.005f;
        if (measurePointMat != null) line.material = measurePointMat;
        line.enabled = false;
        
        Debug.Log("ObjectManager - Script démarré avec succès");
    }
    
    void Update()
    {
        // Tap écran -> raycast plan
        if (Input.touchCount == 0 && !Input.GetMouseButtonDown(0)) return;
        
        Vector3 tapPosition;
        if (Input.touchCount > 0)
        {
            var touch = Input.GetTouch(0);
            if (touch.phase != TouchPhase.Began) return;
            tapPosition = touch.position;
        }
        else
        {
            // Utiliser la souris dans l'Editor
            tapPosition = Input.mousePosition;
        }
        
        // Dans l'Editor, simuler un point sur un plan
        Vector3 worldPosition = mainCam.ScreenToWorldPoint(new Vector3(tapPosition.x, tapPosition.y, 5f));
        
        Debug.Log($"ObjectManager - Tap détecté à la position: {worldPosition}");
        HandleTap(worldPosition);
    }
    
    void HandleTap(Vector3 position)
    {
        if (selectedObjectType == "measure_point")
        {
            PlaceMeasurePoint(position);
        }
        else
        {
            PlaceObject(position);
        }
    }
    
    void PlaceMeasurePoint(Vector3 position)
    {
        if (pointA == null)
        {
            pointA = Instantiate(measurePointPrefab, position, Quaternion.identity);
            line.enabled = false;
            Debug.Log("ObjectManager - Point A placé");
        }
        else if (pointB == null)
        {
            pointB = Instantiate(measurePointPrefab, position, Quaternion.identity);
            UpdateLineAndDistance();
            Debug.Log("ObjectManager - Point B placé");
        }
        else
        {
            // Remplace B
            pointB.transform.position = position;
            UpdateLineAndDistance();
            Debug.Log("ObjectManager - Point B déplacé");
        }
    }
    
    void PlaceObject(Vector3 position)
    {
        GameObject prefab = GetPrefabForType(selectedObjectType);
        if (prefab != null)
        {
            GameObject obj = Instantiate(prefab, position, Quaternion.identity);
            placedObjects.Add(obj);
            Debug.Log($"ObjectManager - Objet {selectedObjectType} placé");
        }
    }
    
    GameObject GetPrefabForType(string objectType)
    {
        switch (objectType)
        {
            case "measure_point": return measurePointPrefab;
            case "projector": return projectorPrefab;
            case "screen": return screenPrefab;
            case "speaker": return speakerPrefab;
            default: return measurePointPrefab;
        }
    }
    
    public void PlaceObject(string objectType)
    {
        selectedObjectType = objectType;
        Debug.Log("ObjectManager - Type d'objet sélectionné: " + objectType);
    }
    
    void UpdateLineAndDistance()
    {
        if (pointA == null || pointB == null) return;
        
        var a = pointA.transform.position;
        var b = pointB.transform.position;
        
        line.enabled = true;
        line.SetPosition(0, a);
        line.SetPosition(1, b);
        
        var dist = Vector3.Distance(a, b);
        Debug.Log($"ObjectManager - Distance A-B: {dist:F3} mètres");
    }
    
    public void ResetMeasure()
    {
        if (pointA != null) Destroy(pointA);
        if (pointB != null) Destroy(pointB);
        pointA = null;
        pointB = null;
        line.enabled = false;
        
        // Supprimer tous les objets placés
        foreach (GameObject obj in placedObjects)
        {
            if (obj != null) Destroy(obj);
        }
        placedObjects.Clear();
        
        Debug.Log("ObjectManager - Reset effectué");
    }
}
