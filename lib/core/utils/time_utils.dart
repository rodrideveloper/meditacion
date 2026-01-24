/// Utilidades para formateo de tiempo
class TimeUtils {
  TimeUtils._();

  /// Formatea una duración a string legible (MM:SS)
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Formatea una duración a string largo (X minutos Y segundos)
  static String formatDurationLong(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);

    if (minutes == 0) {
      return '$seconds segundos';
    } else if (seconds == 0) {
      return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'} $seconds ${seconds == 1 ? 'segundo' : 'segundos'}';
    }
  }

  /// Convierte minutos a Duration
  static Duration minutesToDuration(int minutes) {
    return Duration(minutes: minutes);
  }

  /// Convierte Duration a minutos
  static int durationToMinutes(Duration duration) {
    return duration.inMinutes;
  }
}
