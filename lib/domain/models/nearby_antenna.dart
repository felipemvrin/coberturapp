import 'mobile_operator.dart';
import 'mobile_technology.dart';
import 'signal_quality.dart';

class NearbyAntenna {
  const NearbyAntenna({
    required this.operator,
    required this.distanceKm,
    required this.technology,
    required this.signalQuality,
    required this.direction,
    required this.latitude,
    required this.longitude,
  });

  final MobileOperator operator;
  final double distanceKm;
  final MobileTechnology technology;
  final SignalQuality signalQuality;
  final String direction;
  final double? latitude;
  final double? longitude;
}
