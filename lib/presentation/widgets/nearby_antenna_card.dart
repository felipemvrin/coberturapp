import 'package:flutter/material.dart';
import '../../domain/models/mobile_technology.dart';
import '../../domain/models/nearby_antenna.dart';
import '../../domain/models/signal_quality.dart';
import '../theme/app_colors.dart';

class NearbyAntennaCard extends StatelessWidget {
  const NearbyAntennaCard({super.key, required this.antenna});

  final NearbyAntenna antenna;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _colorForSignal(antenna, colors),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  antenna.operator.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${antenna.distanceKm.toStringAsFixed(1)} km • ${antenna.technology.label}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          Text(
            antenna.direction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }

  Color _colorForSignal(NearbyAntenna antenna, AppColors colors) {
    switch (antenna.signalQuality) {
      case SignalQuality.good:
        return colors.signalGood;
      case SignalQuality.fair:
        return colors.signalMedium;
      case SignalQuality.poor:
      case SignalQuality.none:
        return colors.signalPoor;
      case SignalQuality.excellent:
        return colors.accent;
    }
  }
}
