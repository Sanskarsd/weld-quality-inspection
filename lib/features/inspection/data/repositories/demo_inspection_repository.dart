import '../../domain/models/inspection_request.dart';
import '../../domain/models/inspection_result.dart';
import '../../domain/repositories/inspection_repository.dart';

/// Local demonstration implementation. A future REST implementation must only
/// implement [InspectionRepository] and map its API response to [InspectionResult].
class DemoInspectionRepository implements InspectionRepository {
  const DemoInspectionRepository({
    this.processingDelay = const Duration(milliseconds: 700),
  });

  final Duration processingDelay;

  @override
  Future<InspectionResult> runInspection(InspectionRequest request) async {
    await Future<void>.delayed(processingDelay);

    final scenario =
        request.image.fileName.runes.fold<int>(0, (sum, rune) => sum + rune) %
        3;
    final completedAt = DateTime.now();

    return switch (scenario) {
      0 => InspectionResult(
        inspectionId: 'DEMO-${completedAt.millisecondsSinceEpoch}',
        status: InspectionStatus.passed,
        confidence: 0.97,
        defectDetected: false,
        processingTime: const Duration(milliseconds: 700),
        completedAt: completedAt,
        imageName: request.image.fileName,
        details: 'No significant visual indication was identified in this demonstration result.',
        dataSource: InspectionDataSource.demo,
      ),
      1 => InspectionResult(
        inspectionId: 'DEMO-${completedAt.millisecondsSinceEpoch}',
        status: InspectionStatus.failed,
        confidence: 0.91,
        defectDetected: true,
        defectType: 'Surface discontinuity',
        severity: DefectSeverity.high,
        defectLocation: 'Weld toe region',
        processingTime: const Duration(milliseconds: 700),
        completedAt: completedAt,
        imageName: request.image.fileName,
        details: 'Demonstration result indicates a visual feature requiring quality review.',
        dataSource: InspectionDataSource.demo,
      ),
      _ => InspectionResult(
        inspectionId: 'DEMO-${completedAt.millisecondsSinceEpoch}',
        status: InspectionStatus.underReview,
        confidence: 0.76,
        defectDetected: true,
        defectType: 'Potential surface irregularity',
        severity: DefectSeverity.medium,
        defectLocation: 'Longitudinal seam',
        processingTime: const Duration(milliseconds: 700),
        completedAt: completedAt,
        imageName: request.image.fileName,
        details: 'Demonstration result requires inspector confirmation.',
        dataSource: InspectionDataSource.demo,
      ),
    };
  }
}
