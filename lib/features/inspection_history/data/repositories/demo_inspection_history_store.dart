import 'dart:async';

import '../../../inspection/domain/models/inspection_result.dart';

class DemoInspectionHistoryStore {
  DemoInspectionHistoryStore()
    : _records = List<InspectionResult>.of(initialRecords);

  static final List<InspectionResult> initialRecords = <InspectionResult>[
    InspectionResult(
      inspectionId: 'WI-2026-1042',
      status: InspectionStatus.passed,
      confidence: .98,
      defectDetected: false,
      processingTime: const Duration(milliseconds: 842),
      completedAt: DateTime(2026, 10, 1, 14, 25),
      imageName: 'vessel_shell_042.jpg',
      dataSource: InspectionDataSource.demo,
      details: 'Visual quality criteria satisfied.',
    ),
    InspectionResult(
      inspectionId: 'WI-2026-1041',
      status: InspectionStatus.failed,
      confidence: .93,
      defectDetected: true,
      defectType: 'Surface crack',
      severity: DefectSeverity.high,
      defectLocation: 'Circumferential seam',
      processingTime: const Duration(milliseconds: 1065),
      completedAt: DateTime(2026, 10, 1, 11, 10),
      imageName: 'nozzle_weld_041.jpg',
      dataSource: InspectionDataSource.demo,
      details: 'Quality review is required before release.',
    ),
    InspectionResult(
      inspectionId: 'WI-2026-1040',
      status: InspectionStatus.underReview,
      confidence: .78,
      defectDetected: true,
      defectType: 'Potential undercut',
      severity: DefectSeverity.medium,
      defectLocation: 'Weld toe',
      processingTime: const Duration(milliseconds: 977),
      completedAt: DateTime(2026, 9, 30, 16, 42),
      imageName: 'pipe_spool_040.png',
      dataSource: InspectionDataSource.demo,
      details: 'Manual inspector confirmation is pending.',
    ),
    InspectionResult(
      inspectionId: 'WI-2026-1039',
      status: InspectionStatus.passed,
      confidence: .96,
      defectDetected: false,
      processingTime: const Duration(milliseconds: 755),
      completedAt: DateTime(2026, 9, 30, 9, 5),
      imageName: 'support_skirt_039.jpg',
      dataSource: InspectionDataSource.demo,
      details: 'Visual quality criteria satisfied.',
    ),
    InspectionResult(
      inspectionId: 'WI-2026-1038',
      status: InspectionStatus.failed,
      confidence: .89,
      defectDetected: true,
      defectType: 'Porosity indication',
      severity: DefectSeverity.medium,
      defectLocation: 'Longitudinal seam',
      processingTime: const Duration(milliseconds: 1124),
      completedAt: DateTime(2026, 9, 29, 13, 30),
      imageName: 'exchanger_shell_038.webp',
      dataSource: InspectionDataSource.demo,
      details: 'Quality review is required before release.',
    ),
  ];
  final List<InspectionResult> _records;
  final StreamController<List<InspectionResult>> _changes =
      StreamController<List<InspectionResult>>.broadcast();
  List<InspectionResult> get records =>
      List<InspectionResult>.unmodifiable(_records);
  Stream<List<InspectionResult>> get changes => _changes.stream;
  void add(InspectionResult result) {
    if (_records.any((item) => item.inspectionId == result.inspectionId)) {
      return;
    }
    _records.insert(0, result);
    _changes.add(records);
  }

  InspectionResult? byId(String id) {
    for (final item in _records) {
      if (item.inspectionId == id) return item;
    }
    return null;
  }

  void dispose() => _changes.close();
}
