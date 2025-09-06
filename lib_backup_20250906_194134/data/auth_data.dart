
class AuthData {
  final String email;
  final String password;
  final String name;

  AuthData({
    required this.email,
    required this.password,
    required this.name,
  });

  Future<bool> login() async {
    // TODO: Implement actual login logic
    return true;
  }

  Future<bool> register() async {
    // TODO: Implement actual registration logic
    return true;
  }
}
