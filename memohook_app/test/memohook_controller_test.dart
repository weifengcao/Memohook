import 'package:flutter_test/flutter_test.dart';

import 'package:memohook_app/core/memohook_controller.dart';
import 'package:memohook_app/core/services/assistant_service.dart';
import 'package:memohook_app/core/services/memory_log_repository.dart';
import 'package:memohook_app/core/services/speech_capture_service.dart';
import 'package:memohook_app/features/logs/memory_log.dart';

class _FakeSpeechCaptureService extends SpeechCaptureService {
  _FakeSpeechCaptureService(this.transcript);

  final String transcript;

  @override
  Future<void> initialize() async {}

  @override
  Future<SpeechCaptureResult> captureSingleUtterance() async {
    return SpeechCaptureResult(transcript: transcript);
  }
}

class _FakeAssistantService extends AssistantService {
  _FakeAssistantService({required this.decision, this.match});

  final AssistantDecision decision;
  final MemoryLog? match;

  @override
  Future<AssistantDecision> classifyTranscript(String transcript) async {
    return decision;
  }

  @override
  Future<MemoryLog?> findRelevantLog(
    String question,
    List<MemoryLog> logs,
  ) async {
    if (match != null) {
      return match;
    }
    if (logs.isEmpty) {
      return null;
    }
    return logs.first;
  }

  @override
  Future<String> summarizeLogs(List<MemoryLog> logs) async {
    return 'summary';
  }
}

class _FakeLogRepository extends MemoryLogRepository {
  _FakeLogRepository(List<MemoryLog> seed) : _logs = List.of(seed);

  final List<MemoryLog> _logs;

  @override
  Future<void> addLog(MemoryLog log) async {
    _logs.insert(0, log);
  }

  @override
  Future<List<MemoryLog>> loadInitialLogs() async => List.unmodifiable(_logs);
}

void main() {
  group('MemohookController', () {
    test(
      'toggleListening captures log entries when assistant chooses log',
      () async {
        final repo = _FakeLogRepository([]);
        final speech = _FakeSpeechCaptureService(
          'Log fed the cat and cleaned bowls.',
        );
        final assistant = _FakeAssistantService(
          decision: AssistantDecision.log(
            transcript: 'Fed the cat and cleaned bowls.',
          ),
        );

        final controller = MemohookController(
          logRepository: repo,
          speechService: speech,
          assistantService: assistant,
        );
        await controller.ready;

        expect(controller.logs, isEmpty);

        await controller.toggleListening();

        expect(controller.logs, hasLength(1));
        expect(controller.logs.first.content, contains('Fed the cat'));
        expect(controller.isListening, isFalse);
      },
    );

    test(
      'askQuestion updates query result when assistant finds a match',
      () async {
        final seedLog = MemoryLog.create(
          content: 'Locked the front door at 9pm.',
          createdAt: DateTime(2024, 10, 1, 21, 0),
        );
        final repo = _FakeLogRepository([seedLog]);
        final speech = _FakeSpeechCaptureService('Did I lock the door?');
        final assistant = _FakeAssistantService(
          decision: AssistantDecision.query(question: 'Did I lock the door?'),
          match: seedLog,
        );

        final controller = MemohookController(
          logRepository: repo,
          speechService: speech,
          assistantService: assistant,
        );
        await controller.ready;

        expect(controller.queryResult, isNull);

        await controller.askQuestion('Did I lock the door?');

        expect(controller.isQuerying, isFalse);
        expect(controller.queryResult, isNotNull);
        expect(
          controller.queryResult!.content,
          contains('Locked the front door'),
        );
      },
    );
  });
}
