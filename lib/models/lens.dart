import 'package:hive/hive.dart';

part 'lens.g.dart';

/// Définit une lentille de projecteur avec référence et ratio de projection.
@HiveType(typeId: 2)
class Lens {
  @HiveField(0)

  /// Référence ou nom de la lentille (ex: 'ET-DLE055').
  final String reference;

  @HiveField(1)

  /// Ratio de projection (ex: '0.8:1').
  final String ratio;

  @HiveField(2)

  /// Notes additionnelles sur la lentille.
  final String? notes;

  const Lens({
    required this.reference,
    required this.ratio,
    this.notes,
  });

  /// Convertit un objet Lens en map JSON-compatible.
  Map<String, dynamic> toMap() {
    return {
      'reference': reference,
      'ratio': ratio,
      'notes': notes,
    };
  }

  /// Crée un objet Lens à partir d'une map.
  factory Lens.fromMap(Map<String, dynamic> map) {
    return Lens(
      reference: map['reference'] ?? '',
      ratio: map['ratio'] ?? '',
      notes: map['notes'],
    );
  }

  /// Convertit un objet Lens en JSON.
  Map<String, dynamic> toJson() {
    return {
      'reference': reference,
      'ratio': ratio,
      'notes': notes,
    };
  }

  /// Crée un objet Lens à partir d'un JSON.
  factory Lens.fromJson(Map<String, dynamic> json) {
    return Lens(
      reference: json['reference'] as String,
      ratio: json['ratio'] as String,
      notes: json['notes'] as String?,
    );
  }
}
