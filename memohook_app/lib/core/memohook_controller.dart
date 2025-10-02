import 'package:flutter/foundation.dart';

import '../features/logs/memory_log.dart';
import 'services/assistant_service.dart';
import 'services/memory_log_repository.dart';
import 'services/speech_capture_service.dart';

class MemohookController extends ChangeNotifier {
  MemohookController({
    required MemoryLogRepository logRepository,
    required SpeechCaptureService speechService,
    required AssistantService assistantService,
  }) : _logRepository = logRepository,
       _speechService = speechService,
       _assistantService = assistantService {
    ready = _bootstrap();
  }

  final MemoryLogRepository _logRepository;
  final SpeechCaptureService _speechService;
  final AssistantService _assistantService;

  bool _isInitializing = true;
  bool _isListening = false;
  bool _isQuerying = false;
  bool _isSummarizing = false;
  List<MemoryLog> _logs = const [];
  MemoryLog? _queryResult;
  String? _dailySummary;
  late final Future<void> ready;

  bool get isInitializing => _isInitializing;
  bool get isListening => _isListening;
  bool get isQuerying => _isQuerying;
  bool get isSummarizing => _isSummarizing;
  List<MemoryLog> get logs => List.unmodifiable(_logs);
  MemoryLog? get queryResult => _queryResult;
  String? get dailySummary => _dailySummary;

  Future<void> _bootstrap() async {
    await _speechService.initialize();
    _logs = await _logRepository.loadInitialLogs();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (_isListening || _isInitializing) {
      return;
    }
    _isListening = true;
    notifyListeners();

    final capture = await _speechService.captureSingleUtterance();
    _isListening = false;
    notifyListeners();

    await _handleTranscript(capture.transcript);
  }

  Future<void> askQuestion(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || _isInitializing) {
      return;
    }
    _isQuerying = true;
    notifyListeners();

    final decision = AssistantDecision.query(question: trimmed);
    await _executeAssistantDecision(decision);

    _isQuerying = false;
    notifyListeners();
  }

  Future<void> generateDailySummary() async {
    if (_isSummarizing || _isInitializing) {
      return;
    }
    _isSummarizing = true;
    notifyListeners();

    final summary = await _assistantService.summarizeLogs(_logs);
    _dailySummary = summary;

    _isSummarizing = false;
    notifyListeners();
  }

  void dismissQueryResult() {
    _queryResult = null;
    notifyListeners();
  }

  void dismissSummary() {
    _dailySummary = null;
    notifyListeners();
  }

  Future<void> addManualLog(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty || _isInitializing) {
      return;
    }
    await _appendLog(trimmed);
  }

  Future<void> _handleTranscript(String transcript) async {
    final decision = await _assistantService.classifyTranscript(transcript);
    await _executeAssistantDecision(decision);
  }

  Future<void> _executeAssistantDecision(AssistantDecision decision) async {
    switch (decision.intent) {
      case AssistantIntent.log:
        final content = decision.transcript ?? 'Memory captured.';
        await _appendLog(content);
        break;
      case AssistantIntent.query:
        final question = decision.question ?? '';
        final match = await _assistantService.findRelevantLog(question, _logs);
        if (match != null) {
          _queryResult = match;
        } else {
          _queryResult = MemoryLog.create(
            content:
                'I could not find a matching memory yet. Try logging it first.',
          );
        }
        break;
    }
    notifyListeners();
  }

  Future<void> _appendLog(String content) async {
    final log = MemoryLog.create(content: content);
    await _logRepository.addLog(log);
    _logs = [log, ..._logs];
    notifyListeners();
  }
}
