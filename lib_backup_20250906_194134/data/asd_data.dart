// lib/data/asd_data.dart

/// Entrée de tableau de charge pour une portée donnée (span en m)
class ASDLoadEntry {
  /// Portée (en mètres)
  final double span;

  /// Charge uniformément répartie maximale (UDL) en kg/m
  final double udl;

  /// Flèche maximale admissible en mm
  final double deflection;

  const ASDLoadEntry({
    required this.span,
    required this.udl,
    required this.deflection,
  });
}

/// Données de charge par profilé ASD
class ASDStructure {
  /// Référence du profilé (ex. "H30V")
  final String reference;

  /// Poids propre par mètre en kg/m
  final double selfWeightPerMeter;

  /// Tableau des charges admissibles selon la portée
  final List<ASDLoadEntry> loadTable;

  const ASDStructure({
    required this.reference,
    required this.selfWeightPerMeter,
    required this.loadTable,
  });
}

/// Tables de charge pour les profilés fournis
const List<ASDStructure> asdStructures = [
  ASDStructure(
    reference: 'E20D',
    selfWeightPerMeter: 6.5,
    loadTable: [
      ASDLoadEntry(span: 3, udl: 97.2, deflection: 10),
      ASDLoadEntry(span: 4, udl: 54.0, deflection: 18),
      ASDLoadEntry(span: 5, udl: 34.1, deflection: 28),
      ASDLoadEntry(span: 6, udl: 23.2, deflection: 40),
      ASDLoadEntry(span: 7, udl: 16.7, deflection: 54),
      ASDLoadEntry(span: 8, udl: 12.4, deflection: 71),
      ASDLoadEntry(span: 9, udl: 9.5, deflection: 89),
      ASDLoadEntry(span: 10, udl: 7.4, deflection: 110),
      ASDLoadEntry(span: 11, udl: 5.9, deflection: 133),
      ASDLoadEntry(span: 12, udl: 4.7, deflection: 159),
      ASDLoadEntry(span: 13, udl: 3.8, deflection: 186),
      ASDLoadEntry(span: 14, udl: 3.1, deflection: 216),
      ASDLoadEntry(span: 15, udl: 2.5, deflection: 248),
      ASDLoadEntry(span: 16, udl: 2.0, deflection: 282),
      ASDLoadEntry(span: 17, udl: 1.6, deflection: 319),
      ASDLoadEntry(span: 18, udl: 1.3, deflection: 357),
    ],
  ),
  ASDStructure(
    reference: 'X30D',
    selfWeightPerMeter: 7.1,
    loadTable: [
      ASDLoadEntry(span: 3, udl: 443.7, deflection: 13),
      ASDLoadEntry(span: 4, udl: 248.1, deflection: 23),
      ASDLoadEntry(span: 5, udl: 157.6, deflection: 36),
      ASDLoadEntry(span: 6, udl: 108.4, deflection: 52),
      ASDLoadEntry(span: 7, udl: 78.7, deflection: 71),
      ASDLoadEntry(span: 8, udl: 59.5, deflection: 93),
      ASDLoadEntry(span: 9, udl: 46.3, deflection: 118),
      ASDLoadEntry(span: 10, udl: 36.8, deflection: 146),
      ASDLoadEntry(span: 11, udl: 29.8, deflection: 176),
      ASDLoadEntry(span: 12, udl: 24.5, deflection: 210),
      ASDLoadEntry(span: 13, udl: 20.4, deflection: 246),
      ASDLoadEntry(span: 14, udl: 17.1, deflection: 285),
      ASDLoadEntry(span: 15, udl: 14.5, deflection: 328),
      ASDLoadEntry(span: 16, udl: 12.3, deflection: 373),
    ],
  ),
  ASDStructure(
    reference: 'H30V',
    selfWeightPerMeter: 8.3,
    loadTable: [
      ASDLoadEntry(span: 3, udl: 649.0, deflection: 10),
      ASDLoadEntry(span: 4, udl: 485.3, deflection: 18),
      ASDLoadEntry(span: 5, udl: 387.1, deflection: 28),
      ASDLoadEntry(span: 6, udl: 321.6, deflection: 41),
      ASDLoadEntry(span: 7, udl: 255.6, deflection: 56),
      ASDLoadEntry(span: 8, udl: 194.4, deflection: 73),
      ASDLoadEntry(span: 9, udl: 152.4, deflection: 92),
      ASDLoadEntry(span: 10, udl: 122.3, deflection: 114),
      ASDLoadEntry(span: 11, udl: 100.1, deflection: 137),
      ASDLoadEntry(span: 12, udl: 83.2, deflection: 164),
      ASDLoadEntry(span: 13, udl: 70.1, deflection: 192),
      ASDLoadEntry(span: 14, udl: 59.6, deflection: 223),
      ASDLoadEntry(span: 15, udl: 51.2, deflection: 256),
      ASDLoadEntry(span: 16, udl: 44.3, deflection: 291),
      ASDLoadEntry(span: 17, udl: 38.6, deflection: 328),
      ASDLoadEntry(span: 18, udl: 33.8, deflection: 368),
      ASDLoadEntry(span: 19, udl: 29.8, deflection: 410),
      ASDLoadEntry(span: 20, udl: 26.3, deflection: 454),
    ],
  ),
  ASDStructure(
    reference: 'H40V',
    selfWeightPerMeter: 12.5,
    loadTable: [
      ASDLoadEntry(span: 3, udl: 834.5, deflection: 7),
      ASDLoadEntry(span: 4, udl: 624.0, deflection: 13),
      ASDLoadEntry(span: 5, udl: 497.8, deflection: 20),
      ASDLoadEntry(span: 6, udl: 413.6, deflection: 29),
      ASDLoadEntry(span: 7, udl: 353.5, deflection: 40),
      ASDLoadEntry(span: 8, udl: 276.5, deflection: 52),
      ASDLoadEntry(span: 9, udl: 217.0, deflection: 65),
      ASDLoadEntry(span: 10, udl: 174.4, deflection: 81),
      ASDLoadEntry(span: 11, udl: 142.9, deflection: 98),
      ASDLoadEntry(span: 12, udl: 118.9, deflection: 116),
      ASDLoadEntry(span: 13, udl: 100.2, deflection: 137),
      ASDLoadEntry(span: 14, udl: 85.4, deflection: 158),
      ASDLoadEntry(span: 15, udl: 73.5, deflection: 182),
      ASDLoadEntry(span: 16, udl: 63.7, deflection: 207),
      ASDLoadEntry(span: 17, udl: 55.6, deflection: 234),
      ASDLoadEntry(span: 18, udl: 48.8, deflection: 262),
      ASDLoadEntry(span: 19, udl: 43.1, deflection: 292),
      ASDLoadEntry(span: 20, udl: 38.2, deflection: 323),
    ],
  ),
];
