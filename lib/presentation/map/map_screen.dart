import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

// Centro de respaldo si el GPS falla
const _fallbackCenter = LatLng(-33.4489, -70.6693);
const _initialZoom = 14.0;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  LatLng? _userLocation;
  bool _loadingLocation = true;
  String? _locationError;

  // Capas SUBTEL — se poblarán al cargar los CSV
  final List<Marker> _antennaMarkers = [];
  final List<Polyline> _coverageLines = [];

  @override
  void initState() {
    super.initState();
    _locateUser();
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
      _mapController.move(location, _initialZoom);
    } catch (_) {
      if (mounted) setState(() => _locationError = 'denied');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cobertura'),
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
            options: MapOptions(
              initialCenter: _userLocation ?? _fallbackCenter,
              initialZoom: _initialZoom,
              minZoom: 5,
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
              // Capa cobertura SUBTEL (se llenará con GeoJSON/CSV)
              PolylineLayer(polylines: _coverageLines),
            ],
          ),
          _buildLegend(colors),
        ],
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
            Text(
              'CAPAS ACTIVAS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: colors.muted,
              ),
            ),
            const SizedBox(height: 6),
            _legendItem(colors.primary, 'Tu ubicación', colors),
            _legendItem(colors.signalGood, 'Antenas SUBTEL', colors),
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

  void _centerOnUser() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, _initialZoom);
    } else {
      _locateUser();
    }
  }

  void _showLayerPanel() {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => const _LayerPanel(),
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
          const _LayerTile(label: 'Antenas SUBTEL', subtitle: 'Próximamente — cargar CSV'),
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
