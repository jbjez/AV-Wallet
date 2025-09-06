// Stub classes for AR functionality when running on unsupported platforms
class ARSessionManager {
  ARSessionManager();
  void dispose() {}
}

class ARObjectManager {
  ARObjectManager();
  void dispose() {}
}

class ARAnchorManager {
  ARAnchorManager();
  void dispose() {}
}

class ARLocationManager {
  ARLocationManager();
  void dispose() {}
}

class ARNode {
  ARNode({required String uri});
  void dispose() {}
}

// Stub classes for AR functionality when running on web
class ARSessionManagerWeb {
  ARSessionManagerWeb();
}

class ARObjectManagerWeb {
  ARObjectManagerWeb();
}

class ARNodeWeb {
  ARNodeWeb();
}
