// Stub implementation of app_links to avoid iOS build issues
// Use Uri directly for compatibility with supabase_flutter
typedef AppLink = Uri;

class AppLinks {
  static AppLinks? _instance;
  
  static AppLinks get instance {
    _instance ??= AppLinks._();
    return _instance!;
  }
  
  AppLinks();
  AppLinks._();
  
  Stream<AppLink> get allUriLinkStream {
    return Stream.empty();
  }
  
  Stream<AppLink> get uriLinkStream {
    return Stream.empty();
  }
  
  Future<AppLink?> getInitialAppLink() async {
    return null;
  }
  
  Future<AppLink?> getLatestAppLink() async {
    return null;
  }
}
