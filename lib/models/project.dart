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

  Project({required this.id, required this.name, List<Preset>? presets})
      : presets = presets ?? [];

  Project copyWith({String? id, String? name, List<Preset>? presets}) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      presets: presets ?? List.from(this.presets),
    );
  }
}

