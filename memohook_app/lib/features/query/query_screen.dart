import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/memohook_controller.dart';
import '../../features/logs/memory_log.dart';
import '../../shared/time_format.dart';

class QueryScreen extends StatefulWidget {
  const QueryScreen({super.key});

  @override
  State<QueryScreen> createState() => _QueryScreenState();
}

class _QueryScreenState extends State<QueryScreen> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MemohookController>();
    final theme = Theme.of(context);

    final isLoading = controller.isInitializing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask Memohook'),
        actions: [
          if (controller.queryResult != null)
            IconButton(
              tooltip: 'Clear result',
              onPressed: controller.dismissQueryResult,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask a question about your day',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Example: Did I take my evening pills?',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: controller.isQuerying || isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  controller.isQuerying
                      ? 'Looking up…'
                      : isLoading
                      ? 'Loading memories…'
                      : 'Ask now',
                ),
                onPressed: controller.isQuerying || isLoading
                    ? null
                    : () {
                        FocusScope.of(context).unfocus();
                        final prompt = _promptController.text.trim();
                        if (prompt.isNotEmpty) {
                          context.read<MemohookController>().askQuestion(
                            prompt,
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.queryResult == null
                  ? _QueryPlaceholder(theme: theme)
                  : _QueryResultCard(log: controller.queryResult!),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueryPlaceholder extends StatelessWidget {
  const _QueryPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No questions yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Type a question or speak to Memohook to find the latest memory that matches.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QueryResultCard extends StatelessWidget {
  const _QueryResultCard({required this.log});

  final MemoryLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Most recent match', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(log.content, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              friendlyTimestamp(log.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () => context
                    .read<MemohookController>()
                    .addManualLog('Memohook answered: "${log.content}"'),
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
