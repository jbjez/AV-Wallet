import 'app_localizations.dart';

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([super.locale = 'es']);

  @override
  String get appTitle => 'AV Wallet';

  @override
  String get welcomeMessage => 'Bienvenido a AV Wallet';

  @override
  String get catalogAccess => 'Acceder al catálogo';

  @override
  String get lightMenu => 'Luz';

  @override
  String get structureMenu => 'Estructura';

  @override
  String get soundMenu => 'Sonido';

  @override
  String get videoMenu => 'Video';

  @override
  String get electricityMenu => 'Electricidad';

  @override
  String get networkMenu => 'Red';

  @override
  String get lightPage_title => 'Luz';

  @override
  String get structurePage_title => 'Estructura';

  @override
  String get selectStructure => 'Seleccionar estructura';

  @override
  String distance_label(Object distance) {
    return '$distance m';
  }

  @override
  String charge_max(Object unit, Object value) {
    return 'Carga máxima: $value kg$unit';
  }

  @override
  String beam_weight(Object value) {
    return 'Peso de la viga (sin cargas): $value kg';
  }

  @override
  String max_deflection(Object value) {
    return 'Deflexión máxima: $value mm';
  }

  @override
  String get deflection_rate => 'Tasa de deflexión considerada: 1/200';

  @override
  String get structurePage_selectCharge => 'Tipo de carga';

  @override
  String get soundPage_title => 'Sonido';

  @override
  String get soundPage_amplificationLA => 'Amplificación LA';

  @override
  String get soundPage_delay => 'Retardo';

  @override
  String get soundPage_decibelMeter => 'Medidor de decibelios';

  @override
  String get soundPage_selectSpeaker => 'Seleccionar altavoz';

  @override
  String get soundPage_selectedSpeakers => 'Altavoces seleccionados';

  @override
  String get soundPage_quantity => 'Cantidad';

  @override
  String get soundPage_calculate => 'Calcular';

  @override
  String get soundPage_reset => 'Reiniciar';

  @override
  String get soundPage_optimalConfig =>
      'Configuración de amplificación recomendada';

  @override
  String get soundPage_noConfig =>
      'No se encontró una configuración óptima para esta combinación de altavoces';

  @override
  String get soundPage_checkCompat =>
      'Por favor, verifique las compatibilidades';

  @override
  String get soundPage_addPreset => 'Añadir preset';

  @override
  String get soundPage_presetName => 'Nombre del preset';

  @override
  String get soundPage_enterPresetName => 'Introducir nombre del preset';

  @override
  String get soundPage_save => 'Guardar';

  @override
  String get soundPage_cancel => 'Cancelar';

  @override
  String get catalogPage_title => 'Catálogo';

  @override
  String get catalogPage_search => 'Buscar';

  @override
  String get catalogPage_category => 'Categoría';

  @override
  String get catalogPage_subCategory => 'Subcategoría';

  @override
  String get catalogPage_brand => 'Marca';

  @override
  String get catalogPage_product => 'Producto';

  @override
  String get catalogPage_addToCart => 'Añadir al carrito';

  @override
  String get catalogPage_quantity => 'Cantidad';

  @override
  String get catalogPage_enterQuantity => 'Introducir cantidad';

  @override
  String get catalogPage_cart => 'Carrito';

  @override
  String get catalogPage_emptyCart => 'Su carrito está vacío';

  @override
  String get catalogPage_total => 'Total';

  @override
  String get catalogPage_checkout => 'Finalizar compra';

  @override
  String get catalogPage_clearCart => 'Vaciar carrito';

  @override
  String get catalogPage_remove => 'Eliminar';

  @override
  String get catalogPage_confirm => 'Confirmar';

  @override
  String get catalogPage_cancel => 'Cancelar';

  @override
  String get catalogPage_weight => 'Peso';

  @override
  String get presetWidget_title => 'Presets';

  @override
  String get presetWidget_add => 'Añadir preset';

  @override
  String get presetWidget_edit => 'Editar';

  @override
  String get presetWidget_delete => 'Eliminar';

  @override
  String get presetWidget_confirmDelete =>
      '¿Está seguro de que desea eliminar este preset?';

  @override
  String get presetWidget_yes => 'Sí';

  @override
  String get presetWidget_no => 'No';

  @override
  String get projectCalculationPage_title => 'Cálculo de proyecto';

  @override
  String get projectCalculationPage_powerProject => 'Proyecto de potencia';

  @override
  String get projectCalculationPage_weightProject => 'Proyecto de peso';

  @override
  String get projectCalculationPage_noPresetSelected =>
      'Ningún preset seleccionado';

  @override
  String get projectCalculationPage_powerConsumption => 'Consumo eléctrico';

  @override
  String get projectCalculationPage_weight => 'Peso';

  @override
  String get projectCalculationPage_total => 'Total';

  @override
  String get projectCalculationPage_presetTotal => 'Total del preset';

  @override
  String get projectCalculationPage_globalTotal => 'Total global';

  @override
  String get videoPage_title => 'Video';

  @override
  String get videoPage_videoCalculation => 'Cálculo de video';

  @override
  String get videoPage_videoSimulation => 'Simulación de video';

  @override
  String get videoPage_videoControl => 'Control de video';

  @override
  String get electricityPage_title => 'Electricidad';

  @override
  String get electricityPage_project => 'Proyecto';

  @override
  String get electricityPage_calculations => 'Cálculos';

  @override
  String get electricityPage_noPresetSelected => 'Ningún preset seleccionado';

  @override
  String get electricityPage_selectedPreset => 'Preset seleccionado';

  @override
  String get electricityPage_powerConsumption => 'Consumo eléctrico';

  @override
  String get electricityPage_presetTotal => 'Total del preset';

  @override
  String get electricityPage_globalTotal => 'Total global';

  @override
  String get electricityPage_consumptionByCategory => 'Consumo por categoría';

  @override
  String get electricityPage_powerCalculation => 'Cálculo de potencia';

  @override
  String get electricityPage_voltage => 'Tensión';

  @override
  String get electricityPage_phase => 'Fase';

  @override
  String get electricityPage_threePhase => 'Trifásico';

  @override
  String get electricityPage_singlePhase => 'Monofásico';

  @override
  String get electricityPage_current => 'Corriente (A)';

  @override
  String get electricityPage_power => 'Potencia (W)';

  @override
  String get electricityPage_powerConversion => 'Conversión de potencia';

  @override
  String get electricityPage_kw => 'Potencia activa (kW)';

  @override
  String get electricityPage_kva => 'Potencia aparente (kVA)';

  @override
  String get electricityPage_powerFactor => 'Factor de potencia';

  @override
  String get networkPage_title => 'Red';

  @override
  String get networkPage_bandwidth => 'Ancho de banda';

  @override
  String get networkPage_networkScan => 'Escaneo de red';

  @override
  String get networkPage_detectedNetwork => 'Red detectada';

  @override
  String get networkPage_noNetworkDetected => 'Ninguna red detectada';

  @override
  String get networkPage_testBandwidth => 'Iniciar prueba';

  @override
  String get networkPage_testResults => 'Resultados de la prueba';

  @override
  String get networkPage_bandwidthTestInProgress =>
      'Prueba de ancho de banda en progreso...';

  @override
  String get networkPage_download => 'Descarga';

  @override
  String get networkPage_upload => 'Subida';

  @override
  String get networkPage_downloadError => 'Error durante la descarga';

  @override
  String get networkPage_scanError => 'Error durante el escaneo de red';

  @override
  String get networkPage_noNetworksFound => 'No se encontraron redes';

  @override
  String get networkPage_signalStrength => 'Intensidad de señal';

  @override
  String get networkPage_frequency => 'Frecuencia';

  @override
  String get soundPage_addToCart => 'Añadir al carrito';

  @override
  String get soundPage_preferredAmplifier => 'Amplificador preferido';

  @override
  String get lightPage_beamCalculation => 'Cálculo de haz';

  @override
  String get lightPage_driverCalculation => 'Cálculo de driver LED';

  @override
  String get lightPage_dmxCalculation => 'Cálculo DMX';

  @override
  String get lightPage_angleRange => 'Ángulo (1° a 70°)';

  @override
  String get lightPage_heightRange => 'Altura (1m a 20m)';

  @override
  String get lightPage_distanceRange => 'Distancia (1m a 40m)';

  @override
  String get lightPage_measureDistance => 'Medir su distancia';

  @override
  String get lightPage_calculate => 'Calcular';

  @override
  String get lightPage_selectedProducts => 'Productos seleccionados';

  @override
  String get lightPage_reset => 'Reiniciar';

  @override
  String get lightPage_ledLength => 'Longitud LED (en metros)';

  @override
  String get lightPage_brand => 'Marca';

  @override
  String get lightPage_product => 'Producto';

  @override
  String get lightPage_searchProduct => 'Buscar producto...';

  @override
  String get lightPage_quantity => 'Cantidad';

  @override
  String get lightPage_enterQuantity => 'Introducir cantidad';

  @override
  String get lightPage_cancel => 'Cancelar';

  @override
  String get lightPage_ok => 'OK';

  @override
  String get lightPage_savePreset => 'Guardar preset';

  @override
  String get lightPage_presetName => 'Nombre del preset';

  @override
  String get lightPage_enterPresetName => 'Introducir nombre del preset';

  @override
  String get presetWidget_newPreset => 'Nuevo preset';

  @override
  String get presetWidget_renamePreset => 'Renombrar preset';

  @override
  String get presetWidget_newName => 'Nuevo nombre';

  @override
  String get presetWidget_create => 'Crear';

  @override
  String get presetWidget_defaultProject => 'Su proyecto';

  @override
  String get presetWidget_rename => 'Renombrar';

  @override
  String get presetWidget_cancel => 'Cancelar';

  @override
  String get presetWidget_confirm => 'Confirmar';

  @override
  String get presetWidget_addToCart => 'Añadir al carrito';

  @override
  String get presetWidget_preferredAmplifier => 'Amplificador preferido';

  @override
  String get lightPage_confirm => 'Confirmar';

  @override
  String get lightPage_noFixturesSelected => 'Ningún proyector seleccionado';

  @override
  String get lightPage_save => 'Guardar';

  @override
  String get soundPage_amplificationTab => 'Amplificación';

  @override
  String get soundPage_decibelMeterTab => 'Medidor de decibelios';

  @override
  String get soundPage_calculProjectTab => 'Cálculo de proyecto';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get signOut => 'Cerrar sesión';
}
