import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../inspection/domain/models/inspection_result.dart';
import '../../application/providers/reports_providers.dart';
import '../../domain/models/report_data.dart';
import '../../domain/services/report_generator.dart';

class ReportPreviewScreen extends ConsumerStatefulWidget {
  const ReportPreviewScreen.single({required InspectionResult inspection, super.key})
      : _inspection = inspection,
        _inspections = null,
        _analytics = null,
        _filter = null,
        _type = ReportType.singleInspection;

  const ReportPreviewScreen.summary({required List<InspectionResult> inspections, required ReportData analytics, super.key})
      : _inspection = null,
        _inspections = inspections,
        _analytics = analytics,
        _filter = null,
        _type = ReportType.inspectionSummary;

  const ReportPreviewScreen.periodBatch({required List<InspectionResult> inspections, required ReportData analytics, required ReportFilter filter, super.key})
      : _inspection = null,
        _inspections = inspections,
        _analytics = analytics,
        _filter = filter,
        _type = ReportType.periodBatch;

  final InspectionResult? _inspection;
  final List<InspectionResult>? _inspections;
  final ReportData? _analytics;
  final ReportFilter? _filter;
  final ReportType _type;

  @override
  ConsumerState<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends ConsumerState<ReportPreviewScreen> {
  late final Future<GeneratedReport> _report;

  @override
  void initState() {
    super.initState();
    final generator = ref.read(reportGeneratorProvider);
    _report = switch (widget._type) {
      ReportType.singleInspection => generator.generateSingleInspection(widget._inspection!),
      ReportType.inspectionSummary => generator.generateSummary(widget._inspections!, widget._analytics!),
      ReportType.periodBatch => generator.generatePeriodBatch(widget._inspections!, widget._analytics!, widget._filter!),
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Report preview'),
      actions: [
        FutureBuilder<GeneratedReport>(
          future: _report,
          builder: (context, snapshot) => IconButton(
            tooltip: 'Export PDF',
            onPressed: snapshot.hasData ? () => Printing.sharePdf(bytes: snapshot.data!.bytes, filename: snapshot.data!.filename) : null,
            icon: const Icon(Icons.download_outlined),
          ),
        ),
      ],
    ),
    body: FutureBuilder<GeneratedReport>(
      future: _report,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Unable to generate this report.'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return PdfPreview(
          canChangePageFormat: false,
          canChangeOrientation: false,
          canDebug: false,
          build: (_) async => snapshot.data!.bytes,
          pdfFileName: snapshot.data!.filename,
        );
      },
    ),
  );
}
