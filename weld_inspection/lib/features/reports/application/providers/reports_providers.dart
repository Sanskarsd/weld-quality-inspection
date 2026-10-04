import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/demo_reports_repository.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../domain/services/report_generator.dart';
import '../../data/services/pdf_report_generator.dart';
import '../../../inspection_history/application/providers/inspection_history_providers.dart';

/// The single selection point for a future FastAPI-backed repository.
final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => DemoReportsRepository(ref.read(demoInspectionHistoryStoreProvider)),
);

/// PDF creation is isolated from all presentation widgets and repositories.
final reportGeneratorProvider = Provider<ReportGenerator>(
  (ref) => PdfReportGenerator(),
);
