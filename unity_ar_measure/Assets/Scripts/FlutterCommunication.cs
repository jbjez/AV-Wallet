using UnityEngine;
using FlutterUnityIntegration;

public class FlutterCommunication : MonoBehaviour
{
    void Start()
    {
        // Écouter les messages de Flutter
        UnityMessageManager.Instance.OnMessage += OnFlutterMessage;
    }
    
    void OnDestroy()
    {
        // Nettoyer les listeners
        if (UnityMessageManager.Instance != null)
        {
            UnityMessageManager.Instance.OnMessage -= OnFlutterMessage;
        }
    }
    
    private void OnFlutterMessage(string message)
    {
        Debug.Log($"Message reçu de Flutter: {message}");
        
        // Traiter les messages de Flutter
        switch (message)
        {
            case "Reset":
                ResetMeasurement();
                break;
            case "Home":
                GoHome();
                break;
            default:
                Debug.Log($"Message non reconnu: {message}");
                break;
        }
    }
    
    private void ResetMeasurement()
    {
        // Trouver le MeasureController et reset
        MeasureController measureController = FindObjectOfType<MeasureController>();
        if (measureController != null)
        {
            measureController.ResetMeasurement();
        }
    }
    
    private void GoHome()
    {
        // Envoyer un message à Flutter pour retourner à l'accueil
        UnityMessageManager.Instance.SendMessageToFlutter("NavigateToHome");
    }
}
