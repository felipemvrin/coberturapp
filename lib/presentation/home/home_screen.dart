import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/coverage_service.dart';
import '../../domain/models/signal_quality.dart';
import '../map/map_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/nearest_antenna_card.dart';
import '../widgets/nearby_antenna_card.dart';
import '../widgets/signal_status_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final _coverageService = CoverageService();
  bool _isFindingBestSignal = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      body: FutureBuilder(
        future: _coverageService.repository.getSnapshot(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Error al cargar datos de cobertura',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          final coverageSnapshot = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'assets/images/logo.svg',
                              height: 28,
                              colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Que no se escape la señal.',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const MapScreen()),
                        ),
                        icon: const Icon(Icons.location_on_outlined),
                        iconSize: 18,
                        style: IconButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.surface,
                          minimumSize: const Size(38, 38),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SignalStatusCard(
                    connectionStatus: coverageSnapshot.connectionStatus,
                    operator: coverageSnapshot.operator,
                    technology: coverageSnapshot.technology,
                    signalQuality: coverageSnapshot.signalQuality,
                    subtitle: coverageSnapshot.signalQuality.label,
                  ),
                  const SizedBox(height: 18),
                  NearestAntennaCard(antenna: coverageSnapshot.nearestAntenna),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _handleFindBestSignal,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: _isFindingBestSignal
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _isFindingBestSignal ? 'BUSCANDO...' : 'BUSCAR MEJOR SEÑAL',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'ANTENAS CERCANAS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...coverageSnapshot.nearbyAntennas.map((antenna) => NearbyAntennaCard(antenna: antenna)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const MapScreen()),
                    ),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('VER MAPA'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleFindBestSignal() async {
    setState(() => _isFindingBestSignal = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isFindingBestSignal = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MapScreen()),
    );
  }
}
