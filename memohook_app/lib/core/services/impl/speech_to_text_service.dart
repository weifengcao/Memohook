import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../speech_capture_service.dart';

class SpeechToTextService extends SpeechCaptureService {
  SpeechToTextService() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;

  @override
  Future<void> initialize() async {
    final available = await _speech.initialize(debugLogging: false);
    if (!available) {
      throw Exception('Speech recognition unavailable on this device.');
    }
  }

  @override
  Future<SpeechCaptureResult> captureSingleUtterance() async {
    if (!_speech.isAvailable) {
      await initialize();
    }
    final completer = Completer<SpeechCaptureResult>();

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        if (result.finalResult) {
          final confidence = result.alternates.isNotEmpty
              ? result.alternates.first.confidence
              : 0.0;
          completer.complete(
            SpeechCaptureResult(
              transcript: result.recognizedWords,
              confidence: confidence,
            ),
          );
          _speech.stop();
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
      ),
    );

    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        _speech.stop();
        throw TimeoutException('Speech capture timed out.');
      },
    );
  }
}
