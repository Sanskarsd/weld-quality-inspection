import 'package:flutter/material.dart';

class DashboardSection extends StatelessWidget {
  const DashboardSection({
    required this.title,
    required this.child,
    this.action,
    super.key,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final titleWidget = Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            );
            if (action == null || constraints.maxWidth >= 600) {
              return Row(
                children: <Widget>[
                  Expanded(child: titleWidget),
                  ?action,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleWidget,
                const SizedBox(height: 8),
                action!,
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
