import '../domain/models/connection_status.dart';
import '../domain/models/coverage_snapshot.dart';
import '../domain/models/mobile_operator.dart';
import '../domain/models/mobile_technology.dart';
import '../domain/models/nearby_antenna.dart';
import '../domain/models/signal_quality.dart';

class MockCoverageRepository {
  const MockCoverageRepository();

  CoverageSnapshot getSnapshot() {
    const entel = MobileOperator(name: 'Entel', code: 'ENT', colorHex: '#32D583');
    const movistar = MobileOperator(name: 'Movistar', code: 'MOV', colorHex: '#FFB547');
    const wom = MobileOperator(name: 'WOM', code: 'WOM', colorHex: '#F97068');

    return CoverageSnapshot(
      connectionStatus: ConnectionStatus.connected,
      operator: entel,
      technology: MobileTechnology.fourG,
      signalQuality: SignalQuality.good,
      lastSignalDistanceKm: 3.2,
      nearestAntenna: NearbyAntenna(
        operator: entel,
        distanceKm: 2.8,
        technology: MobileTechnology.fourG,
        signalQuality: SignalQuality.good,
        direction: 'NE 42°',
        latitude: -33.45,
        longitude: -70.66,
      ),
      nearbyAntennas: [
        NearbyAntenna(
          operator: entel,
          distanceKm: 2.8,
          technology: MobileTechnology.fourG,
          signalQuality: SignalQuality.good,
          direction: 'NE 42°',
          latitude: -33.45,
          longitude: -70.66,
        ),
        NearbyAntenna(
          operator: movistar,
          distanceKm: 5.2,
          technology: MobileTechnology.fourG,
          signalQuality: SignalQuality.fair,
          direction: 'E 18°',
          latitude: -33.46,
          longitude: -70.67,
        ),
        NearbyAntenna(
          operator: wom,
          distanceKm: 9.7,
          technology: MobileTechnology.unknown,
          signalQuality: SignalQuality.none,
          direction: 'S 12°',
          latitude: -33.47,
          longitude: -70.68,
        ),
      ],
    );
  }
}
