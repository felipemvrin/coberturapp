import 'package:flutter/services.dart';
import '../config/app_constants.dart';
import '../domain/models/mobile_operator.dart';
import '../domain/models/mobile_technology.dart';
import '../domain/models/nearby_antenna.dart';
import '../domain/models/signal_quality.dart';

/// Servicio para cargar y parsear datos de antenas desde CSV de SUBTEL
class SubtelDataService {
  /// Carga y parsea el archivo CSV especificado
  static Future<List<NearbyAntenna>> loadRegion(String region) async {
    try {
      final csvContent = await rootBundle.loadString('assets/data/$region.csv');
      return _parseAntennas(csvContent);
    } catch (e) {
      // Log omitido por performance
      return [];
    }
  }

  /// Carga todas las regiones disponibles
  static Future<List<NearbyAntenna>> loadAllRegions() async {
    final allAntennas = <NearbyAntenna>[];
    
    for (final region in AppConstants.availableRegions) {
      final antennas = await loadRegion(region);
      allAntennas.addAll(antennas);
    }
    
    return allAntennas;
  }

  /// Parsea el contenido CSV y devuelve lista de antenas
  static List<NearbyAntenna> _parseAntennas(String csvContent) {
    final lines = csvContent.split('\n').skip(1); // Skip header
    final antennas = <NearbyAntenna>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        // Parse CSV con quoted fields
        final fields = _parseCsvLine(line);
        if (fields.length < 8) continue;

        final empresa = fields[3].trim();
        final latStr = fields[6].trim();
        final lonStr = fields[7].trim();

        final lat = _dmsToDecimal(latStr, negativeByDefault: true);
        final lon = _dmsToDecimal(lonStr, negativeByDefault: true);

        antennas.add(
          NearbyAntenna(
            operator: _getOperator(empresa),
            distanceKm: 0, // Se calcula en tiempo real desde ubicación del usuario
            technology: MobileTechnology.fourG,
            signalQuality: SignalQuality.fair, // Se recalcula basado en distancia en CsvCoverageRepository
            direction: '',
            latitude: lat,
            longitude: lon,
          ),
        );
      } catch (_) {
        // Skip filas mal formadas
        continue;
      }
    }

    return antennas;
  }

  /// Convierte coordenadas DMS (grados°minutos"segundos) a decimal
  static double _dmsToDecimal(
    String dms, {
    required bool negativeByDefault,
  }) {
    final normalized = dms.toUpperCase();
    final isNegative = normalized.contains('S') ||
        normalized.contains('W') ||
        negativeByDefault && !normalized.contains('N') && !normalized.contains('E');

    dms = dms.replaceAll(RegExp(r'["°]'), ' ').trim();
    final parts = dms.split(RegExp(r'\s+'));
    if (parts.isEmpty) return 0;
    final degrees = double.tryParse(parts[0]) ?? 0;
    final minutes = parts.length > 1 ? double.tryParse(parts[1]) ?? 0 : 0;
    final seconds = parts.length > 2 ? double.tryParse(parts[2]) ?? 0 : 0;
    final value = degrees.abs() + (minutes / 60) + (seconds / 3600);
    return isNegative ? -value : value;
  }

  /// Obtiene el operador móvil de la cadena de texto del CSV
  static MobileOperator _getOperator(String empresa) {
    final normalized = empresa.toUpperCase();
    if (normalized.contains('MOVISTAR')) {
      return const MobileOperator(name: 'Movistar', code: 'MOV', colorHex: '#FFB547');
    } else if (normalized.contains('ENTEL')) {
      return const MobileOperator(name: 'Entel', code: 'ENT', colorHex: '#32D583');
    } else if (normalized.contains('CLARO')) {
      return const MobileOperator(name: 'Claro', code: 'CLA', colorHex: '#FF0000');
    } else if (normalized.contains('WOM')) {
      return const MobileOperator(name: 'WOM', code: 'WOM', colorHex: '#F97068');
    }
    return MobileOperator(name: empresa, code: 'UNK', colorHex: '#999999');
  }

  /// Parse CSV respetando quoted fields
  static List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    var current = '';
    var inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current += char;
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        fields.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    fields.add(current);
    return fields;
  }
}
