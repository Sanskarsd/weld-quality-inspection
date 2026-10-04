import 'package:flutter/material.dart';

import '../router/app_routes.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({
    required this.selectedRoute,
    required this.onDestinationSelected,
    super.key,
  });

  final AppRoute selectedRoute;
  final ValueChanged<AppRoute> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return NavigationBar(
            height: 72,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: selectedRoute.index,
            onDestinationSelected: (index) {
              onDestinationSelected(AppRoute.values[index]);
            },
            destinations: AppRoute.values
                .map(
                  (route) => NavigationDestination(
                    icon: Icon(route.icon),
                    label: route.label,
                  ),
                )
                .toList(),
          );
        }

        return _DesktopSidebar(
          selectedRoute: selectedRoute,
          onDestinationSelected: onDestinationSelected,
        );
      },
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.selectedRoute,
    required this.onDestinationSelected,
  });

  final AppRoute selectedRoute;
  final ValueChanged<AppRoute> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      child: SizedBox(
        width: 272,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.precision_manufacturing_outlined,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Weld Inspection\nQuality System',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: AppRoute.values
                      .map(
                        (route) {
                          final selected = selectedRoute == route;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: selected
                                    ? theme.colorScheme.secondaryContainer
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? theme.colorScheme.primary.withValues(alpha: .18)
                                      : Colors.transparent,
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  route.icon,
                                  color: selected
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                                title: Text(
                                  route.label,
                                  style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                                selected: selected,
                                selectedTileColor: Colors.transparent,
                                onTap: () => onDestinationSelected(route),
                              ),
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
              ),
              const Divider(),
              const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text('Operator'),
                subtitle: Text('Quality Control'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
