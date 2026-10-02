import 'package:flutter/material.dart';

class ScreenPlaceholder extends StatelessWidget {
  const ScreenPlaceholder({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(description, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
