import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_constants.dart';
import '../domain/models/connection_status.dart';
import '../domain/models/coverage_snapshot.dart';
import '../domain/models/signal_quality.dart';
import '../domain/utils/location_utils.dart';
import 'mock_coverage_repository.dart';
import 'subtel_data_service.dart';

class CsvCoverageRepository {
  static final Distance _distance = Distance();
  static final MockCoverageRepository _mockRepo = const MockCoverageRepository();

  /// Obtiene el snapshot de cobertura actual basado en ubicación real
  /// y datos de antenas del CSV
  Future<CoverageSnapshot> getSnapshot({LatLng? userLocation}) async {
    try {
      // Si no se proporciona ubicación, obtener la actual
      final location = userLocation ?? await _getCurrentLocation();
      
      // Cargar todas las antenas del CSV
      final allAntennas = await SubtelDataService.loadAllRegions();
      
      if (allAntennas.isEmpty) {
        // Fallback a mock data si no hay antenas
        return _mockRepo.getSnapshot();
      }

      // Calcular distancia y dirección a cada antena
      final antennasWithDistance = allAntennas.where((antenna) {
        // Filtrar antenas sin coordenadas válidas
        return antenna.latitude != null && antenna.longitude != null;
      }).map((antenna) {
        final antennaLocation = LatLng(antenna.latitude!, antenna.longitude!);
        final distKm = _distance.as(LengthUnit.Kilometer, location, antennaLocation);
        final bearing = LocationUtils.calculateBearing(location, antennaLocation);
        
        return antenna.copyWith(
          distanceKm: distKm,
          direction: LocationUtils.bearingToDirection(bearing),
          signalQuality: LocationUtils.getSignalQualityByDistance(distKm),
        );
      }).toList();

      // Ordenar por distancia
      antennasWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

      if (antennasWithDistance.isEmpty) {
        return _mockRepo.getSnapshot();
      }

      // La más cercana es el nearestAntenna
      final nearest = antennasWithDistance.first;
      
      // Las 5 más cercanas para el listado
      final nearby = antennasWithDistance.take(5).toList();

      // Determinar status de conexión basado en antena más cercana
      final connectionStatus = nearest.distanceKm < AppConstants.connectionThresholdKm
          ? ConnectionStatus.connected
          : ConnectionStatus.noConnection;

      return CoverageSnapshot(
        connectionStatus: connectionStatus,
        operator: nearest.operator,
        technology: nearest.technology,
        signalQuality: nearest.signalQuality,
        lastSignalDistanceKm: nearest.distanceKm,
        nearestAntenna: nearest,
        nearbyAntennas: nearby,
      );
    } catch (e) {
      // En caso de error, retornar mock data
      return _mockRepo.getSnapshot();
    }
  }

  /// Calcula el bearing (rumbo) entre dos puntos en grados (0-360)
  static double _calculateBearing(LatLng from, LatLng to) {
    return LocationUtils.calculateBearing(from, to);
  }

  /// Convierte bearing en grados a dirección cardinal (N, NE, E, etc)
  static String _bearingToDirection(double bearing) {
    return LocationUtils.bearingToDirection(bearing);
  }

  /// Determina la calidad de señal basada en la distancia
  static SignalQuality _getSignalQualityByDistance(double distanceKm) {
    return LocationUtils.getSignalQualityByDistance(distanceKm);
  }

  /// Obtiene la ubicación actual del usuario
  static Future<LatLng> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        timeLimit: AppConstants.locationTimeoutDuration,
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // Por defecto, Santiago Centro (Recoleta)
      return LatLng(
        AppConstants.defaultLatitude,
        AppConstants.defaultLongitude,
      );
    }
  }
}
