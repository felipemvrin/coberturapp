import 'package:flutter/material.dart';
import '../../domain/models/connection_status.dart';
import '../../domain/models/mobile_operator.dart';
import '../../domain/models/mobile_technology.dart';
import '../../domain/models/signal_quality.dart';
import '../theme/app_colors.dart';
import 'signal_strength_indicator.dart';

class SignalStatusCard extends StatelessWidget {
  const SignalStatusCard({
    super.key,
    required this.connectionStatus,
    required this.operator,
    required this.technology,
    required this.signalQuality,
    required this.subtitle,
  });

  final ConnectionStatus connectionStatus;
  final MobileOperator operator;
  final MobileTechnology technology;
  final SignalQuality signalQuality;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final isConnected = connectionStatus == ConnectionStatus.connected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isConnected ? colors.signalGood : colors.signalPoor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isConnected ? 'CONECTADO' : 'SIN SEÑAL',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.2,
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            isConnected ? technology.label : 'No hay conexión móvil',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: colors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isConnected ? operator.name.toUpperCase() : 'Última señal: 3,2 km atrás',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SignalStrengthIndicator(quality: signalQuality),
              const SizedBox(width: 12),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
