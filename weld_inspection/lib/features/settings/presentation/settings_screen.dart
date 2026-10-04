import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inspection/domain/models/inspection_request.dart';
import '../application/controllers/settings_controller.dart';
import '../domain/models/app_settings.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SafeArea(
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Settings could not be loaded.')),
        data: (settings) => _Content(settings: settings),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.settings});
  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Configure the inspection workspace and local quality-control preferences.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 28),
          _Section(title: 'General', children: [
            _ThemePicker(settings: settings),
            _SwitchTile(icon: Icons.notifications_outlined, title: 'Inspection notifications', subtitle: 'Show local inspection completion notifications.', value: settings.notificationsEnabled, onChanged: (value) => _save(ref, settings.copyWith(notificationsEnabled: value))),
            _SwitchTile(icon: Icons.refresh_outlined, title: 'Auto refresh', subtitle: 'Keep dashboard and report views ready for refresh.', value: settings.autoRefreshEnabled, onChanged: (value) => _save(ref, settings.copyWith(autoRefreshEnabled: value))),
            const ListTile(leading: Icon(Icons.language_outlined), title: Text('Language'), subtitle: Text('English')),
          ]),
          const SizedBox(height: 24),
          _Section(title: 'Inspection preferences', children: [
            _TypePicker(settings: settings),
            _SwitchTile(icon: Icons.fact_check_outlined, title: 'Confirm before submission', subtitle: 'Require confirmation before an inspection is submitted.', value: settings.confirmBeforeSubmission, onChanged: (value) => _save(ref, settings.copyWith(confirmBeforeSubmission: value))),
            _SwitchTile(icon: Icons.save_outlined, title: 'Auto-save inspection draft', subtitle: 'Keep local form-progress preference enabled.', value: settings.autoSaveDraft, onChanged: (value) => _save(ref, settings.copyWith(autoSaveDraft: value))),
            _QualityPicker(settings: settings),
          ]),
          const SizedBox(height: 24),
          _Section(title: 'Account', children: const [
            _PlaceholderTile(icon: Icons.person_outline, title: 'Profile'),
            _PlaceholderTile(icon: Icons.lock_outline, title: 'Change password'),
            _PlaceholderTile(icon: Icons.logout_outlined, title: 'Logout'),
          ]),
          const SizedBox(height: 24),
          _Section(title: 'Application', children: const [
            ListTile(leading: Icon(Icons.info_outline), title: Text('Weld Inspection System'), subtitle: Text('Version 1.0.0')),
            _PlaceholderTile(icon: Icons.help_outline, title: 'Help / Support'),
            _PlaceholderTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
            _PlaceholderTile(icon: Icons.gavel_outlined, title: 'Terms & Conditions'),
          ]),
        ]),
      ),
    ),
  );

  void _save(WidgetRef ref, AppSettings next) => ref.read(settingsControllerProvider.notifier).saveSettings(next);
}

class _ThemePicker extends ConsumerWidget {
  const _ThemePicker({required this.settings}); final AppSettings settings;
  @override Widget build(BuildContext context, WidgetRef ref) => DropdownButtonFormField<ThemeMode>(
    initialValue: settings.themeMode, decoration: const InputDecoration(labelText: 'Theme'),
    items: ThemeMode.values.map((mode) => DropdownMenuItem(value: mode, child: Text(mode.name[0].toUpperCase() + mode.name.substring(1)))).toList(),
    onChanged: (value) { if (value != null) ref.read(settingsControllerProvider.notifier).saveSettings(settings.copyWith(themeMode: value)); },
  );
}

class _TypePicker extends ConsumerWidget {
  const _TypePicker({required this.settings}); final AppSettings settings;
  @override Widget build(BuildContext context, WidgetRef ref) => DropdownButtonFormField<InspectionType>(
    initialValue: settings.defaultInspectionType, decoration: const InputDecoration(labelText: 'Default inspection type'), isExpanded: true,
    items: InspectionType.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
    onChanged: (value) { if (value != null) ref.read(settingsControllerProvider.notifier).saveSettings(settings.copyWith(defaultInspectionType: value)); },
  );
}

class _QualityPicker extends ConsumerWidget {
  const _QualityPicker({required this.settings}); final AppSettings settings;
  @override Widget build(BuildContext context, WidgetRef ref) => DropdownButtonFormField<ImageQuality>(
    initialValue: settings.imageQuality, decoration: const InputDecoration(labelText: 'Image quality'),
    items: ImageQuality.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
    onChanged: (value) { if (value != null) ref.read(settingsControllerProvider.notifier).saveSettings(settings.copyWith(imageQuality: value)); },
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children}); final String title; final List<Widget> children;
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge), const SizedBox(height: 12), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: children)))]);
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged}); final IconData icon; final String title, subtitle; final bool value; final ValueChanged<bool> onChanged;
  @override Widget build(BuildContext context) => SwitchListTile.adaptive(contentPadding: EdgeInsets.zero, secondary: Icon(icon), title: Text(title), subtitle: Text(subtitle), value: value, onChanged: onChanged);
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.icon, required this.title}); final IconData icon; final String title;
  @override Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title is coming soon.'))));
}
