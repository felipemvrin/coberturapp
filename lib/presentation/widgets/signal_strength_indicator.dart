import 'package:flutter/material.dart';
import '../../domain/models/signal_quality.dart';
import '../theme/app_colors.dart';

class SignalStrengthIndicator extends StatelessWidget {
  const SignalStrengthIndicator({super.key, required this.quality});

  final SignalQuality quality;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bars = _barsForQuality(quality);
    final color = _colorForQuality(quality, colors);

    return Row(
      children: [
        for (final filled in bars)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 8,
              height: 8 + (filled ? 8 : 0) + (filled ? 6 : 0),
              decoration: BoxDecoration(
                color: filled ? color : colors.muted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }

  List<bool> _barsForQuality(SignalQuality quality) {
    switch (quality) {
      case SignalQuality.none:
        return [false, false, false, false];
      case SignalQuality.poor:
        return [true, false, false, false];
      case SignalQuality.fair:
        return [true, true, false, false];
      case SignalQuality.good:
        return [true, true, true, false];
      case SignalQuality.excellent:
        return [true, true, true, true];
    }
  }

  Color _colorForQuality(SignalQuality quality, AppColors colors) {
    switch (quality) {
      case SignalQuality.none:
        return colors.muted;
      case SignalQuality.poor:
        return colors.signalPoor;
      case SignalQuality.fair:
        return colors.signalMedium;
      case SignalQuality.good:
        return colors.signalGood;
      case SignalQuality.excellent:
        return colors.accent;
    }
  }
}
