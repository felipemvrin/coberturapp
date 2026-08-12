/// Strings de la aplicación (textos)
/// 
/// Esta clase centraliza todos los strings usados en la app.
/// Facilita mantenimiento, traducción (i18n) y consistencia.
class AppStrings {
  AppStrings._(); // Constructor privado para impedir instanciación

  // Pantalla principal (HomeScreen)
  static const String appTitle = 'CoberturApp';
  static const String homeTagline = 'Que no se escape la señal.';
  static const String findBestSignalButton = 'BUSCAR MEJOR SEÑAL';
  static const String findBestSignalLoading = 'BUSCANDO...';
  static const String nearbyAntennasSection = 'ANTENAS CERCANAS';
  static const String viewMapButton = 'VER MAPA';

  // Tarjeta de estado de señal
  static const String lastSignalDistance = 'Última señal: {distance} km atrás';

  // Pantalla de mapa (MapScreen)
  static const String mapTitle = 'CoberturApp';

  // Errores y estados
  static const String errorLoadingCoverage = 'Error al cargar datos de cobertura';

  // Distancias (para información)
  /// Formato de distancia con 2 decimales
  static String formatDistance(double km) => '${km.toStringAsFixed(2)} km';
}
