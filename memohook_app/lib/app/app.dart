import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/memohook_controller.dart';
import '../core/services/assistant_service.dart';
import '../core/services/memory_log_repository.dart';
import '../core/services/speech_capture_service.dart';
import '../features/logs/memory_log.dart';
import 'app_shell.dart';

class MemohookApp extends StatelessWidget {
  const MemohookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A62FF),
      brightness: Brightness.light,
    );

    final seedLogs = [
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
        Provider<AssistantService>(create: (_) => MockAssistantService()),
        Provider<SpeechCaptureService>(
          create: (_) => MockSpeechCaptureService(),
        ),
        Provider<MemoryLogRepository>(
          create: (_) => InMemoryLogRepository(seed: seedLogs),
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
          colorScheme: colorScheme,
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
