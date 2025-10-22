import 'package:flutter/services.dart';

class UnityMeasurePlugin {
  static const MethodChannel _channel = MethodChannel('unity_measure_plugin');

  static Future<void> startUnityMeasure() async {
    try {
      await _channel.invokeMethod('startUnityMeasure');
      print("Unity Measure started.");
    } on PlatformException catch (e) {
      print("Failed to start Unity Measure: '${e.message}'.");
    }
  }

  static Future<void> stopUnityMeasure() async {
    try {
      await _channel.invokeMethod('stopUnityMeasure');
      print("Unity Measure stopped.");
    } on PlatformException catch (e) {
      print("Failed to stop Unity Measure: '${e.message}'.");
    }
  }

  static Future<double?> measureDistance() async {
    try {
      final double? result = await _channel.invokeMethod('measureDistance');
      return result;
    } on PlatformException catch (e) {
      print("Failed to measure distance: '${e.message}'.");
      return null;
    }
  }

  static Future<void> toggleMode() async {
    try {
      await _channel.invokeMethod('toggleMode');
      print("Mode toggled.");
    } on PlatformException catch (e) {
      print("Failed to toggle mode: '${e.message}'.");
    }
  }
}