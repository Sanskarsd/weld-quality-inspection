import 'package:flutter/material.dart';

import '../../domain/models/inspection_request.dart';
import '../../domain/models/inspection_result.dart';

class InspectionResultCard extends StatelessWidget {
  const InspectionResultCard({required this.result, super.key});

  final InspectionResult result;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (result.status) {
      InspectionStatus.passed => Colors.green,
      InspectionStatus.failed => Theme.of(context).colorScheme.error,
      InspectionStatus.underReview => Colors.orange.shade800,
    };
    final fields = <_ResultField>[
      _ResultField('Inspection ID', result.inspectionId),
      _ResultField(
        'Confidence',
        '${(result.confidence * 100).toStringAsFixed(1)}%',
      ),
      _ResultField('Defect detected', result.defectDetected ? 'Yes' : 'No'),
      _ResultField('Defect type', result.defectType ?? 'None reported'),
      _ResultField('Severity', result.severity?.label ?? 'Not applicable'),
      _ResultField(
        'Location / details',
        result.defectLocation ?? 'Not applicable',
      ),
      _ResultField(
        'Processing time',
        '${result.processingTime.inMilliseconds} ms',
      ),
      _ResultField('Completed', result.completedAt.toLocal().toString()),
      _ResultField('Image reference', result.imageName),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Inspection result',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                _StatusIndicator(
                  label: result.status.label,
                  color: statusColor,
                ),
              ],
            ),
            if (result.dataSourceNotice case final notice?) ...<Widget>[
              const SizedBox(height: 12),
              Chip(
                avatar: const Icon(Icons.info_outline, size: 18),
                label: Text(notice),
                visualDensity: VisualDensity.compact,
              ),
            ],
            const SizedBox(height: 16),
            if (result.image != null) ...<Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.memory(result.image!.bytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...<Widget>[
              const ListTile(
                leading: Icon(Icons.image_not_supported_outlined),
                title: Text('Inspection image unavailable'),
              ),
              const SizedBox(height: 8),
            ],
            if (result.componentName != null) ...<Widget>[
              Text(
                'Inspection information',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _ResultRow(
                field: _ResultField('Component', result.componentName!),
              ),
              if (result.jobBatchId != null)
                _ResultRow(
                  field: _ResultField('Job / Batch', result.jobBatchId!),
                ),
              if (result.inspectionType != null)
                _ResultRow(
                  field: _ResultField(
                    'Inspection type',
                    result.inspectionType!.label,
                  ),
                ),
              const Divider(height: 24),
            ],
            ...fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ResultRow(field: field),
              ),
            ),
            if (result.details case final details?) ...<Widget>[
              const Divider(height: 24),
              Text(
                'Additional details',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(details),
            ],
            if (result.inspectionNotes case final notes?) ...<Widget>[
              const Divider(height: 24),
              Text(
                'Inspection notes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(notes),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.12),
        shape: const StadiumBorder(),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color)),
    );
  }
}

class _ResultField {
  const _ResultField(this.label, this.value);

  final String label;
  final String value;
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.field});

  final _ResultField field;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(field.label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(field.value),
            ],
          );
        }
        return Row(
          children: <Widget>[
            SizedBox(
              width: 150,
              child: Text(
                field.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Expanded(child: Text(field.value)),
          ],
        );
      },
    );
  }
}
