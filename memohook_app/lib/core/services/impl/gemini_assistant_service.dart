import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../features/logs/memory_log.dart';
import '../assistant_service.dart';

class GeminiAssistantService extends AssistantService {
  GeminiAssistantService({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
  }) : _model = GenerativeModel(model: modelName, apiKey: apiKey);

  final String apiKey;
  final String modelName;
  final GenerativeModel _model;

  @override
  Future<AssistantDecision> classifyTranscript(String transcript) async {
    final prompt =
        '''Classify user input as LOG or QUERY. Respond ONLY with JSON: {
  "intent": "LOG" | "QUERY",
  "keywords": ["keyword1", "keyword2"]
}
Input: "$transcript"''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '{}';
    final payload = _safeJson(text);

    final intent = (payload['intent'] as String?)?.toUpperCase() == 'QUERY'
        ? AssistantIntent.query
        : AssistantIntent.log;
    final keywords = (payload['keywords'] as List?)?.cast<String>() ?? const [];

    if (intent == AssistantIntent.query) {
      return AssistantDecision.query(question: transcript, keywords: keywords);
    }
    return AssistantDecision.log(transcript: transcript);
  }

  @override
  Future<MemoryLog?> findRelevantLog(
    String question,
    List<MemoryLog> logs,
  ) async {
    if (logs.isEmpty) {
      return null;
    }
    // TODO: Use Gemini for semantic retrieval with Firestore search results.
    for (final log in logs) {
      if (log.content.toLowerCase().contains(question.toLowerCase())) {
        return log;
      }
    }
    return logs.first;
  }

  @override
  Future<String> summarizeLogs(List<MemoryLog> logs) async {
    if (logs.isEmpty) {
      return 'No memories logged today.';
    }
    final logBullets = logs.map((log) => '- ${log.content}').join('\n');
    final prompt =
        'Summarize these logs into one friendly paragraph:\n$logBullets';
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Summary unavailable.';
  }

  Map<String, dynamic> _safeJson(String text) {
    try {
      return json.decode(text) as Map<String, dynamic>;
    } catch (_) {
      return const {};
    }
  }
}
