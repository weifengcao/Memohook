import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/memohook_controller.dart';
import '../../features/logs/log_detail_screen.dart';
import '../../features/logs/memory_log.dart';
import '../../shared/time_format.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _showManualLogComposer(BuildContext context) async {
    final controller = context.read<MemohookController>();
    final theme = Theme.of(context);
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: bottomInset + 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add a memory manually',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: textController,
                  autofocus: true,
                  minLines: 2,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText:
                        'Example: Fed the dog at 8am and took him for a walk.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please describe the memory before saving.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    final text = textController.text.trim();
                    await controller.addManualLog(text);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Memory saved: "$text"'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save memory'),
                ),
              ],
            ),
          ),
        );
      },
    );

    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MemohookController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              isBusy: controller.isInitializing,
              onAddLog: controller.isInitializing
                  ? null
                  : () => _showManualLogComposer(context),
            ),
            if (controller.isInitializing)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: controller.logs.isEmpty
                    ? const _EmptyState()
                    : _LogList(logs: controller.logs),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.isInitializing
            ? null
            : () => controller.toggleListening(),
        backgroundColor: controller.isListening
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primary,
        foregroundColor: controller.isListening
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onPrimary,
        icon: Icon(controller.isListening ? Icons.stop : Icons.mic),
        label: Text(
          controller.isListening
              ? 'Listening…'
              : controller.isInitializing
              ? 'Loading…'
              : 'Tap to Speak',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAddLog, required this.isBusy});

  final VoidCallback? onAddLog;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Hi David 👋', style: theme.textTheme.titleLarge),
              ),
              IconButton.filledTonal(
                tooltip: 'Add memory manually',
                onPressed: onAddLog,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'What would you like to remember or ask today?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isBusy
                          ? 'Setting things up… hang tight for a moment.'
                          : 'Tap the microphone and speak naturally. Memohook will log memories or answer questions for you.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogList extends StatelessWidget {
  const _LogList({required this.logs});

  final List<MemoryLog> logs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
      itemBuilder: (context, index) {
        final log = logs[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDetail(context, log),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.content, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        friendlyTimestamp(log.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: logs.length,
    );
  }

  void _openDetail(BuildContext context, MemoryLog log) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LogDetailScreen(log: log)));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text('Ready when you are', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Tap the microphone to start logging your day. Ask a question any time to hear what happened.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
