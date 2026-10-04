import 'package:flutter/material.dart';

import '../../domain/models/inspection_request.dart';

class InspectionMetadataForm extends StatelessWidget {
  const InspectionMetadataForm({
    required this.type,
    required this.componentName,
    required this.jobBatchId,
    required this.notes,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onComponentNameChanged,
    required this.onJobBatchIdChanged,
    required this.onNotesChanged,
    super.key,
  });

  final InspectionType type;
  final String componentName;
  final String jobBatchId;
  final String notes;
  final bool isLoading;
  final ValueChanged<InspectionType> onTypeChanged;
  final ValueChanged<String> onComponentNameChanged;
  final ValueChanged<String> onJobBatchIdChanged;
  final ValueChanged<String> onNotesChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Inspection details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InspectionType>(
              initialValue: type,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Inspection type'),
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) onTypeChanged(value);
                    },
              items: InspectionType.values
                  .map(
                    (value) => DropdownMenuItem<InspectionType>(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: componentName,
              enabled: !isLoading,
              onChanged: onComponentNameChanged,
              decoration: const InputDecoration(
                labelText: 'Component name',
                helperText: 'Required',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: jobBatchId,
              enabled: !isLoading,
              onChanged: onJobBatchIdChanged,
              decoration: const InputDecoration(
                labelText: 'Job / Batch ID (optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: notes,
              enabled: !isLoading,
              minLines: 3,
              maxLines: 5,
              onChanged: onNotesChanged,
              decoration: const InputDecoration(
                labelText: 'Inspection notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
