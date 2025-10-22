// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdfDataHiveAdapter extends TypeAdapter<PdfDataHive> {
  @override
  final int typeId = 10;

  @override
  PdfDataHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdfDataHive(
      id: fields[0] as String,
      fileName: fields[1] as String,
      pdfBytes: (fields[2] as List).cast<int>(),
      calculationType: fields[3] as String,
      projectName: fields[4] as String,
      createdAt: fields[5] as DateTime,
      description: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PdfDataHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.pdfBytes)
      ..writeByte(3)
      ..write(obj.calculationType)
      ..writeByte(4)
      ..write(obj.projectName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfDataHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PdfDataImpl _$$PdfDataImplFromJson(Map<String, dynamic> json) =>
    _$PdfDataImpl(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      pdfBytes: (json['pdfBytes'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      calculationType: json['calculationType'] as String,
      projectName: json['projectName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$PdfDataImplToJson(_$PdfDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'pdfBytes': instance.pdfBytes,
      'calculationType': instance.calculationType,
      'projectName': instance.projectName,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
    };
