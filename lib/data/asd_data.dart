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
    reference: 'SC300',
    selfWeightPerMeter: 7.0,
    loadTable: [
      ASDLoadEntry(span: 1, udl: 1543.0, deflection: 3),
      ASDLoadEntry(span: 2, udl: 768.0, deflection: 7),
      ASDLoadEntry(span: 3, udl: 510.0, deflection: 10),
      ASDLoadEntry(span: 4, udl: 381.0, deflection: 13),
      ASDLoadEntry(span: 5, udl: 303.0, deflection: 17),
      ASDLoadEntry(span: 6, udl: 252.0, deflection: 20),
      ASDLoadEntry(span: 7, udl: 177.0, deflection: 23),
      ASDLoadEntry(span: 8, udl: 117.0, deflection: 27),
      ASDLoadEntry(span: 9, udl: 80.0, deflection: 30),
      ASDLoadEntry(span: 10, udl: 56.0, deflection: 33),
      ASDLoadEntry(span: 11, udl: 41.0, deflection: 37),
      ASDLoadEntry(span: 12, udl: 30.0, deflection: 40),
      ASDLoadEntry(span: 13, udl: 22.0, deflection: 43),
      ASDLoadEntry(span: 14, udl: 16.0, deflection: 47),
      ASDLoadEntry(span: 15, udl: 12.0, deflection: 50),
      ASDLoadEntry(span: 16, udl: 9.0, deflection: 53),
      ASDLoadEntry(span: 17, udl: 6.0, deflection: 57),
      ASDLoadEntry(span: 18, udl: 4.0, deflection: 60),
      ASDLoadEntry(span: 19, udl: 3.0, deflection: 63),
      ASDLoadEntry(span: 20, udl: 1.0, deflection: 67),
    ],
  ),
  ASDStructure(
    reference: 'SC390',
    selfWeightPerMeter: 8.0,
    loadTable: [
      ASDLoadEntry(span: 1, udl: 2441.0, deflection: 3),
      ASDLoadEntry(span: 2, udl: 1217.0, deflection: 7),
      ASDLoadEntry(span: 3, udl: 809.0, deflection: 10),
      ASDLoadEntry(span: 4, udl: 604.0, deflection: 13),
      ASDLoadEntry(span: 5, udl: 482.0, deflection: 17),
      ASDLoadEntry(span: 6, udl: 369.0, deflection: 20),
      ASDLoadEntry(span: 7, udl: 269.0, deflection: 23),
      ASDLoadEntry(span: 8, udl: 204.0, deflection: 27),
      ASDLoadEntry(span: 9, udl: 160.0, deflection: 30),
      ASDLoadEntry(span: 10, udl: 118.0, deflection: 33),
      ASDLoadEntry(span: 11, udl: 87.0, deflection: 37),
      ASDLoadEntry(span: 12, udl: 65.0, deflection: 40),
      ASDLoadEntry(span: 13, udl: 49.0, deflection: 43),
      ASDLoadEntry(span: 14, udl: 38.0, deflection: 47),
      ASDLoadEntry(span: 15, udl: 29.0, deflection: 50),
      ASDLoadEntry(span: 16, udl: 23.0, deflection: 53),
      ASDLoadEntry(span: 17, udl: 18.0, deflection: 57),
      ASDLoadEntry(span: 18, udl: 14.0, deflection: 60),
      ASDLoadEntry(span: 19, udl: 11.0, deflection: 63),
      ASDLoadEntry(span: 20, udl: 8.0, deflection: 67),
    ],
  ),
  ASDStructure(
    reference: 'SC500',
    selfWeightPerMeter: 18.0,
    loadTable: [
      ASDLoadEntry(span: 1, udl: 4240.0, deflection: 3),
      ASDLoadEntry(span: 2, udl: 4240.0, deflection: 7),
      ASDLoadEntry(span: 3, udl: 1413.0, deflection: 10),
      ASDLoadEntry(span: 4, udl: 795.0, deflection: 13),
      ASDLoadEntry(span: 5, udl: 509.0, deflection: 17),
      ASDLoadEntry(span: 6, udl: 353.0, deflection: 20),
      ASDLoadEntry(span: 7, udl: 259.0, deflection: 23),
      ASDLoadEntry(span: 8, udl: 199.0, deflection: 27),
      ASDLoadEntry(span: 9, udl: 157.0, deflection: 30),
      ASDLoadEntry(span: 10, udl: 127.0, deflection: 33),
      ASDLoadEntry(span: 11, udl: 105.0, deflection: 37),
      ASDLoadEntry(span: 12, udl: 88.0, deflection: 40),
      ASDLoadEntry(span: 13, udl: 75.0, deflection: 43),
      ASDLoadEntry(span: 14, udl: 65.0, deflection: 47),
      ASDLoadEntry(span: 15, udl: 1950.0, deflection: 84),
      ASDLoadEntry(span: 16, udl: 1490.0, deflection: 116),
      ASDLoadEntry(span: 17, udl: 930.0, deflection: 135),
      ASDLoadEntry(span: 18, udl: 540.0, deflection: 154),
      ASDLoadEntry(span: 19, udl: 320.0, deflection: 173),
      ASDLoadEntry(span: 20, udl: 200.0, deflection: 200),
    ],
  ),
  ASDStructure(
    reference: 'E20D',
    selfWeightPerMeter: 1.6,
    loadTable: [
      ASDLoadEntry(span: 1, udl: 400.0, deflection: 3),
      ASDLoadEntry(span: 2, udl: 340.0, deflection: 6),
      ASDLoadEntry(span: 3, udl: 292.0, deflection: 10),
      ASDLoadEntry(span: 4, udl: 216.0, deflection: 18),
      ASDLoadEntry(span: 5, udl: 170.0, deflection: 28),
      ASDLoadEntry(span: 6, udl: 139.0, deflection: 40),
      ASDLoadEntry(span: 7, udl: 117.0, deflection: 54),
      ASDLoadEntry(span: 8, udl: 99.0, deflection: 71),
      ASDLoadEntry(span: 9, udl: 86.0, deflection: 89),
      ASDLoadEntry(span: 10, udl: 74.0, deflection: 110),
      ASDLoadEntry(span: 11, udl: 65.0, deflection: 133),
      ASDLoadEntry(span: 12, udl: 56.0, deflection: 159),
      ASDLoadEntry(span: 13, udl: 49.0, deflection: 186),
      ASDLoadEntry(span: 14, udl: 43.0, deflection: 216),
      ASDLoadEntry(span: 15, udl: 38.0, deflection: 248),
      ASDLoadEntry(span: 16, udl: 32.0, deflection: 282),
      ASDLoadEntry(span: 17, udl: 27.0, deflection: 319),
      ASDLoadEntry(span: 18, udl: 23.0, deflection: 357),
    ],
  ),
];

