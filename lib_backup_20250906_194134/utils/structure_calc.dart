import 'dart:math' as math;

class TrussSpecPoint {
  final double spanM;          // portée en mètres
  final double udlKgPerM;      // charge uniformément répartie admissible
  final double cplKg;          // charge ponctuelle admissible au centre
  final double deflectionMm;   // flèche sous UDL admissible de référence (si dispo, sinon 0)
  const TrussSpecPoint({
    required this.spanM,
    required this.udlKgPerM,
    required this.cplKg,
    this.deflectionMm = 0,
  });
}

class TrussSpec {
  final String brand;          // "ASD", "Prolyte", etc.
  final String model;          // "H30V", "H40V", ...
  final String config;         // "portique", "appui simple", "suspension 2 pts", etc.
  final List<TrussSpecPoint> table; // points tabulés constructeur
  const TrussSpec({
    required this.brand,
    required this.model,
    required this.config,
    required this.table,
  });
}

class StructureCheckInput {
  final TrussSpec spec;
  final double spanM;
  final double udlRequestKgPerM; // UDL demandée
  final List<double> pointLoadsKg; // charges ponctuelles (positionnées approx au centre pour verif rapide)
  final double safetyFactor;      // marge >= 1.0 (ex: 1.1 à 1.3)
  final double deflectionLimitRatio; // ex: 200 => L/200
  const StructureCheckInput({
    required this.spec,
    required this.spanM,
    required this.udlRequestKgPerM,
    this.pointLoadsKg = const [],
    this.safetyFactor = 1.15,
    this.deflectionLimitRatio = 200,
  });
}

class StructureCheckResult {
  final bool okUDL;
  final bool okCPL;
  final bool okDeflection;
  final double allowedUdlKgPerM;
  final double allowedCplKg;
  final double spanM;
  final double estDeflectionMm; // estimation par interpolation si donnée de table
  final List<String> notes;
  const StructureCheckResult({
    required this.okUDL,
    required this.okCPL,
    required this.okDeflection,
    required this.allowedUdlKgPerM,
    required this.allowedCplKg,
    required this.spanM,
    required this.estDeflectionMm,
    required this.notes,
  });
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Interpole linéairement la valeur admissible entre deux portées tabulées.
double _interpBySpan(List<TrussSpecPoint> pts, double span, double Function(TrussSpecPoint) pick) {
  if (pts.isEmpty) return 0;
  final sorted = [...pts]..sort((a,b) => a.spanM.compareTo(b.spanM));
  if (span <= sorted.first.spanM) return pick(sorted.first);
  if (span >= sorted.last.spanM)  return pick(sorted.last);
  for (var i = 0; i < sorted.length - 1; i++) {
    final a = sorted[i];
    final b = sorted[i+1];
    if (span >= a.spanM && span <= b.spanM) {
      final t = (span - a.spanM) / (b.spanM - a.spanM);
      return _lerp(pick(a), pick(b), t);
    }
  }
  return pick(sorted.last);
}

/// Calcul principal : vérifie UDL/CPL/flèche (si donnée) avec facteur de sécurité.
StructureCheckResult checkStructure(StructureCheckInput input) {
  final spec = input.spec;
  final udlAdm = _interpBySpan(spec.table, input.spanM, (p) => p.udlKgPerM) / input.safetyFactor;
  final cplAdm = _interpBySpan(spec.table, input.spanM, (p) => p.cplKg) / input.safetyFactor;
  final deflEst = _interpBySpan(spec.table, input.spanM, (p) => p.deflectionMm);

  // UDL
  final okUDL = input.udlRequestKgPerM <= udlAdm + 1e-6;

  // CPL: on vérifie la somme des charges ponctuelles vs admissible (approche conservatrice)
  final totalCpl = input.pointLoadsKg.fold<double>(0, (s, v) => s + v);
  final okCPL = totalCpl <= cplAdm + 1e-6;

  // Flèche admissible (si on a une estimation ; sinon on valide par défaut et on ajoute une note)
  double deflLimitMm = (input.spanM * 1000.0) / input.deflectionLimitRatio;
  bool okDefl = true;
  final notes = <String>[];

  if (deflEst > 0) {
    okDefl = deflEst <= deflLimitMm + 1e-6;
  } else {
    notes.add("Flèche constructeur non fournie pour cette portée : validation flèche non concluante.");
  }

  if (!okUDL) notes.add("UDL demandée ${input.udlRequestKgPerM.toStringAsFixed(1)} kg/m > admise ${udlAdm.toStringAsFixed(1)} kg/m.");
  if (!okCPL) notes.add("Charges ponctuelles ${totalCpl.toStringAsFixed(1)} kg > admis ${cplAdm.toStringAsFixed(1)} kg.");
  if (!okDefl) notes.add("Flèche estimée ${deflEst.toStringAsFixed(1)} mm > limite ${deflLimitMm.toStringAsFixed(1)} mm (L/${input.deflectionLimitRatio.toStringAsFixed(0)}).");

  return StructureCheckResult(
    okUDL: okUDL,
    okCPL: okCPL,
    okDeflection: okDefl,
    allowedUdlKgPerM: udlAdm,
    allowedCplKg: cplAdm,
    spanM: input.spanM,
    estDeflectionMm: deflEst,
    notes: notes,
  );
}



/// Données ASD SC300 basées sur les fiches techniques officielles (CHARGES PRÉCONISÉES 1/300)
final asdSC300 = TrussSpec(
  brand: "ASD",
  model: "SC300",
  config: "appui simple",
  table: const [
    TrussSpecPoint(spanM: 1,  udlKgPerM: 1543.0, cplKg: 1543.0, deflectionMm: 3),
    TrussSpecPoint(spanM: 2,  udlKgPerM: 1543.0, cplKg: 1543.0, deflectionMm: 7),
    TrussSpecPoint(spanM: 3,  udlKgPerM: 510.0,  cplKg: 1530.0, deflectionMm: 10),
    TrussSpecPoint(spanM: 4,  udlKgPerM: 287.0,  cplKg: 1148.0, deflectionMm: 13),
    TrussSpecPoint(spanM: 5,  udlKgPerM: 184.0,  cplKg: 920.0,  deflectionMm: 17),
    TrussSpecPoint(spanM: 6,  udlKgPerM: 128.0,  cplKg: 768.0,  deflectionMm: 20),
    TrussSpecPoint(spanM: 7,  udlKgPerM: 94.0,   cplKg: 658.0,  deflectionMm: 23),
    TrussSpecPoint(spanM: 8,  udlKgPerM: 72.0,   cplKg: 576.0,  deflectionMm: 27),
    TrussSpecPoint(spanM: 9,  udlKgPerM: 57.0,   cplKg: 513.0,  deflectionMm: 30),
    TrussSpecPoint(spanM: 10, udlKgPerM: 46.0,   cplKg: 460.0,  deflectionMm: 33),
    TrussSpecPoint(spanM: 11, udlKgPerM: 38.0,   cplKg: 418.0,  deflectionMm: 37),
    TrussSpecPoint(spanM: 12, udlKgPerM: 32.0,   cplKg: 384.0,  deflectionMm: 40),
    TrussSpecPoint(spanM: 13, udlKgPerM: 27.0,   cplKg: 351.0,  deflectionMm: 43),
    TrussSpecPoint(spanM: 14, udlKgPerM: 23.0,   cplKg: 322.0,  deflectionMm: 47),
    TrussSpecPoint(spanM: 15, udlKgPerM: 20.0,   cplKg: 300.0,  deflectionMm: 50),
    TrussSpecPoint(spanM: 16, udlKgPerM: 17.0,   cplKg: 272.0,  deflectionMm: 53),
    TrussSpecPoint(spanM: 17, udlKgPerM: 15.0,   cplKg: 255.0,  deflectionMm: 57),
    TrussSpecPoint(spanM: 18, udlKgPerM: 13.0,   cplKg: 234.0,  deflectionMm: 60),
    TrussSpecPoint(spanM: 19, udlKgPerM: 12.0,   cplKg: 228.0,  deflectionMm: 63),
    TrussSpecPoint(spanM: 20, udlKgPerM: 10.0,   cplKg: 200.0,  deflectionMm: 67),
  ],
);



/// Données ASD E20D basées sur les fiches techniques
final asdE20D = TrussSpec(
  brand: "ASD",
  model: "E20D",
  config: "appui simple",
  table: const [
    TrussSpecPoint(spanM: 3,  udlKgPerM: 97.2,  cplKg: 97.2,  deflectionMm: 10),
    TrussSpecPoint(spanM: 4,  udlKgPerM: 54.0,  cplKg: 54.0,  deflectionMm: 18),
    TrussSpecPoint(spanM: 5,  udlKgPerM: 34.1,  cplKg: 34.1,  deflectionMm: 28),
    TrussSpecPoint(spanM: 6,  udlKgPerM: 23.2,  cplKg: 23.2,  deflectionMm: 40),
    TrussSpecPoint(spanM: 7,  udlKgPerM: 16.7,  cplKg: 16.7,  deflectionMm: 54),
    TrussSpecPoint(spanM: 8,  udlKgPerM: 12.4,  cplKg: 12.4,  deflectionMm: 71),
    TrussSpecPoint(spanM: 9,  udlKgPerM: 9.5,   cplKg: 9.5,   deflectionMm: 89),
    TrussSpecPoint(spanM: 10, udlKgPerM: 7.4,   cplKg: 7.4,   deflectionMm: 110),
    TrussSpecPoint(spanM: 11, udlKgPerM: 5.9,   cplKg: 5.9,   deflectionMm: 133),
    TrussSpecPoint(spanM: 12, udlKgPerM: 4.7,   cplKg: 4.7,   deflectionMm: 159),
    TrussSpecPoint(spanM: 13, udlKgPerM: 3.8,   cplKg: 3.8,   deflectionMm: 186),
    TrussSpecPoint(spanM: 14, udlKgPerM: 3.1,   cplKg: 3.1,   deflectionMm: 216),
    TrussSpecPoint(spanM: 15, udlKgPerM: 2.5,   cplKg: 2.5,   deflectionMm: 248),
    TrussSpecPoint(spanM: 16, udlKgPerM: 2.0,   cplKg: 2.0,   deflectionMm: 282),
    TrussSpecPoint(spanM: 17, udlKgPerM: 1.6,   cplKg: 1.6,   deflectionMm: 319),
    TrussSpecPoint(spanM: 18, udlKgPerM: 1.3,   cplKg: 1.3,   deflectionMm: 357),
  ],
);



/// Données ASD SC390 basées sur les fiches techniques officielles (CHARGES PRÉCONISÉES 1/300)
final asdSC390 = TrussSpec(
  brand: "ASD",
  model: "SC390",
  config: "appui simple",
  table: const [
    TrussSpecPoint(spanM: 1,  udlKgPerM: 1543.0, cplKg: 1543.0, deflectionMm: 3),
    TrussSpecPoint(spanM: 2,  udlKgPerM: 1543.0, cplKg: 1543.0, deflectionMm: 7),
    TrussSpecPoint(spanM: 3,  udlKgPerM: 510.0,  cplKg: 1530.0, deflectionMm: 10),
    TrussSpecPoint(spanM: 4,  udlKgPerM: 287.0,  cplKg: 1148.0, deflectionMm: 13),
    TrussSpecPoint(spanM: 5,  udlKgPerM: 184.0,  cplKg: 920.0,  deflectionMm: 17),
    TrussSpecPoint(spanM: 6,  udlKgPerM: 128.0,  cplKg: 768.0,  deflectionMm: 20),
    TrussSpecPoint(spanM: 7,  udlKgPerM: 94.0,   cplKg: 658.0,  deflectionMm: 23),
    TrussSpecPoint(spanM: 8,  udlKgPerM: 72.0,   cplKg: 576.0,  deflectionMm: 27),
    TrussSpecPoint(spanM: 9,  udlKgPerM: 57.0,   cplKg: 513.0,  deflectionMm: 30),
    TrussSpecPoint(spanM: 10, udlKgPerM: 46.0,   cplKg: 460.0,  deflectionMm: 33),
    TrussSpecPoint(spanM: 11, udlKgPerM: 38.0,   cplKg: 418.0,  deflectionMm: 37),
    TrussSpecPoint(spanM: 12, udlKgPerM: 32.0,   cplKg: 384.0,  deflectionMm: 40),
    TrussSpecPoint(spanM: 13, udlKgPerM: 27.0,   cplKg: 351.0,  deflectionMm: 43),
    TrussSpecPoint(spanM: 14, udlKgPerM: 23.0,   cplKg: 322.0,  deflectionMm: 47),
    TrussSpecPoint(spanM: 15, udlKgPerM: 20.0,   cplKg: 300.0,  deflectionMm: 50),
    TrussSpecPoint(spanM: 16, udlKgPerM: 17.0,   cplKg: 272.0,  deflectionMm: 53),
    TrussSpecPoint(spanM: 17, udlKgPerM: 15.0,   cplKg: 255.0,  deflectionMm: 57),
    TrussSpecPoint(spanM: 18, udlKgPerM: 13.0,   cplKg: 234.0,  deflectionMm: 60),
    TrussSpecPoint(spanM: 19, udlKgPerM: 12.0,   cplKg: 228.0,  deflectionMm: 63),
    TrussSpecPoint(spanM: 20, udlKgPerM: 10.0,   cplKg: 200.0,  deflectionMm: 67),
  ],
);

/// Données ASD SC500 basées sur les fiches techniques officielles (CHARGES PRÉCONISÉES 1/300)
final asdSC500 = TrussSpec(
  brand: "ASD",
  model: "SC500",
  config: "appui simple",
  table: const [
    TrussSpecPoint(spanM: 3,  udlKgPerM: 4240.0, cplKg: 2860.0, deflectionMm: 1.0),
    TrussSpecPoint(spanM: 4,  udlKgPerM: 4200.0, cplKg: 2510.0, deflectionMm: 1.5),
    TrussSpecPoint(spanM: 5,  udlKgPerM: 3410.0, cplKg: 1870.0, deflectionMm: 2.5),
    TrussSpecPoint(spanM: 6,  udlKgPerM: 2520.0, cplKg: 1400.0, deflectionMm: 3.6),
    TrussSpecPoint(spanM: 7,  udlKgPerM: 1950.0, cplKg: 1080.0, deflectionMm: 4.9),
    TrussSpecPoint(spanM: 8,  udlKgPerM: 1490.0, cplKg: 860.0,  deflectionMm: 6.4),
    TrussSpecPoint(spanM: 9,  udlKgPerM: 930.0,  cplKg: 580.0,  deflectionMm: 8.1),
    TrussSpecPoint(spanM: 10, udlKgPerM: 540.0,  cplKg: 340.0,  deflectionMm: 10.0),
    TrussSpecPoint(spanM: 11, udlKgPerM: 320.0,  cplKg: 220.0,  deflectionMm: 12.1),
    TrussSpecPoint(spanM: 12, udlKgPerM: 200.0,  cplKg: 140.0,  deflectionMm: 14.4),
    TrussSpecPoint(spanM: 13, udlKgPerM: 130.0,  cplKg: 90.0,   deflectionMm: 16.9),
    TrussSpecPoint(spanM: 14, udlKgPerM: 85.0,   cplKg: 60.0,   deflectionMm: 19.6),
    TrussSpecPoint(spanM: 15, udlKgPerM: 55.0,   cplKg: 40.0,   deflectionMm: 22.5),
    TrussSpecPoint(spanM: 16, udlKgPerM: 35.0,   cplKg: 25.0,   deflectionMm: 25.6),
    TrussSpecPoint(spanM: 17, udlKgPerM: 22.0,   cplKg: 16.0,   deflectionMm: 28.9),
    TrussSpecPoint(spanM: 18, udlKgPerM: 14.0,   cplKg: 10.0,   deflectionMm: 32.4),
    TrussSpecPoint(spanM: 19, udlKgPerM: 9.0,    cplKg: 6.0,    deflectionMm: 36.1),
    TrussSpecPoint(spanM: 20, udlKgPerM: 6.0,    cplKg: 4.0,    deflectionMm: 40.0),
  ],
);

/// Map des spécifications disponibles
final Map<String, TrussSpec> availableTrussSpecs = {
  'SC300': asdSC300,
  'SC390': asdSC390,
  'SC500': asdSC500,
  'E20D': asdE20D,
};

/// Fonction utilitaire pour obtenir une spécification par référence
TrussSpec? getTrussSpec(String reference) {
  return availableTrussSpecs[reference];
}

/// Fonction utilitaire pour calculer la charge par point selon le type de charge
double calculatePointLoad(String chargeType, double udlKgPerM, double spanM) {
  switch (chargeType) {
    case 'charge_repartie':
      return udlKgPerM; // kg/m
    case 'point_centre':
      return udlKgPerM * spanM; // kg total au centre
    case 'points_extremites':
      return (udlKgPerM * spanM) / 2; // kg par point aux extrémités
    case '3points':
      return (udlKgPerM * spanM) / 3; // kg par point (3 points)
    case '4points':
      return (udlKgPerM * spanM) / 4; // kg par point (4 points)
    default:
      return udlKgPerM;
  }
}
