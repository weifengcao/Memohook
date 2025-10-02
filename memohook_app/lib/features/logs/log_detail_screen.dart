import 'package:flutter/material.dart';

import '../../shared/time_format.dart';
import 'memory_log.dart';

class LogDetailScreen extends StatelessWidget {
  const LogDetailScreen({super.key, required this.log});

  final MemoryLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Memory details')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              friendlyTimestamp(log.createdAt),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(log.content, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: log.keywords.isEmpty
                  ? [
                      Chip(
                        avatar: const Icon(Icons.key, size: 16),
                        label: const Text('No keywords extracted'),
                      ),
                    ]
                  : log.keywords
                        .map(
                          (keyword) => Chip(
                            avatar: const Icon(Icons.key, size: 16),
                            label: Text(keyword),
                          ),
                        )
                        .toList(),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next steps', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'From here you will be able to expand this memory, add notes, or share it with a caregiver once those features land.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
