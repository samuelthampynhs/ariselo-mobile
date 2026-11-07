import 'package:flutter/material.dart';

import 'family.dart';
import 'plan.dart';
import 'settings.dart';

/// The grown-ups' part of the app: Family, Plan and Account.
/// Phones: tabs along the bottom. Tablets and wide windows: a rail down the side, with the
/// page beside it.
class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  /// Wider than this, the tabs become a side rail.
  static const wide = 720.0;

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  int _tab = 0;

  static const _pages = [FamilyScreen(), PlanScreen(), SettingsScreen()];
  static const _tabs = [
    (Icons.family_restroom_outlined, Icons.family_restroom, 'My family'),
    (Icons.workspace_premium_outlined, Icons.workspace_premium, 'Plan'),
    (Icons.settings_outlined, Icons.settings, 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = IndexedStack(index: _tab, children: _pages);
    void go(int i) => setState(() => _tab = i);
    return LayoutBuilder(builder: (context, size) {
      if (size.maxWidth >= ParentHome.wide) {
        return Scaffold(
          body: SafeArea(
            child: Row(children: [
              NavigationRail(
                selectedIndex: _tab,
                onDestinationSelected: go,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final t in _tabs)
                    NavigationRailDestination(icon: Icon(t.$1), selectedIcon: Icon(t.$2), label: Text(t.$3)),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: pages),
            ]),
          ),
        );
      }
      return Scaffold(
        body: pages,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: go,
          destinations: [
            for (final t in _tabs) NavigationDestination(icon: Icon(t.$1), selectedIcon: Icon(t.$2), label: t.$3),
          ],
        ),
      );
    });
  }
}
