import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../inspection/domain/models/inspection_request.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._preferences);
  final SharedPreferences _preferences;
  static const _prefix = 'settings.';

  @override
  Future<AppSettings> load() async => AppSettings(
    themeMode: ThemeMode.values.byName(_preferences.getString('${_prefix}theme') ?? ThemeMode.system.name),
    notificationsEnabled: _preferences.getBool('${_prefix}notifications') ?? true,
    autoRefreshEnabled: _preferences.getBool('${_prefix}autoRefresh') ?? true,
    defaultInspectionType: InspectionType.values.byName(_preferences.getString('${_prefix}type') ?? InspectionType.weldVisual.name),
    confirmBeforeSubmission: _preferences.getBool('${_prefix}confirm') ?? true,
    autoSaveDraft: _preferences.getBool('${_prefix}draft') ?? true,
    imageQuality: ImageQuality.values.byName(_preferences.getString('${_prefix}quality') ?? ImageQuality.high.name),
  );

  @override
  Future<void> save(AppSettings value) async {
    await Future.wait([
      _preferences.setString('${_prefix}theme', value.themeMode.name),
      _preferences.setBool('${_prefix}notifications', value.notificationsEnabled),
      _preferences.setBool('${_prefix}autoRefresh', value.autoRefreshEnabled),
      _preferences.setString('${_prefix}type', value.defaultInspectionType.name),
      _preferences.setBool('${_prefix}confirm', value.confirmBeforeSubmission),
      _preferences.setBool('${_prefix}draft', value.autoSaveDraft),
      _preferences.setString('${_prefix}quality', value.imageQuality.name),
    ]);
  }
}
