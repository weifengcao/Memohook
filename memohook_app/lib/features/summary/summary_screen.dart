import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/memohook_controller.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MemohookController>();
    final theme = Theme.of(context);

    final isLoading = controller.isInitializing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Summary'),
        actions: [
          if (controller.dailySummary != null)
            IconButton(
              tooltip: 'Clear summary',
              onPressed: controller.dismissSummary,
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
              'Get a quick recap of today\'s memories.',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: controller.isSummarizing || isLoading
                  ? null
                  : () => context
                        .read<MemohookController>()
                        .generateDailySummary(),
              icon: controller.isSummarizing || isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_graph),
              label: Text(
                controller.isSummarizing
                    ? 'Summarizing…'
                    : isLoading
                    ? 'Loading memories…'
                    : 'Summarize today',
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.dailySummary == null
                  ? _SummaryPlaceholder(theme: theme)
                  : _SummaryCard(summary: controller.dailySummary!),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPlaceholder extends StatelessWidget {
  const _SummaryPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('No summary yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Generate a summary to hear what you logged today. Summaries combine the latest memories into a friendly recap.',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final String summary;

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
            Text('Today\'s recap', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(summary, style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
