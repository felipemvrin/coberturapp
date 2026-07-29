import 'connection_status.dart';
import 'mobile_operator.dart';
import 'mobile_technology.dart';
import 'nearby_antenna.dart';
import 'signal_quality.dart';

class CoverageSnapshot {
  const CoverageSnapshot({
    required this.connectionStatus,
    required this.operator,
    required this.technology,
    required this.signalQuality,
    required this.nearestAntenna,
    required this.nearbyAntennas,
    required this.lastSignalDistanceKm,
  });

  final ConnectionStatus connectionStatus;
  final MobileOperator operator;
  final MobileTechnology technology;
  final SignalQuality signalQuality;
  final NearbyAntenna nearestAntenna;
  final List<NearbyAntenna> nearbyAntennas;
  final double lastSignalDistanceKm;
}
