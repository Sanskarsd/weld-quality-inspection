import 'package:flutter/material.dart';

import '../../domain/models/inspection_request.dart';

class InspectionImageInput extends StatelessWidget {
  const InspectionImageInput({
    required this.image,
    required this.isLoading,
    required this.onSelect,
    required this.onRemove,
    super.key,
  });

  final InspectionImage? image;
  final bool isLoading;
  final VoidCallback onSelect;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Inspection image', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Upload a clear JPG, JPEG, PNG, or WEBP image of the weld or fabrication area.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (image == null)
              _EmptyImageInput(onSelect: onSelect, isLoading: isLoading)
            else
              _SelectedImageInput(
                image: image!,
                onSelect: onSelect,
                onRemove: onRemove,
                isLoading: isLoading,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyImageInput extends StatelessWidget {
  const _EmptyImageInput({required this.onSelect, required this.isLoading});

  final VoidCallback onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 44,
            color: scheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('No inspection image selected'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isLoading ? null : onSelect,
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Select image'),
          ),
        ],
      ),
    );
  }
}

class _SelectedImageInput extends StatelessWidget {
  const _SelectedImageInput({
    required this.image,
    required this.onSelect,
    required this.onRemove,
    required this.isLoading,
  });

  final InspectionImage image;
  final VoidCallback onSelect;
  final VoidCallback onRemove;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Image.memory(image.bytes, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 12),
        Text(image.fileName, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: isLoading ? null : onSelect,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Replace'),
            ),
            TextButton.icon(
              onPressed: isLoading ? null : onRemove,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
      ],
    );
  }
}
