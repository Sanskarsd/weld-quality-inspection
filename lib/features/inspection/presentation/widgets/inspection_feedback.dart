import 'package:flutter/material.dart';

class InspectionLoadingView extends StatelessWidget {
  const InspectionLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: <Widget>[
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
            SizedBox(width: 16),
            Expanded(child: Text('Analyzing inspection image...')),
          ],
        ),
      ),
    );
  }
}

class InspectionErrorView extends StatelessWidget {
  const InspectionErrorView({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(Icons.error_outline, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
