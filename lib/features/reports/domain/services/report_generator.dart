import 'dart:typed_data';

import '../../../inspection/domain/models/inspection_result.dart';
import '../models/report_data.dart';

enum ReportType { singleInspection, inspectionSummary, periodBatch }

class ReportFilter {
  const ReportFilter({this.startDate, this.endDate, this.jobBatchId});

  final DateTime? startDate;
  final DateTime? endDate;
  final String? jobBatchId;

  List<InspectionResult> apply(List<InspectionResult> records) => records.where((record) {
    final afterStart = startDate == null ||
        !record.completedAt.isBefore(DateTime(startDate!.year, startDate!.month, startDate!.day));
    final beforeEnd = endDate == null ||
        record.completedAt.isBefore(DateTime(endDate!.year, endDate!.month, endDate!.day + 1));
    final batchMatches = jobBatchId == null ||
        jobBatchId!.isEmpty ||
        record.jobBatchId == jobBatchId;
    return afterStart && beforeEnd && batchMatches;
  }).toList();
}

class GeneratedReport {
  const GeneratedReport({
    required this.bytes,
    required this.filename,
    required this.type,
  });

  final Uint8List bytes;
  final String filename;
  final ReportType type;
}

abstract interface class ReportGenerator {
  Future<GeneratedReport> generateSingleInspection(InspectionResult inspection);

  Future<GeneratedReport> generateSummary(
    List<InspectionResult> inspections,
    ReportData analytics,
  );

  Future<GeneratedReport> generatePeriodBatch(
    List<InspectionResult> inspections,
    ReportData analytics,
    ReportFilter filter,
  );
}
