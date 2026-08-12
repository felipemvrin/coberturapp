import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/signal_quality.dart';

/// Utilidades de cálculo de ubicación y dirección
class LocationUtils {
  LocationUtils._(); // Constructor privado para impedir instanciación

  /// Calcula el rumbo (bearing) en grados (0-360) entre dos coordenadas
  /// 
  /// Utiliza la fórmula de navegación esférica para calcular la dirección
  /// inicial desde 'from' hacia 'to'.
  static double calculateBearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lon1 = from.longitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final lon2 = to.longitude * math.pi / 180;

    final dLon = lon2 - lon1;
    final x = math.sin(dLon) * math.cos(lat2);
    final y = math.cos(lat1) * math.sin(lat2) - 
              math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    
    final bearing = math.atan2(x, y);
    final degrees = (bearing * 180 / math.pi + 360) % 360;
    return degrees;
  }

  /// Convierte un rumbo en grados a dirección cardinal con brújula
  /// 
  /// Ejemplo: 45° → "NE 45°"
  static String bearingToDirection(double bearing) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((bearing + 11.25) / 22.5).toInt() % 16;
    return '${directions[index]} ${bearing.toStringAsFixed(0)}°';
  }

  /// Determina la calidad de señal basada en la distancia a la antena
  /// 
  /// Thresholds:
  /// - < 1 km: Excelente
  /// - < 2 km: Buena
  /// - < 4 km: Aceptable
  /// - < 6 km: Pobre
  /// - ≥ 6 km: Sin señal
  static SignalQuality getSignalQualityByDistance(double distanceKm) {
    if (distanceKm < 1.0) return SignalQuality.excellent;
    if (distanceKm < 2.0) return SignalQuality.good;
    if (distanceKm < 4.0) return SignalQuality.fair;
    if (distanceKm < 6.0) return SignalQuality.poor;
    return SignalQuality.none;
  }
}
