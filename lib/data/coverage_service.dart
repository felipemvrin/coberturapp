import 'csv_coverage_repository.dart';

/// Servicio singleton para acceder al repositorio de cobertura
class CoverageService {
  static final CoverageService _instance = CoverageService._internal();
  late final CsvCoverageRepository _repository;

  CoverageService._internal() {
    _repository = CsvCoverageRepository();
  }

  factory CoverageService() {
    return _instance;
  }

  CsvCoverageRepository get repository => _repository;
}
