import 'dart:math';

import '../../features/logs/memory_log.dart';

enum AssistantIntent { log, query }

typedef KeywordList = List<String>;

typedef QueryText = String;

class AssistantDecision {
  AssistantDecision.log({required this.transcript})
    : intent = AssistantIntent.log,
      keywords = const [],
      question = null;

  AssistantDecision.query({required this.question, this.keywords = const []})
    : intent = AssistantIntent.query,
      transcript = null;

  final AssistantIntent intent;
  final String? transcript;
  final QueryText? question;
  final KeywordList keywords;
}

class AssistantService {
  Future<AssistantDecision> classifyTranscript(String transcript) async {
    throw UnimplementedError('AssistantService.classifyTranscript');
  }

  Future<MemoryLog?> findRelevantLog(
    QueryText question,
    List<MemoryLog> logs,
  ) async {
    throw UnimplementedError('AssistantService.findRelevantLog');
  }

  Future<String> summarizeLogs(List<MemoryLog> logs) async {
    throw UnimplementedError('AssistantService.summarizeLogs');
  }
}

class MockAssistantService extends AssistantService {
  MockAssistantService({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _logSamples = [
    'Fed the dog and refilled his water bowl.',
    'Took morning blood pressure medication.',
    'Watered the house plants.',
    'Called Sarah and chatted about the weekend.',
    'Checked the front door and it is locked.',
  ];

  @override
  Future<AssistantDecision> classifyTranscript(String transcript) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final normalized = transcript.toLowerCase();
    if (normalized.contains('?') ||
        normalized.startsWith('did') ||
        normalized.startsWith('what')) {
      return AssistantDecision.query(question: transcript);
    }
    if (normalized.startsWith('log')) {
      return AssistantDecision.log(
        transcript: transcript.replaceFirst(RegExp('^log '), ''),
      );
    }
    if (normalized.startsWith('add')) {
      return AssistantDecision.log(
        transcript: transcript.replaceFirst(RegExp('^add '), ''),
      );
    }
    // Otherwise randomly decide to log or query for demo purposes.
    if (_random.nextBool()) {
      return AssistantDecision.log(transcript: transcript);
    }
    return AssistantDecision.query(
      question: 'What happened about "$transcript"?',
    );
  }

  @override
  Future<MemoryLog?> findRelevantLog(
    QueryText question,
    List<MemoryLog> logs,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final normalized = question.toLowerCase();
    for (final log in logs) {
      if (log.content.toLowerCase().contains(normalized)) {
        return log;
      }
    }
    return logs.isEmpty ? null : logs.first;
  }

  @override
  Future<String> summarizeLogs(List<MemoryLog> logs) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (logs.isEmpty) {
      return 'No memories logged today. Tap the microphone to add your first note.';
    }
    final latest = logs.take(3).toList();
    final bulletPoints = latest.map((log) => '• ${log.content}').join('\n');
    return 'Here is what I remember today:\n$bulletPoints\nYou have ${logs.length} memories captured.';
  }

  MemoryLog randomLog() {
    return MemoryLog.create(
      content: _logSamples[_random.nextInt(_logSamples.length)],
      createdAt: DateTime.now().subtract(
        Duration(minutes: _random.nextInt(120)),
      ),
    );
  }
}
