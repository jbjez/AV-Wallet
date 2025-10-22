import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_data.freezed.dart';
part 'pdf_data.g.dart';

@freezed
class PdfData with _$PdfData {
  const factory PdfData({
    required String id,
    required String fileName,
    required List<int> pdfBytes,
    required String calculationType,
    required String projectName,
    required DateTime createdAt,
    String? description,
  }) = _PdfData;

  factory PdfData.fromJson(Map<String, dynamic> json) => _$PdfDataFromJson(json);
}

@HiveType(typeId: 10)
class PdfDataHive extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  List<int> pdfBytes;

  @HiveField(3)
  String calculationType;

  @HiveField(4)
  String projectName;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? description;

  PdfDataHive({
    required this.id,
    required this.fileName,
    required this.pdfBytes,
    required this.calculationType,
    required this.projectName,
    required this.createdAt,
    this.description,
  });

  PdfData toPdfData() {
    return PdfData(
      id: id,
      fileName: fileName,
      pdfBytes: pdfBytes,
      calculationType: calculationType,
      projectName: projectName,
      createdAt: createdAt,
      description: description,
    );
  }

  static PdfDataHive fromPdfData(PdfData pdfData) {
    return PdfDataHive(
      id: pdfData.id,
      fileName: pdfData.fileName,
      pdfBytes: pdfData.pdfBytes,
      calculationType: pdfData.calculationType,
      projectName: pdfData.projectName,
      createdAt: pdfData.createdAt,
      description: pdfData.description,
    );
  }
}
