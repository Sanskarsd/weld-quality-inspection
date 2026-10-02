import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../inspection/domain/models/inspection_request.dart';
import '../../../inspection/domain/models/inspection_result.dart';
import '../../domain/models/report_data.dart';
import '../../domain/services/report_generator.dart';

class PdfReportGenerator implements ReportGenerator {
  PdfReportGenerator({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  @override
  Future<GeneratedReport> generateSingleInspection(InspectionResult inspection) async {
    final document = _document();
    document.addPage(
      pw.MultiPage(
        footer: _footer,
        build: (context) => [
          ..._heading('WELD INSPECTION REPORT', 'Single inspection record'),
          _section('Inspection information', _detailTable(_inspectionFields(inspection))),
          _section('Inspection result', _detailTable(_resultFields(inspection))),
          _section('Inspection image', _inspectionImage(inspection)),
          if (inspection.inspectionNotes case final notes?)
            _section('Inspection notes', pw.Text(notes)),
          if (inspection.details case final details?)
            _section('Result / explanation', pw.Text(details)),
          _generatedAt(),
        ],
      ),
    );
    return GeneratedReport(
      bytes: await document.save(),
      filename: 'weld_inspection_${inspection.inspectionId}.pdf',
      type: ReportType.singleInspection,
    );
  }

  @override
  Future<GeneratedReport> generateSummary(List<InspectionResult> inspections, ReportData analytics) =>
      _aggregateReport(
        title: 'WELD INSPECTION SUMMARY',
        subtitle: 'Inspection summary report',
        inspections: inspections,
        analytics: analytics,
        filename: 'weld_inspection_summary.pdf',
        type: ReportType.inspectionSummary,
      );

  @override
  Future<GeneratedReport> generatePeriodBatch(
    List<InspectionResult> inspections,
    ReportData analytics,
    ReportFilter filter,
  ) {
    final label = filter.jobBatchId?.isNotEmpty == true
        ? filter.jobBatchId!
        : 'selected_period';
    return _aggregateReport(
      title: 'WELD INSPECTION PERIOD / BATCH REPORT',
      subtitle: _filterDescription(filter),
      inspections: inspections,
      analytics: analytics,
      filename: 'weld_inspection_${label.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf',
      type: ReportType.periodBatch,
    );
  }

  Future<GeneratedReport> _aggregateReport({
    required String title,
    required String subtitle,
    required List<InspectionResult> inspections,
    required ReportData analytics,
    required String filename,
    required ReportType type,
  }) async {
    final document = _document();
    document.addPage(
      pw.MultiPage(
        footer: _footer,
        build: (context) => [
          ..._heading(title, subtitle),
          _section('Inspection summary', _summaryTable(analytics.summary)),
          _section('Defect distribution', _distributionTable(
            'Defect', analytics.defectDistribution.map((item) => [item.defectType, '${item.count}', '${item.percentage.toStringAsFixed(1)}%']).toList(),
          )),
          _section('Severity distribution', _distributionTable(
            'Severity', analytics.severityDistribution.map((item) => [item.severity, '${item.count}', '${item.percentage.toStringAsFixed(1)}%']).toList(),
          )),
          _section('Inspection trend', _distributionTable(
            'Date', analytics.inspectionTrend.map((item) => [item.label, '${item.total}', '${item.passed} passed / ${item.failed} failed / ${item.underReview} review']).toList(),
            valueHeader: 'Total',
            percentageHeader: 'Outcome',
          )),
          _section('Included inspections', _inspectionList(inspections)),
          _section('Quality insights', _insights(analytics)),
          _generatedAt(),
        ],
      ),
    );
    return GeneratedReport(bytes: await document.save(), filename: filename, type: type);
  }

  pw.Document _document() => pw.Document(
    theme: pw.ThemeData.withFont(base: pw.Font.helvetica(), bold: pw.Font.helveticaBold()),
  );

  List<pw.Widget> _heading(String title, String subtitle) => [
    pw.Text(title, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
    pw.SizedBox(height: 4),
    pw.Text('Weld Inspection System - $subtitle', style: const pw.TextStyle(color: PdfColors.blueGrey600)),
    pw.Divider(color: PdfColors.blueGrey300),
    pw.SizedBox(height: 10),
  ];

  pw.Widget _section(String title, pw.Widget child) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 14),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
      pw.SizedBox(height: 6),
      child,
    ]),
  );

  pw.Widget _detailTable(List<List<String>> rows) => pw.TableHelper.fromTextArray(
    headers: const ['Field', 'Value'], data: rows,
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
    cellAlignment: pw.Alignment.centerLeft,
  );

  pw.Widget _summaryTable(ReportSummary data) => _detailTable([
    ['Total inspections', '${data.totalInspections}'], ['Passed', '${data.passedInspections}'],
    ['Failed', '${data.failedInspections}'], ['Under review', '${data.underReviewInspections}'],
    ['Pass rate', '${data.passRate.toStringAsFixed(1)}%'], ['Average confidence', '${data.averageConfidence.toStringAsFixed(1)}%'],
    ['Average processing time', '${(data.averageProcessingTime.inMilliseconds / 1000).toStringAsFixed(1)} s'], ['Total defects', '${data.totalDefects}'],
  ]);

  pw.Widget _distributionTable(String firstHeader, List<List<String>> rows, {String valueHeader = 'Count', String percentageHeader = 'Share'}) =>
      rows.isEmpty ? pw.Text('No data available.') : pw.TableHelper.fromTextArray(
        headers: [firstHeader, valueHeader, percentageHeader], data: rows,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      );

  pw.Widget _inspectionList(List<InspectionResult> inspections) => inspections.isEmpty
      ? pw.Text('No inspections match this selection.')
      : pw.TableHelper.fromTextArray(
          headers: const ['Inspection ID', 'Component', 'Batch', 'Status'],
          data: inspections.map((record) => [record.inspectionId, record.componentName ?? '-', record.jobBatchId ?? '-', record.status.label]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
        );

  pw.Widget _inspectionImage(InspectionResult record) {
    if (record.image == null || record.image!.bytes.isEmpty) return pw.Text('Image unavailable.');
    return pw.Image(pw.MemoryImage(record.image!.bytes), fit: pw.BoxFit.contain, height: 240);
  }

  List<List<String>> _inspectionFields(InspectionResult item) => [
    ['Inspection ID', item.inspectionId], ['Component name', item.componentName ?? 'Not available'],
    ['Job / Batch ID', item.jobBatchId ?? 'Not available'], ['Inspection type', item.inspectionType?.label ?? 'Not available'],
    ['Inspection date/time', _date(item.completedAt)], ['Image reference', item.imageName],
  ];

  List<List<String>> _resultFields(InspectionResult item) => [
    ['Status', item.status.label], ['Defect', item.defectDetected ? item.defectType ?? 'Detected' : 'No defect detected'],
    ['Severity', item.severity?.label ?? 'Not applicable'], ['Confidence', '${(item.confidence * 100).toStringAsFixed(1)}%'],
    ['Processing time', '${item.processingTime.inMilliseconds} ms'], ['Location', item.defectLocation ?? 'Not available'],
  ];

  pw.Widget _insights(ReportData data) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Text('Pass rate: ${data.summary.passRate.toStringAsFixed(1)}%'),
    pw.Text('Average AI confidence: ${data.summary.averageConfidence.toStringAsFixed(1)}%'),
    if (data.defectDistribution.isNotEmpty) pw.Text('Most common defect: ${data.defectDistribution.first.defectType}'),
    if (data.severityDistribution.isNotEmpty) pw.Text('Most frequent severity: ${data.severityDistribution.first.severity}'),
  ]);

  pw.Widget _generatedAt() => pw.Padding(padding: const pw.EdgeInsets.only(top: 8), child: pw.Text('Generated by Weld Inspection System on ${_date(_clock())}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)));
  pw.Widget _footer(pw.Context context) => pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)));
  String _filterDescription(ReportFilter filter) => 'Selected ${filter.jobBatchId == null ? 'inspection period' : 'batch ${filter.jobBatchId}'}${filter.startDate == null && filter.endDate == null ? '' : ' - ${filter.startDate == null ? 'start' : _date(filter.startDate!)} to ${filter.endDate == null ? 'present' : _date(filter.endDate!)}'}';
  String _date(DateTime value) => '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}
