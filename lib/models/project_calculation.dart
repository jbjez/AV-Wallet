import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_calculation.freezed.dart';
part 'project_calculation.g.dart';

@freezed
class ProjectCalculation with _$ProjectCalculation {
  const factory ProjectCalculation({
    required String id,
    required String projectId,
    required String name,
    required double totalPower,
    required double totalWeight,
    required DateTime createdAt,
    String? comment,
    String? filePath,
    String? type,
    @Default([]) List<String> photoPaths, // Nouveau: liste des chemins des photos
    @Default({}) Map<String, dynamic> data,
  }) = _ProjectCalculation;

  factory ProjectCalculation.fromJson(Map<String, dynamic> json) =>
      _$ProjectCalculationFromJson(json);
}