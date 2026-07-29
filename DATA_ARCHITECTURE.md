# Arquitectura de Datos - CoberturApp

## Descripción General

CoberturApp carga datos de antenas SUBTEL desde archivos CSV. La arquitectura está diseñada para ser escalable, permitiendo agregar múltiples regiones sin cambios mayores en el código.

## Estructura de Carpetas

```
lib/
├── data/
│   ├── subtel_data_service.dart    # Parsea CSV y convierte coordenadas
│   ├── csv_coverage_repository.dart # Carga datos y calcula distancias
│   ├── coverage_service.dart        # Singleton para acceder al repositorio
│   └── mock_coverage_repository.dart # Fallback para testing
├── domain/models/
│   ├── nearby_antenna.dart          # Modelo de antena
│   └── coverage_snapshot.dart       # Estado general de cobertura
└── presentation/
    └── home/home_screen.dart        # Consume datos vía CoverageService

assets/data/
├── santiago-recoleta.csv            # Datos de Recoleta
└── (futuros: santiago-centro.csv, valparaiso.csv, etc)
```

## Flujo de Datos

```
HomeScreen
    ↓
CoverageService.repository.getSnapshot()
    ↓
CsvCoverageRepository.getSnapshot()
    ├─→ Obtiene ubicación actual del usuario (Geolocator)
    ├─→ Carga antenas desde SubtelDataService
    ├─→ Calcula distancia a cada antena (latlong2)
    ├─→ Calcula dirección (bearing → brújula)
    ├─→ Ordena por distancia (más cercana primero)
    └─→ Retorna CoverageSnapshot con datos reales
```

## Cómo Agregar un Nuevo CSV

### Paso 1: Obtener el CSV
Descargar/copiar el CSV a `assets/data/` con naming convencional:
- `santiago-recoleta.csv` (región-comuna.csv)
- `valparaiso-centro.csv`
- `concepcion-centro.csv`

### Paso 2: Registrar en pubspec.yaml
```yaml
flutter:
  assets:
    - assets/data/santiago-recoleta.csv
    - assets/data/valparaiso-centro.csv  # agregar aquí
```

### Paso 3: Actualizar SubtelDataService

El servicio actual carga datos hardcodeados (mock). Para producción, cambiar a:

**Opción A: Cargar desde assets (Recomendado)**
```dart
static Future<List<NearbyAntenna>> parseAntennas(String region) async {
  final csvContent = await rootBundle.loadString('assets/data/$region.csv');
  // ...parse CSV...
}
```

**Opción B: Cargar todas las regiones disponibles**
```dart
static Future<Map<String, List<NearbyAntenna>>> parseAllRegions() async {
  final regions = ['santiago-recoleta', 'valparaiso-centro', 'concepcion-centro'];
  final allData = <String, List<NearbyAntenna>>{};
  for (final region in regions) {
    final csv = await rootBundle.loadString('assets/data/$region.csv');
    allData[region] = _parseAntennas(csv);
  }
  return allData;
}
```

### Paso 4: Filtrar por Región (Opcional)

Si el usuario está en una región específica, filtrar antenas:

```dart
final userLocation = await _getCurrentLocation();
final userRegion = _determineRegion(userLocation); // ej: 'santiago-recoleta'
final antennasForRegion = await SubtelDataService.parseAntennas(userRegion);
```

## Formato esperado del CSV

Columnas requeridas:
- `Empresa` (Operador: MOVISTAR, ENTEL, CLARO, WOM)
- `Latitud` (Formato DMS: "33°25""45")
- `Longitud` (Formato DMS: "70°38""50")

Columnas opcionales:
- Dirección, Comuna, etc. (para contexto futuro)

Conversión de coordenadas:
- DMS (Grados°Minutos"Segundos) → Decimal (usado por latlong2)
- Ejemplo: "33°25""45" → 33.4292

## Cálculo de Distancias

**Algoritmo:** Haversine (distancia geodésica)
- Implementado por `latlong2` package
- Precisión: ±0.5% a nivel local
- Costo: O(1) por antena

## Mejoras Futuras

1. **Caché local**
   - Almacenar CSV parseado en SQLite/Hive
   - Evitar re-parseo en cada startup
   - Verificar versión de datos

2. **API remoto**
   - Reemplazar CSV por GraphQL/REST
   - Cargar dinámicamente según ubicación
   - Sincronizar en background

3. **Compresión**
   - Usar GeoJSON + gzip en lugar de CSV
   - Reducir tamaño de assets (~50%)

4. **Geocerca (Geofencing)**
   - Notificar cuando usuario entra en rango de antena mejor
   - Usar `flutter_local_notifications`

5. **Análisis de Cobertura**
   - Heatmap en MapScreen
   - Poligonos Voronoi de cobertura
   - WebSocket para actualizaciones real-time

## Testing

```dart
// Test parser
final antennas = SubtelDataService.parseAntennas();
expect(antennas, isNotEmpty);
expect(antennas.first.operator, isNotNull);

// Test cálculo de distancia
final snapshot = await csvRepo.getSnapshot(
  userLocation: LatLng(-33.4489, -70.6693)
);
expect(snapshot.nearestAntenna.distanceKm, greaterThan(0));
```

## Performance

| Métrica | Valor |
|---------|-------|
| Parse CSV | ~50ms (358 filas) |
| Cálculo distancias | ~10ms (358 antenas) |
| Total getSnapshot() | ~200ms (incl. GPS) |

**Optimización:** Cachear resultado de parse en memoria estática.
