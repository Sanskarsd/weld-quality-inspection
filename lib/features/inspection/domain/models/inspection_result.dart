import 'inspection_request.dart';

enum InspectionStatus { passed, failed, underReview }

enum DefectSeverity { low, medium, high, critical }

enum InspectionDataSource { demo, live }

extension InspectionStatusLabel on InspectionStatus {
  String get label => switch (this) {
    InspectionStatus.passed => 'Passed',
    InspectionStatus.failed => 'Failed',
    InspectionStatus.underReview => 'Under review',
  };
}

extension DefectSeverityLabel on DefectSeverity {
  String get label => switch (this) {
    DefectSeverity.low => 'Low',
    DefectSeverity.medium => 'Medium',
    DefectSeverity.high => 'High',
    DefectSeverity.critical => 'Critical',
  };
}

class InspectionResult {
  const InspectionResult({
    required this.inspectionId,
    required this.status,
    required this.confidence,
    required this.defectDetected,
    required this.processingTime,
    required this.completedAt,
    required this.imageName,
    required this.dataSource,
    this.image,
    this.componentName,
    this.jobBatchId,
    this.inspectionType,
    this.inspectionNotes,
    this.defectType,
    this.severity,
    this.defectLocation,
    this.details,
  });

  final String inspectionId;
  final InspectionStatus status;
  final double confidence;
  final bool defectDetected;
  final String? defectType;
  final DefectSeverity? severity;
  final String? defectLocation;
  final Duration processingTime;
  final DateTime completedAt;
  final String? details;
  final String imageName;
  final InspectionImage? image;
  final String? componentName;
  final String? jobBatchId;
  final InspectionType? inspectionType;
  final String? inspectionNotes;
  final InspectionDataSource dataSource;

  String? get dataSourceNotice => switch (dataSource) {
    InspectionDataSource.demo => 'Demonstration result — backend not connected',
    InspectionDataSource.live => null,
  };
}
