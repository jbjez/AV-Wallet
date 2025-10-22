import 'package:hive/hive.dart';
import 'preset.dart';

part 'project.g.dart';

@HiveType(typeId: 2)
class Project extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Preset> presets;

  @HiveField(3)
  String? location;

  @HiveField(4)
  String? mountingDate;

  @HiveField(5)
  String? period;

  Project({
    required this.id, 
    required this.name, 
    List<Preset>? presets,
    this.location,
    this.mountingDate,
    this.period,
  }) : presets = presets ?? [];

  Project copyWith({
    String? id, 
    String? name, 
    List<Preset>? presets,
    String? location,
    String? mountingDate,
    String? period,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      presets: presets ?? List.from(this.presets),
      location: location ?? this.location,
      mountingDate: mountingDate ?? this.mountingDate,
      period: period ?? this.period,
    );
  }
}

