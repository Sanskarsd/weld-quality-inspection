import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/shared_preferences_settings_repository.dart';
import '../../domain/repositories/settings_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider).requireValue;
  return SharedPreferencesSettingsRepository(preferences);
});
