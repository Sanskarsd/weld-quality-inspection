import 'package:flutter/material.dart';

import '../../../inspection/domain/models/inspection_request.dart';

enum ImageQuality { high, medium, low }

extension ImageQualityLabel on ImageQuality {
  String get label => switch (this) {
    ImageQuality.high => 'High',
    ImageQuality.medium => 'Medium',
    ImageQuality.low => 'Low',
  };
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.autoRefreshEnabled = true,
    this.defaultInspectionType = InspectionType.weldVisual,
    this.confirmBeforeSubmission = true,
    this.autoSaveDraft = true,
    this.imageQuality = ImageQuality.high,
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool autoRefreshEnabled;
  final InspectionType defaultInspectionType;
  final bool confirmBeforeSubmission;
  final bool autoSaveDraft;
  final ImageQuality imageQuality;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? autoRefreshEnabled,
    InspectionType? defaultInspectionType,
    bool? confirmBeforeSubmission,
    bool? autoSaveDraft,
    ImageQuality? imageQuality,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
    defaultInspectionType: defaultInspectionType ?? this.defaultInspectionType,
    confirmBeforeSubmission: confirmBeforeSubmission ?? this.confirmBeforeSubmission,
    autoSaveDraft: autoSaveDraft ?? this.autoSaveDraft,
    imageQuality: imageQuality ?? this.imageQuality,
  );
}
