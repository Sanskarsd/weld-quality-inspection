import 'package:flutter/material.dart';

import '../../../inspection/domain/models/inspection_result.dart';
import 'history_status_badge.dart';

class HistoryRecordsView extends StatelessWidget {
  const HistoryRecordsView({
    required this.records,
    required this.onSelect,
    super.key,
  });
  final List<InspectionResult> records;
  final ValueChanged<InspectionResult> onSelect;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth >= 760
        ? _Table(records: records, onSelect: onSelect)
        : _List(records: records, onSelect: onSelect),
  );
}

class _Table extends StatelessWidget {
  const _Table({required this.records, required this.onSelect});
  final List<InspectionResult> records;
  final ValueChanged<InspectionResult> onSelect;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Inspection ID')),
            DataColumn(label: Text('Component')),
            DataColumn(label: Text('Job / Batch')),
            DataColumn(label: Text('Date / time')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Defect')),
            DataColumn(label: Text('Severity')),
            DataColumn(label: Text('Confidence')),
            DataColumn(label: Text('View')),
          ],
          rows: <DataRow>[
            for (final record in records)
              DataRow(
                cells: <DataCell>[
                  DataCell(Text(record.inspectionId)),
                  DataCell(Text(record.componentName ?? '—')),
                  DataCell(Text(record.jobBatchId ?? '—')),
                  DataCell(Text(_date(record))),
                  DataCell(HistoryStatusBadge(status: record.status)),
                  DataCell(Text(record.defectType ?? 'None')),
                  DataCell(Text(record.severity?.label ?? '—')),
                  DataCell(
                    Text('${(record.confidence * 100).toStringAsFixed(0)}%'),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => onSelect(record),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.records, required this.onSelect});
  final List<InspectionResult> records;
  final ValueChanged<InspectionResult> onSelect;
  @override
  Widget build(BuildContext context) => Column(
    children: records
        .map(
          (r) => Card(
            child: ListTile(
              onTap: () => onSelect(r),
              title: Text(r.inspectionId),
              subtitle: Text(
                '${r.componentName ?? 'Component unavailable'}${r.jobBatchId == null ? '' : ' · ${r.jobBatchId}'}\n${_date(r)} · ${r.defectType ?? 'No defect reported'} · ${(r.confidence * 100).toStringAsFixed(0)}% confidence',
              ),
              isThreeLine: true,
              trailing: HistoryStatusBadge(status: r.status),
            ),
          ),
        )
        .toList(),
  );
}

String _date(InspectionResult result) =>
    result.completedAt.toLocal().toString().substring(0, 16);
