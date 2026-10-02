import 'package:flutter/material.dart';

import '../../data/models/dashboard_data.dart';
import 'status_badge.dart';

class RecentInspections extends StatelessWidget {
  const RecentInspections({required this.inspections, super.key});

  final List<RecentInspection> inspections;

  @override
  Widget build(BuildContext context) {
    if (inspections.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: ListTile(
            leading: Icon(Icons.inbox_outlined),
            title: Text('No inspections available'),
            subtitle: Text('Completed inspections will appear here.'),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return _InspectionList(inspections: inspections);
        }
        return _InspectionTable(inspections: inspections);
      },
    );
  }
}

class _InspectionTable extends StatelessWidget {
  const _InspectionTable({required this.inspections});

  final List<RecentInspection> inspections;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const <DataColumn>[
            DataColumn(label: Text('Inspection ID')),
            DataColumn(label: Text('Component / Job')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Result summary')),
          ],
          rows: inspections
              .map(
                (inspection) => DataRow(
                  cells: <DataCell>[
                    DataCell(Text(inspection.id)),
                    DataCell(Text(inspection.componentName)),
                    DataCell(Text(inspection.dateLabel)),
                    DataCell(StatusBadge(status: inspection.status)),
                    DataCell(Text(inspection.resultSummary)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _InspectionList extends StatelessWidget {
  const _InspectionList({required this.inspections});

  final List<RecentInspection> inspections;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: inspections
          .map(
            (inspection) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            inspection.componentName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        StatusBadge(status: inspection.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(inspection.id),
                    Text(inspection.dateLabel),
                    const SizedBox(height: 8),
                    Text(inspection.resultSummary),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
