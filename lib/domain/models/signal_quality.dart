enum SignalQuality {
  none,
  poor,
  fair,
  good,
  excellent,
}

extension SignalQualityLabel on SignalQuality {
  String get label {
    switch (this) {
      case SignalQuality.none:
        return 'Sin señal';
      case SignalQuality.poor:
        return 'Señal débil';
      case SignalQuality.fair:
        return 'Señal media';
      case SignalQuality.good:
        return 'Señal buena';
      case SignalQuality.excellent:
        return 'Señal excelente';
    }
  }
}
