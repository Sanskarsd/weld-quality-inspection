import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/inspection_history_controller.dart';
import '../../../inspection/presentation/widgets/inspection_result_card.dart';
import '../../../reports/presentation/screens/report_preview_screen.dart';
import '../widgets/history_states.dart';

class InspectionHistoryDetailScreen extends ConsumerWidget {
  const InspectionHistoryDetailScreen({required this.inspectionId, super.key});
  final String inspectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(inspectionDetailProvider(inspectionId));
    final child = detail.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(48),
        child: CircularProgressIndicator(),
      ),
      error: (_, _) => const HistoryMessage(
        icon: Icons.error_outline,
        title: 'Inspection unavailable',
        message: 'The selected inspection could not be loaded.',
      ),
      data: (record) => record == null
          ? const HistoryMessage(
              icon: Icons.find_in_page_outlined,
              title: 'Inspection not found',
              message: 'This inspection record is unavailable.',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InspectionResultCard(result: record),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ReportPreviewScreen.single(inspection: record),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('Generate Report'),
                ),
              ],
            ),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
