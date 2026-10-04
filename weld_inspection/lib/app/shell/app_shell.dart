import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import 'app_navigation.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final selectedRoute = AppRoute.fromPath(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 760;
        final navigation = AppNavigation(
          selectedRoute: selectedRoute,
          onDestinationSelected: (route) => context.go(route.path),
        );

        if (isMobile) {
          return Scaffold(
            body: child,
            bottomNavigationBar: SafeArea(top: false, child: navigation),
          );
        }

        return Scaffold(
          body: Row(
            children: <Widget>[
              navigation,
              VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
