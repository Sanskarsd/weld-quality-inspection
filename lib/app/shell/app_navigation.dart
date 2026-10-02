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
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: 272,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.precision_manufacturing_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Weld Inspection\nSystem',
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
                        (route) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: ListTile(
                            leading: Icon(route.icon),
                            title: Text(route.label),
                            selected: selectedRoute == route,
                            shape: const StadiumBorder(),
                            onTap: () => onDestinationSelected(route),
                          ),
                        ),
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
