class AmpModeSpec {
  final String name;         // "4ch", "2ch", "Bridge"…
  final int channels;        // ex. 4
  final bool sharedPSU;      // headroom mutualisé ?
  
  const AmpModeSpec({
    required this.name, 
    required this.channels, 
    this.sharedPSU = true
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'channels': channels,
      'sharedPSU': sharedPSU,
    };
  }

  factory AmpModeSpec.fromMap(Map<String, dynamic> map) {
    return AmpModeSpec(
      name: map['name'] as String,
      channels: map['channels'] as int,
      sharedPSU: map['sharedPSU'] as bool? ?? true,
    );
  }
}

class PerChannelPower {
  final Map<int, int> wattsAtOhms; // {2: 2500, 4: 1800, 8: 1000}
  
  const PerChannelPower(this.wattsAtOhms);

  Map<String, dynamic> toMap() {
    return {
      'wattsAtOhms': wattsAtOhms.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  factory PerChannelPower.fromMap(Map<String, dynamic> map) {
    final wattsMap = map['wattsAtOhms'] as Map<String, dynamic>? ?? {};
    return PerChannelPower(
      wattsMap.map((k, v) => MapEntry(int.parse(k), v as int)),
    );
  }
}

class AmplifierSpec {
  final String brand;                      // "L-Acoustics"
  final String model;                      // "LA12X"
  final int minLoadOhms;                   // 2, 4…
  final int maxParallelPerChannel;         // sécurité câblage
  final Map<String, AmpModeSpec> modes;    // {"4ch": …, "Bridge": …}
  final Map<String, PerChannelPower> power;// {"4ch": PerChannelPower({...})}
  
  const AmplifierSpec({
    required this.brand,
    required this.model,
    required this.minLoadOhms,
    required this.maxParallelPerChannel,
    required this.modes,
    required this.power,
  });

  /// Clé unique pour identifier l'amplificateur
  String get key => '$brand:$model';

  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'model': model,
      'minLoadOhms': minLoadOhms,
      'maxParallelPerChannel': maxParallelPerChannel,
      'modes': modes.map((k, v) => MapEntry(k, v.toMap())),
      'power': power.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory AmplifierSpec.fromMap(Map<String, dynamic> map) {
    return AmplifierSpec(
      brand: map['brand'] as String,
      model: map['model'] as String,
      minLoadOhms: map['minLoadOhms'] as int,
      maxParallelPerChannel: map['maxParallelPerChannel'] as int,
      modes: (map['modes'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, AmpModeSpec.fromMap(v as Map<String, dynamic>))),
      power: (map['power'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, PerChannelPower.fromMap(v as Map<String, dynamic>))),
    );
  }

  /// Obtient la puissance disponible pour un mode et une impédance donnés
  int? getPowerForModeAndImpedance(String mode, int impedanceOhms) {
    final modePower = power[mode];
    if (modePower == null) return null;
    return modePower.wattsAtOhms[impedanceOhms];
  }

  /// Vérifie si l'amplificateur peut gérer l'impédance demandée
  bool canHandleImpedance(int impedanceOhms) {
    return impedanceOhms >= minLoadOhms;
  }

  /// Vérifie si l'amplificateur peut gérer le nombre de canaux en parallèle
  bool canHandleParallelChannels(int parallelCount) {
    return parallelCount <= maxParallelPerChannel;
  }
}
