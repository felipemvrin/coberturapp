/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._(); // Constructor privado para impedir instanciación

  // Ubicación por defecto (Santiago Centro, Recoleta)
  static const double defaultLatitude = -33.4489;
  static const double defaultLongitude = -70.6693;

  // Umbrales de conexión (en kilómetros)
  /// Distancia máxima para considerar que hay conexión móvil
  static const double connectionThresholdKm = 15.0;

  // Timeouts
  /// Timeout para obtener ubicación GPS actual
  static const Duration locationTimeoutDuration = Duration(seconds: 15);

  // Zoom del mapa
  /// Zoom inicial del mapa cuando se abre la app
  static const double mapInitialZoom = 17.0;

  // Datos de antenas y regiones
  /// Lista de regiones disponibles (CSV)
  /// Próximas versiones agregarán más regiones
  static const List<String> availableRegions = ['santiago-recoleta'];
}
