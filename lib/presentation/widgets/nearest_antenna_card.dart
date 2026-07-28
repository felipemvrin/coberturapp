import 'package:flutter/material.dart';
import '../../domain/models/mobile_technology.dart';
import '../../domain/models/nearby_antenna.dart';
import '../theme/app_colors.dart';

class NearestAntennaCard extends StatelessWidget {
  const NearestAntennaCard({super.key, required this.antenna});

  final NearbyAntenna antenna;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANTENA MÁS CERCANA',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.1,
              color: colors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${antenna.distanceKm.toStringAsFixed(1)} km',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '↗ ${antenna.direction}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Chip(
                label: Text(antenna.operator.name),
                avatar: Icon(Icons.cell_tower, size: 16, color: colors.primary),
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text(antenna.technology.label),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
