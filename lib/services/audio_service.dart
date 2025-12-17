import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();

  AudioService() {
    _tts.setLanguage('es-ES');
    _tts.setSpeechRate(0.4); // más lento = más accesible
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }
}
