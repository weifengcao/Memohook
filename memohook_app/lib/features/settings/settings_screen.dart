import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('General', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: true,
            onChanged: (_) {},
            title: const Text('Daily summary notifications'),
            subtitle: const Text(
              'Send a reminder each evening to review the day.',
            ),
          ),
          const Divider(height: 32),
          Text('Voice preferences', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.record_voice_over_outlined),
            title: const Text('Preferred voice profile'),
            subtitle: const Text('Default (auto-detect)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Privacy and security'),
            subtitle: const Text(
              'Review how your memories are stored and protected.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 32),
          Text('Support', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help center'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text('Contact support'),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Version 1.0.0 (MVP)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
