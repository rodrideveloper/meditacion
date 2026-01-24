/// Constantes para los sonidos de meditación
class SoundConstants {
  SoundConstants._();

  /// Sonidos disponibles
  static const List<MeditationSound> availableSounds = [
    MeditationSound(
      id: 'angelical',
      name: 'Angelical',
      assetPath: 'assets/sounds/angelical.mp3',
      androidRawName: 'angelical',
    ),
  ];

  /// Sonido por defecto
  static const String defaultSoundId = 'angelical';
}

/// Modelo para representar un sonido de meditación
class MeditationSound {
  final String id;
  final String name;
  final String assetPath;
  final String androidRawName;

  const MeditationSound({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.androidRawName,
  });

  /// Obtener sonido por ID
  static MeditationSound? getById(String id) {
    try {
      return SoundConstants.availableSounds.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sonido por defecto
  static MeditationSound get defaultSound =>
      getById(SoundConstants.defaultSoundId) ??
      SoundConstants.availableSounds.first;
}
