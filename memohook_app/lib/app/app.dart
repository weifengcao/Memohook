import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/memohook_controller.dart';
import '../core/services/assistant_service.dart';
import '../core/services/impl/firestore_memory_log_repository.dart';
import '../core/services/impl/gemini_assistant_service.dart';
import '../core/services/impl/speech_to_text_service.dart';
import '../core/services/memory_log_repository.dart';
import '../core/services/speech_capture_service.dart';
import '../features/logs/memory_log.dart';
import 'app_shell.dart';

class MemohookApp extends StatelessWidget {
  const MemohookApp({
    super.key,
    required this.useFirestore,
    required this.useGemini,
    required this.useSpeechToText,
    this.geminiApiKey,
  });

  final bool useFirestore;
  final bool useGemini;
  final bool useSpeechToText;
  final String? geminiApiKey;

  @override
  Widget build(BuildContext context) {
    final seedLogs = useFirestore
        ? const <MemoryLog>[]
        : [
            MemoryLog.create(
              content: 'Fed the dog and refilled his water bowl.',
              createdAt: DateTime.now().subtract(
                const Duration(hours: 2, minutes: 15),
              ),
              keywords: const ['dog', 'fed', 'water'],
            ),
            MemoryLog.create(
              content: 'Took morning blood pressure medication.',
              createdAt: DateTime.now().subtract(
                const Duration(hours: 4, minutes: 40),
              ),
              keywords: const ['medication', 'blood pressure'],
            ),
            MemoryLog.create(
              content: 'Closed the garage door before bed.',
              createdAt: DateTime.now().subtract(
                const Duration(hours: 10, minutes: 5),
              ),
              keywords: const ['garage', 'door'],
            ),
          ];

    return MultiProvider(
      providers: [
        Provider<AssistantService>(
          create: (_) {
            if (useGemini && (geminiApiKey?.isNotEmpty ?? false)) {
              return GeminiAssistantService(apiKey: geminiApiKey!);
            }
            return MockAssistantService();
          },
        ),
        Provider<SpeechCaptureService>(
          create: (_) => useSpeechToText
              ? SpeechToTextService()
              : MockSpeechCaptureService(),
        ),
        Provider<MemoryLogRepository>(
          create: (_) {
            if (useFirestore) {
              return FirestoreMemoryLogRepository(
                firestore: FirebaseFirestore.instance,
              );
            }
            return InMemoryLogRepository(seed: seedLogs);
          },
          dispose: (_, repo) => repo.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => MemohookController(
            logRepository: context.read<MemoryLogRepository>(),
            speechService: context.read<SpeechCaptureService>(),
            assistantService: context.read<AssistantService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Memohook',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2A62FF),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            displaySmall: TextStyle(fontWeight: FontWeight.w600),
            titleMedium: TextStyle(fontWeight: FontWeight.w600),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        ),
        home: const AppShell(),
      ),
    );
  }
}
