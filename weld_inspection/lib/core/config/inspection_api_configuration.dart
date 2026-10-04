/// Central build-time configuration for the replaceable live inspection API.
///
/// Demo mode remains the default so local development and widget tests do not
/// depend on a running ML service. Enable live inference with:
/// `--dart-define=INSPECTION_MODE=live --dart-define=INSPECTION_API_BASE_URL=...`
class InspectionApiConfiguration {
  const InspectionApiConfiguration({
    required this.useLiveInspection,
    required this.baseUrl,
  });

  static const InspectionApiConfiguration fromEnvironment =
      InspectionApiConfiguration(
        useLiveInspection:
            String.fromEnvironment('INSPECTION_MODE', defaultValue: 'demo') ==
            'live',
        baseUrl: String.fromEnvironment(
          'INSPECTION_API_BASE_URL',
          defaultValue: 'http://10.0.2.2:8000',
        ),
      );

  final bool useLiveInspection;
  final String baseUrl;
}
