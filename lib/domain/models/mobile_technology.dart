enum MobileTechnology {
  unknown,
  threeG,
  fourG,
  fiveG,
}

extension MobileTechnologyLabel on MobileTechnology {
  String get label {
    switch (this) {
      case MobileTechnology.threeG:
        return '3G';
      case MobileTechnology.fourG:
        return '4G LTE';
      case MobileTechnology.fiveG:
        return '5G';
      case MobileTechnology.unknown:
        return 'Sin dato';
    }
  }
}
