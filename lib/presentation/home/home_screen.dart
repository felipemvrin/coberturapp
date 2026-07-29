import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/mock_coverage_repository.dart';
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
  final _repository = const MockCoverageRepository();
  bool _isFindingBestSignal = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final snapshot = _repository.getSnapshot();

    return Scaffold(
      body: SafeArea(
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
                          'Encuentra señal. Sigue conectado.',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.location_on_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SignalStatusCard(
                connectionStatus: snapshot.connectionStatus,
                operator: snapshot.operator,
                technology: snapshot.technology,
                signalQuality: snapshot.signalQuality,
                subtitle: snapshot.signalQuality.label,
              ),
              const SizedBox(height: 18),
              NearestAntennaCard(antenna: snapshot.nearestAntenna),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _handleFindBestSignal,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              const SizedBox(height: 24),
              Text(
                'ANTENAS CERCANAS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...snapshot.nearbyAntennas.map((antenna) => NearbyAntennaCard(antenna: antenna)),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map_outlined),
                label: const Text('VER MAPA'),
              ),
            ],
          ),
        ),
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
