import 'lens.dart';
import 'package:hive/hive.dart';

part 'catalogue_item.g.dart';

@HiveType(typeId: 0)
class CatalogueItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String categorie;

  @HiveField(4)
  final String sousCategorie;

  @HiveField(5)
  final String marque;

  @HiveField(6)
  final String produit;

  @HiveField(21)
  final int? taille; // ✅ en pouces

  @HiveField(7)
  final String dimensions;

  @HiveField(8)
  final String poids;

  @HiveField(9)
  final String conso;

  @HiveField(10)
  final String? imageUrl;

  @HiveField(11)
  final String? resolutionDalle;

  @HiveField(12)
  final String? angle;

  @HiveField(13)
  final String? lux;

  @HiveField(14)
  final String? lumens;

  @HiveField(15)
  final String? definition;

  @HiveField(16)
  final String? dmxMax;

  @HiveField(17)
  final String? dmxMini;

  @HiveField(18)
  final String? resolution;

  @HiveField(19)
  final String? pitch;

  @HiveField(20)
  final List<Lens>? optiques;

  @HiveField(22)
  final String? puissanceAdmissible;

  @HiveField(23)
  final String? impedanceNominale;

  // ⬇️ Champs audio pour calcul d'amplification
  @HiveField(24)
  final int? impedanceOhms;        // 8, 16, 4…

  @HiveField(25)
  final int? powerRmsW;            // puissance continue recommandée

  @HiveField(26)
  final int? powerProgramW;        // ~2× RMS (si dispo)

  @HiveField(27)
  final int? powerPeakW;           // ~4× RMS (si dispo)

  @HiveField(28)
  final double? maxVoltageVrms;    // limite tension admissible (optionnel)

  @HiveField(29)
  final bool? isWifiByDefault;     // true si le produit est WiFi par défaut (Titan, Helios, etc.)

  const CatalogueItem({
    required this.id,
    required this.name,
    required this.description,
    required this.categorie,
    required this.sousCategorie,
    required this.marque,
    required this.produit,
    this.taille,
    required this.dimensions,
    required this.poids,
    required this.conso,
    this.imageUrl,
    this.resolutionDalle,
    this.angle,
    this.lux,
    this.lumens,
    this.definition,
    this.dmxMax,
    this.dmxMini,
    this.resolution,
    this.pitch,
    this.optiques,
    this.puissanceAdmissible,
    this.impedanceNominale,
    this.impedanceOhms,
    this.powerRmsW,
    this.powerProgramW,
    this.powerPeakW,
    this.maxVoltageVrms,
    this.isWifiByDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categorie': categorie,
      'sousCategorie': sousCategorie,
      'marque': marque,
      'produit': produit,
      'taille': taille,
      'dimensions': dimensions,
      'poids': poids,
      'conso': conso,
      'imageUrl': imageUrl,
      'resolutionDalle': resolutionDalle,
      'angle': angle,
      'lux': lux,
      'lumens': lumens,
      'definition': definition,
      'dmxMax': dmxMax,
      'dmxMini': dmxMini,
      'resolution': resolution,
      'pitch': pitch,
      'optiques': optiques?.map((x) => x.toMap()).toList(),
      'puissanceAdmissible': puissanceAdmissible,
      'impedanceNominale': impedanceNominale,
      'impedance_ohms': impedanceOhms,
      'power_rms_w': powerRmsW,
      'power_program_w': powerProgramW,
      'power_peak_w': powerPeakW,
      'max_voltage_vrms': maxVoltageVrms,
      'is_wifi_by_default': isWifiByDefault,
    };
  }

  factory CatalogueItem.fromMap(Map<String, dynamic> map) {
    return CatalogueItem(
      id: map['id'] as String? ?? '',
      name: map['name'] as String,
      description: map['description'] as String,
      categorie: map['categorie'] as String,
      sousCategorie: map['sousCategorie'] as String,
      marque: map['marque'] as String,
      produit: map['produit'] as String,
      taille: map['taille'] is int
          ? map['taille']
          : int.tryParse(map['taille']?.toString() ?? ''),
      dimensions: map['dimensions'] as String,
      poids: map['poids'] as String,
      conso: map['conso'] as String,
      imageUrl: map['imageUrl'] as String?,
      resolutionDalle: map['resolutionDalle'] as String?,
      angle: map['angle'] as String?,
      lux: map['lux'] as String?,
      lumens: map['lumens'] as String?,
      definition: map['definition'] as String?,
      dmxMax: map['dmxMax'] as String?,
      dmxMini: map['dmxMini'] as String?,
      resolution: map['resolution'] as String?,
      pitch: map['pitch'] as String?,
      optiques: (map['optiques'] as List<dynamic>?)
          ?.map((x) => Lens.fromMap(x as Map<String, dynamic>))
          .toList(),
      puissanceAdmissible: map['puissanceAdmissible'] as String?,
      impedanceNominale: map['impedanceNominale'] as String?,
      impedanceOhms: map['impedance_ohms'] is int
          ? map['impedance_ohms']
          : int.tryParse(map['impedance_ohms']?.toString() ?? ''),
      powerRmsW: map['power_rms_w'] is int
          ? map['power_rms_w']
          : int.tryParse(map['power_rms_w']?.toString() ?? ''),
      powerProgramW: map['power_program_w'] is int
          ? map['power_program_w']
          : int.tryParse(map['power_program_w']?.toString() ?? ''),
      powerPeakW: map['power_peak_w'] is int
          ? map['power_peak_w']
          : int.tryParse(map['power_peak_w']?.toString() ?? ''),
      maxVoltageVrms: map['max_voltage_vrms'] is double
          ? map['max_voltage_vrms']
          : double.tryParse(map['max_voltage_vrms']?.toString() ?? ''),
      isWifiByDefault: map['is_wifi_by_default'] as bool?,
    );
  }

  factory CatalogueItem.fromJson(Map<String, dynamic> json) {
    return CatalogueItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String,
      description: json['description'] as String,
      categorie: json['categorie'] as String,
      sousCategorie: json['sous_categorie'] as String,
      marque: json['marque'] as String,
      produit: json['produit'] as String,
      taille: json['taille'] is int
          ? json['taille']
          : int.tryParse(json['taille']?.toString() ?? ''),
      dimensions: json['dimensions'] as String,
      poids: json['poids'] as String,
      conso: json['conso'] as String,
      imageUrl: json['image_url'] as String?,
      resolutionDalle: json['resolution_dalle'] as String?,
      angle: json['angle'] as String?,
      lux: json['lux'] as String?,
      lumens: json['lumens'] as String?,
      definition: json['definition'] as String?,
      dmxMax: json['dmx_max'] as String?,
      dmxMini: json['dmx_mini'] as String?,
      resolution: json['resolution'] as String?,
      pitch: json['pitch'] as String?,
      optiques: (json['optiques'] as List<dynamic>?)
          ?.map((x) => Lens.fromJson(x as Map<String, dynamic>))
          .toList(),
      puissanceAdmissible: json['puissance_admissible'] as String?,
      impedanceNominale: json['impedance_nominale'] as String?,
      impedanceOhms: json['impedance_ohms'] is int
          ? json['impedance_ohms']
          : int.tryParse(json['impedance_ohms']?.toString() ?? ''),
      powerRmsW: json['power_rms_w'] is int
          ? json['power_rms_w']
          : int.tryParse(json['power_rms_w']?.toString() ?? ''),
      powerProgramW: json['power_program_w'] is int
          ? json['power_program_w']
          : int.tryParse(json['power_program_w']?.toString() ?? ''),
      powerPeakW: json['power_peak_w'] is int
          ? json['power_peak_w']
          : int.tryParse(json['power_peak_w']?.toString() ?? ''),
      maxVoltageVrms: json['max_voltage_vrms'] is double
          ? json['max_voltage_vrms']
          : double.tryParse(json['max_voltage_vrms']?.toString() ?? ''),
      isWifiByDefault: json['is_wifi_by_default'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categorie': categorie,
      'sous_categorie': sousCategorie,
      'marque': marque,
      'produit': produit,
      'taille': taille,
      'dimensions': dimensions,
      'poids': poids,
      'conso': conso,
      'image_url': imageUrl,
      'resolution_dalle': resolutionDalle,
      'angle': angle,
      'lux': lux,
      'lumens': lumens,
      'definition': definition,
      'dmx_max': dmxMax,
      'dmx_mini': dmxMini,
      'resolution': resolution,
      'pitch': pitch,
      'optiques': optiques?.map((x) => x.toJson()).toList(),
      'puissance_admissible': puissanceAdmissible,
      'impedance_nominale': impedanceNominale,
      'impedance_ohms': impedanceOhms,
      'power_rms_w': powerRmsW,
      'power_program_w': powerProgramW,
      'power_peak_w': powerPeakW,
      'max_voltage_vrms': maxVoltageVrms,
      'is_wifi_by_default': isWifiByDefault,
    };
  }
}
