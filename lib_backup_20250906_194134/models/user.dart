import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class AppUser {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? photoURL;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime lastLogin;

  @HiveField(6)
  final bool isEmailVerified;

  @HiveField(7)
  final bool isPremium;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLogin,
    required this.isEmailVerified,
    this.isPremium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoURL: map['photoURL'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLogin: DateTime.parse(map['lastLogin'] as String),
      isEmailVerified: map['isEmailVerified'] as bool,
      isPremium: map['isPremium'] as bool? ?? false,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isEmailVerified,
    bool? isPremium,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
