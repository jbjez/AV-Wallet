using UnityEngine;

public class SimpleFlutterCommunication : MonoBehaviour
{
    void Start()
    {
        Debug.Log("SimpleFlutterCommunication démarré");
    }
    
    public void ResetMeasurement()
    {
        Debug.Log("ResetMeasurement appelé");
        // Trouver le MeasureController et reset
        MeasureController measureController = FindObjectOfType<MeasureController>();
        if (measureController != null)
        {
            measureController.ResetMeasurement();
        }
    }
    
    public void GoHome()
    {
        Debug.Log("GoHome appelé - retour à l'accueil");
        // TODO: Intégrer avec Flutter plus tard
    }
}
