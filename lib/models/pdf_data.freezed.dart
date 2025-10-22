// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PdfData _$PdfDataFromJson(Map<String, dynamic> json) {
  return _PdfData.fromJson(json);
}

/// @nodoc
mixin _$PdfData {
  String get id => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  List<int> get pdfBytes => throw _privateConstructorUsedError;
  String get calculationType => throw _privateConstructorUsedError;
  String get projectName => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PdfDataCopyWith<PdfData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfDataCopyWith<$Res> {
  factory $PdfDataCopyWith(PdfData value, $Res Function(PdfData) then) =
      _$PdfDataCopyWithImpl<$Res, PdfData>;
  @useResult
  $Res call(
      {String id,
      String fileName,
      List<int> pdfBytes,
      String calculationType,
      String projectName,
      DateTime createdAt,
      String? description});
}

/// @nodoc
class _$PdfDataCopyWithImpl<$Res, $Val extends PdfData>
    implements $PdfDataCopyWith<$Res> {
  _$PdfDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? pdfBytes = null,
    Object? calculationType = null,
    Object? projectName = null,
    Object? createdAt = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      pdfBytes: null == pdfBytes
          ? _value.pdfBytes
          : pdfBytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      calculationType: null == calculationType
          ? _value.calculationType
          : calculationType // ignore: cast_nullable_to_non_nullable
              as String,
      projectName: null == projectName
          ? _value.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PdfDataImplCopyWith<$Res> implements $PdfDataCopyWith<$Res> {
  factory _$$PdfDataImplCopyWith(
          _$PdfDataImpl value, $Res Function(_$PdfDataImpl) then) =
      __$$PdfDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fileName,
      List<int> pdfBytes,
      String calculationType,
      String projectName,
      DateTime createdAt,
      String? description});
}

/// @nodoc
class __$$PdfDataImplCopyWithImpl<$Res>
    extends _$PdfDataCopyWithImpl<$Res, _$PdfDataImpl>
    implements _$$PdfDataImplCopyWith<$Res> {
  __$$PdfDataImplCopyWithImpl(
      _$PdfDataImpl _value, $Res Function(_$PdfDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fileName = null,
    Object? pdfBytes = null,
    Object? calculationType = null,
    Object? projectName = null,
    Object? createdAt = null,
    Object? description = freezed,
  }) {
    return _then(_$PdfDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fileName: null == fileName
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      pdfBytes: null == pdfBytes
          ? _value._pdfBytes
          : pdfBytes // ignore: cast_nullable_to_non_nullable
              as List<int>,
      calculationType: null == calculationType
          ? _value.calculationType
          : calculationType // ignore: cast_nullable_to_non_nullable
              as String,
      projectName: null == projectName
          ? _value.projectName
          : projectName // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfDataImpl implements _PdfData {
  const _$PdfDataImpl(
      {required this.id,
      required this.fileName,
      required final List<int> pdfBytes,
      required this.calculationType,
      required this.projectName,
      required this.createdAt,
      this.description})
      : _pdfBytes = pdfBytes;

  factory _$PdfDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfDataImplFromJson(json);

  @override
  final String id;
  @override
  final String fileName;
  final List<int> _pdfBytes;
  @override
  List<int> get pdfBytes {
    if (_pdfBytes is EqualUnmodifiableListView) return _pdfBytes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pdfBytes);
  }

  @override
  final String calculationType;
  @override
  final String projectName;
  @override
  final DateTime createdAt;
  @override
  final String? description;

  @override
  String toString() {
    return 'PdfData(id: $id, fileName: $fileName, pdfBytes: $pdfBytes, calculationType: $calculationType, projectName: $projectName, createdAt: $createdAt, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            const DeepCollectionEquality().equals(other._pdfBytes, _pdfBytes) &&
            (identical(other.calculationType, calculationType) ||
                other.calculationType == calculationType) &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      fileName,
      const DeepCollectionEquality().hash(_pdfBytes),
      calculationType,
      projectName,
      createdAt,
      description);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfDataImplCopyWith<_$PdfDataImpl> get copyWith =>
      __$$PdfDataImplCopyWithImpl<_$PdfDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfDataImplToJson(
      this,
    );
  }
}

abstract class _PdfData implements PdfData {
  const factory _PdfData(
      {required final String id,
      required final String fileName,
      required final List<int> pdfBytes,
      required final String calculationType,
      required final String projectName,
      required final DateTime createdAt,
      final String? description}) = _$PdfDataImpl;

  factory _PdfData.fromJson(Map<String, dynamic> json) = _$PdfDataImpl.fromJson;

  @override
  String get id;
  @override
  String get fileName;
  @override
  List<int> get pdfBytes;
  @override
  String get calculationType;
  @override
  String get projectName;
  @override
  DateTime get createdAt;
  @override
  String? get description;
  @override
  @JsonKey(ignore: true)
  _$$PdfDataImplCopyWith<_$PdfDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
