import 'dart:async';
import 'dart:math';

class SpeechCaptureResult {
  SpeechCaptureResult({required this.transcript, this.confidence = 1.0});

  final String transcript;
  final double confidence;
}

abstract class SpeechCaptureService {
  Future<void> initialize();

  Future<SpeechCaptureResult> captureSingleUtterance();
}

class MockSpeechCaptureService extends SpeechCaptureService {
  MockSpeechCaptureService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _utterances = [
    'Log that I took my morning pills.',
    'Call Sarah tomorrow afternoon.',
    'Did I lock the front door?',
    'Watered the garden at 5pm.',
    'What did I cook for dinner last night?',
  ];

  @override
  Future<void> initialize() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<SpeechCaptureResult> captureSingleUtterance() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final transcript = _utterances[_random.nextInt(_utterances.length)];
    return SpeechCaptureResult(
      transcript: transcript,
      confidence: 0.85 + _random.nextDouble() * 0.15,
    );
  }
}
