import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_constants.dart';
import '../../data/coverage_service.dart';
import '../../data/subtel_data_service.dart';
import '../../domain/models/mobile_technology.dart';
import '../../domain/models/nearby_antenna.dart';
import '../../domain/models/signal_quality.dart';
import '../../domain/utils/location_utils.dart';
import '../theme/app_colors.dart';

const _fallbackCenter = LatLng(
  AppConstants.defaultLatitude,
  AppConstants.defaultLongitude,
);
const _initialZoom = AppConstants.mapInitialZoom;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  late final _coverageService = CoverageService();
  
  LatLng? _userLocation;
  bool _loadingLocation = true;
  String? _locationError;
  
  List<NearbyAntenna> _nearbyAntennas = [];
  bool _loadingAntennas = true;

  // Capas SUBTEL — se poblarán al cargar los CSV
  final List<Marker> _antennaMarkers = [];

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Primero intentar obtener ubicación, luego cargar antenas
    await _locateUser();
    // _locateUser ya llama a _loadAntennas()
  }

  Future<void> _loadAntennas() async {
    setState(() => _loadingAntennas = true);
    try {
      // Cargar TODAS las antenas de Recoleta (no solo las 5 más cercanas)
      final allAntennas = await SubtelDataService.loadAllRegions();
      if (!mounted) return;
      
      // Calcular distancia desde ubicación actual
      final location = _userLocation ?? _fallbackCenter;
      final Distance distanceCalc = Distance();
      
      final antennasWithDistance = allAntennas.where((antenna) {
        return antenna.latitude != null && antenna.longitude != null;
      }).map((antenna) {
        final antennaLocation = LatLng(antenna.latitude!, antenna.longitude!);
        final distKm = distanceCalc.as(LengthUnit.Kilometer, location, antennaLocation);
        final bearing = LocationUtils.calculateBearing(location, antennaLocation);
        
        return antenna.copyWith(
          distanceKm: distKm,
          direction: LocationUtils.bearingToDirection(bearing),
          signalQuality: LocationUtils.getSignalQualityByDistance(distKm),
        );
      }).toList();
      
      setState(() {
        _nearbyAntennas = antennasWithDistance;
        _antennaMarkers.clear();
        _antennaMarkers.addAll(_buildAntennaMarkers(antennasWithDistance));
      });
      // Ajustar el mapa para mostrar todas las antenas después de cargar
      _fitMapToShowAllAntennas();
    } catch (e) {
      // Log omitido
    } finally {
      if (mounted) setState(() => _loadingAntennas = false);
    }
  }

  void _fitMapToShowAllAntennas() {
    if (_antennaMarkers.isEmpty) return;
    
    // Obtener los límites de todas las antenas
    double minLat = 90, maxLat = -90, minLon = 180, maxLon = -180;
    
    for (final marker in _antennaMarkers) {
      minLat = math.min(minLat, marker.point.latitude);
      maxLat = math.max(maxLat, marker.point.latitude);
      minLon = math.min(minLon, marker.point.longitude);
      maxLon = math.max(maxLon, marker.point.longitude);
    }
    
    // Incluir ubicación del usuario si existe
    if (_userLocation != null) {
      minLat = math.min(minLat, _userLocation!.latitude);
      maxLat = math.max(maxLat, _userLocation!.latitude);
      minLon = math.min(minLon, _userLocation!.longitude);
      maxLon = math.max(maxLon, _userLocation!.longitude);
    }
    
    // Crear bounds con padding
    final bounds = LatLngBounds(
      LatLng(maxLat, minLon),
      LatLng(minLat, maxLon),
    );
    
    // Ajustar el mapa con animación
    _mapController.fitBounds(
      bounds,
      options: const FitBoundsOptions(padding: EdgeInsets.all(100)),
    );
  }

  List<Marker> _buildAntennaMarkers(List<NearbyAntenna> antennas) {
    return antennas.map((antenna) {
      final lat = antenna.latitude;
      final lon = antenna.longitude;
      if (lat == null || lon == null) return null;

      final color = antenna.operator.colorHex.hexToColor();
      
      return Marker(
        point: LatLng(lat, lon),
        width: 48,
        height: 48,
        child: GestureDetector(
          onTap: () => _showAntennaInfo(antenna),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
            ),
            child: Icon(Icons.broadcast_on_home, color: color, size: 24),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }

  void _showAntennaInfo(NearbyAntenna antenna) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _AntennaInfoPanel(antenna: antenna),
    );
  }

  Future<void> _locateUser() async {
    setState(() => _loadingLocation = true);
    setState(() => _locationError = null);
    try {
      // En web el navegador maneja el permiso al llamar getCurrentPosition
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      final location = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _userLocation = location);
    } catch (_) {
      if (mounted) setState(() => _locationError = 'denied');
      // Usar ubicación por defecto si hay error
      if (mounted) setState(() => _userLocation = _fallbackCenter);
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
      // Cargar antenas después de obtener ubicación (real o fallback)
      _loadAntennas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CoberturApp'),
        centerTitle: false,
        actions: [
          if (_loadingLocation)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'Mi ubicación',
              onPressed: _locateUser,
            ),
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Capas',
            onPressed: _showLayerPanel,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_locationError != null) _buildLocationError(colors),
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _fallbackCenter,
              initialZoom: _initialZoom,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              // Capa base: OpenStreetMap
              // Tiles CartoDB Voyager: diseño limpio y neutral
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.coberturapp.app',
              ),
              // Capa antenas SUBTEL (se llenará con CSV)
              MarkerLayer(markers: [
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.primary, width: 2),
                      ),
                      child: Icon(Icons.person_pin_circle, color: colors.primary, size: 24),
                    ),
                  ),
                ..._antennaMarkers,
              ]),
              // Nota: Capa de cobertura SUBTEL (GeoJSON/polígonos) para próximas versiones
            ],
          ),
          _buildLegend(colors),
          _buildCompass(colors),
          _buildZoomControls(colors),
        ],
      ),
    );
  }

  Widget _buildCompass(AppColors colors) {
    return Positioned(
      top: _locationError != null ? 72 : 16,
      right: 16,
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          final heading = snapshot.data?.heading ?? 0.0;
          return Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Transform.rotate(
              // Rota en sentido inverso para que la aguja apunte al norte
              angle: -(heading * math.pi / 180),
              child: Icon(Icons.navigation, color: colors.primary, size: 28),
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoomControls(AppColors colors) {
    return Positioned(
      bottom: 24,
      right: 16,
      child: Column(
        children: [
          _zoomButton(Icons.add, colors, () {
            final current = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, (current + 1).clamp(3, 18));
          }),
          const SizedBox(height: 8),
          _zoomButton(Icons.remove, colors, () {
            final current = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, (current - 1).clamp(3, 18));
          }),
        ],
      ),
    );
  }

  Widget _zoomButton(IconData icon, AppColors colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Icon(icon, color: colors.primary, size: 22),
      ),
    );
  }

  Widget _buildLocationError(AppColors colors) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Material(
        color: const Color(0xFFFFF3CD),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.location_off, size: 18, color: Color(0xFF856404)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Activa la ubicación en Chrome: ícono 🔒 en la barra de dirección → Ubicación → Permitir',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF856404)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF856404)),
                onPressed: _locateUser,
                tooltip: 'Reintentar',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(AppColors colors) {
    return Positioned(
      bottom: 24,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'CAPAS ACTIVAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(width: 8),
                if (_loadingAntennas)
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: colors.primary)),
              ],
            ),
            const SizedBox(height: 6),
            _legendItem(colors.primary, 'Tu ubicación', colors),
            if (_nearbyAntennas.isNotEmpty)
              _legendItem(colors.signalGood, '${_nearbyAntennas.length} antenas SUBTEL', colors)
            else
              _legendItem(colors.muted, 'Antenas SUBTEL', colors),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color dot, String label, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: colors.text)),
        ],
      ),
    );
  }

  void _showLayerPanel() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const _LayerPanel(),
    );
  }
}

extension on String {
  Color hexToColor() {
    String hexColor = replaceFirst('#', '');
    return Color(int.parse(hexColor, radix: 16) + 0xFF000000);
  }
}

class _AntennaInfoPanel extends StatelessWidget {
  const _AntennaInfoPanel({required this.antenna});

  final NearbyAntenna antenna;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final color = antenna.operator.colorHex.hexToColor();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                antenna.operator.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow('Distancia', '${antenna.distanceKm.toStringAsFixed(2)} km', colors),
          const SizedBox(height: 8),
          _infoRow('Dirección', antenna.direction, colors),
          const SizedBox(height: 8),
          _infoRow('Tecnología', antenna.technology.label, colors),
          const SizedBox(height: 8),
          _infoRow('Señal', antenna.signalQuality.label, colors),
          const SizedBox(height: 8),
          _infoRow('Ubicación', '${antenna.latitude?.toStringAsFixed(4)}, ${antenna.longitude?.toStringAsFixed(4)}', colors),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colors.muted,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LayerPanel extends StatelessWidget {
  const _LayerPanel();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Capas del mapa',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const _LayerTile(label: 'Antenas SUBTEL', subtitle: 'Cargadas en tiempo real desde CSV'),
          const _LayerTile(label: 'Cobertura 4G', subtitle: 'Próximamente — GeoJSON SUBTEL'),
          const _LayerTile(label: 'Cobertura 5G', subtitle: 'Próximamente — GeoJSON SUBTEL'),
          const _LayerTile(label: 'Mi ubicación GPS', subtitle: 'Activa el permiso en el navegador'),
        ],
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({required this.label, required this.subtitle});

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.layers_outlined),
      title: Text(label),
      subtitle: Text(subtitle),
      trailing: Switch(value: false, onChanged: null),
    );
  }
}
