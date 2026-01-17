import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  AudioService();

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('es-ES');
      // speech rate a 0.45 para buena comprensión sin distorsión
      await _tts.setSpeechRate(0.45);
      // bajar un poco el volumen para evitar saturación inicial
      await _tts.setVolume(0.85);
      await _tts.setPitch(1.0);
      // esperar a que se completen los eventos de speak
      await _tts.awaitSpeakCompletion(true);
      _initialized = true;
    } catch (e) {
      _initialized = false;
    }
  }

  Future<void> speak(String text) async {
    try {
      if (!_initialized) await init();
      await _tts.speak(text);
    } catch (e) {
      // ignore errors silently for now
    }
  }

  Future<void> dispose() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
