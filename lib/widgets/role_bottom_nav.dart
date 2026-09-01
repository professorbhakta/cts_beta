import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Role-safe bottom navigation for commuter and driver homes.
///
/// Admin keeps the drawer/dashboard shell — this bar is never shown for admin.
enum RoleBottomNavTab { home, scan, track, profile, returnList }

class RoleBottomNav extends StatelessWidget {
  const RoleBottomNav({
    super.key,
    required this.selected,
    this.onScan,
    this.onTrack,
    this.onReturnList,
  });

  final RoleBottomNavTab selected;
  final VoidCallback? onScan;
  final VoidCallback? onTrack;
  final VoidCallback? onReturnList;

  @override
  Widget build(BuildContext context) {
    if (SessionRole.isAdmin) return const SizedBox.shrink();

    final scheme = context.scheme;
    final cts = context.cts;

    if (SessionRole.isDriver) {
      return NavigationBar(
        selectedIndex: _driverIndex(selected),
        indicatorColor: cts.navy.withValues(alpha: 0.12),
        backgroundColor: scheme.surface,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              if (selected != RoleBottomNavTab.home) {
                context.go(RouteName.driverHomeScreen);
              }
            case 1:
              onReturnList?.call();
            case 2:
              context.push(RouteName.profileScreen);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_return_outlined),
            selectedIcon: Icon(Icons.assignment_return_rounded),
            label: 'Return',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      );
    }

    // Commuter
    return NavigationBar(
      selectedIndex: _commuterIndex(selected),
      indicatorColor: cts.navy.withValues(alpha: 0.12),
      backgroundColor: scheme.surface,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            if (selected != RoleBottomNavTab.home) {
              context.go(RouteName.commuterHomeScreen);
            }
          case 1:
            onScan?.call();
          case 2:
            onTrack?.call();
          case 3:
            context.push(RouteName.profileScreen);
        }
      },
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: scheme.onSurfaceVariant),
          selectedIcon: Icon(Icons.home_rounded, color: cts.navy),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.qr_code_scanner_outlined, color: scheme.onSurfaceVariant),
          selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: cts.navy),
          label: 'Scan',
        ),
        NavigationDestination(
          icon: Icon(Icons.location_on_outlined, color: scheme.onSurfaceVariant),
          selectedIcon: Icon(Icons.location_on_rounded, color: cts.navy),
          label: 'Track',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: scheme.onSurfaceVariant),
          selectedIcon: Icon(Icons.person_rounded, color: cts.navy),
          label: 'Profile',
        ),
      ],
    );
  }

  static int _commuterIndex(RoleBottomNavTab tab) => switch (tab) {
        RoleBottomNavTab.home => 0,
        RoleBottomNavTab.scan => 1,
        RoleBottomNavTab.track => 2,
        RoleBottomNavTab.profile => 3,
        RoleBottomNavTab.returnList => 0,
      };

  static int _driverIndex(RoleBottomNavTab tab) => switch (tab) {
        RoleBottomNavTab.home => 0,
        RoleBottomNavTab.returnList => 1,
        RoleBottomNavTab.profile => 2,
        RoleBottomNavTab.scan ||
        RoleBottomNavTab.track =>
          0,
      };
}
