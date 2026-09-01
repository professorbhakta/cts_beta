import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/controller_reset_util.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/offline_temp/screens/offline_home_screen.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: switch (SessionRole.userType) {
        'COMMUTER' => const CommuterNavList(),
        'DRIVER' => const DriverNavList(),
        _ => const AdminNavList(),
      },
    );
  }
}

/// Driver-only drawer: Home, Profile, Logout.
/// No admin management routes.
class DriverNavList extends StatelessWidget {
  const DriverNavList({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final homeRoute = RouteName.driverHomeScreen;

    return _DrawerShell(
      children: [
        const _DrawerQuietHeader(),
        _DrawerNavTile(
          icon: Icons.home_outlined,
          title: 'Home',
          route: homeRoute,
          isSelected: currentRoute == homeRoute,
        ),
        _DrawerNavTile(
          icon: Icons.person_outline,
          title: 'Profile',
          route: RouteName.profileScreen,
          isSelected: currentRoute == RouteName.profileScreen,
        ),
        const Spacer(),
        const _DrawerLogoutTile(),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
      ],
    );
  }
}

/// Commuter-only drawer: Home, Profile, Track cab, Logout.
/// No admin management routes.
class CommuterNavList extends StatelessWidget {
  const CommuterNavList({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final homeRoute = RouteName.commuterHomeScreen;

    return _DrawerShell(
      children: [
        const _DrawerQuietHeader(),
        _DrawerNavTile(
          icon: Icons.home_outlined,
          title: 'Home',
          route: homeRoute,
          isSelected: currentRoute == homeRoute,
        ),
        _DrawerNavTile(
          icon: Icons.person_outline,
          title: 'Profile',
          route: RouteName.profileScreen,
          isSelected: currentRoute == RouteName.profileScreen,
        ),
        _DrawerNavTile(
          icon: Icons.my_location_outlined,
          title: 'Track cab',
          route: RouteName.trackCabScreen,
          isSelected: currentRoute == RouteName.trackCabScreen,
        ),
        const Spacer(),
        const _DrawerLogoutTile(),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
      ],
    );
  }
}

/// Admin drawer: home/dashboard, profile, management routes, logout.
class AdminNavList extends StatelessWidget {
  const AdminNavList({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isAdmin = SessionRole.isAdmin;
    final homeRoute = SessionRole.homeRoute;

    return _DrawerShell(
      scrollable: true,
      children: [
        const _DrawerQuietHeader(),
        _DrawerNavTile(
          icon: isAdmin ? Icons.dashboard_outlined : Icons.home_outlined,
          title: isAdmin ? 'Dashboard' : 'Home',
          route: homeRoute,
          isSelected: currentRoute == homeRoute,
        ),
        _DrawerNavTile(
          icon: Icons.person_outline,
          title: 'Profile',
          route: RouteName.profileScreen,
          isSelected: currentRoute == RouteName.profileScreen,
        ),
        if (isAdmin) ...[
          _SyncStatusBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'MANAGEMENT',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ),
          _DrawerNavTile(
            icon: Icons.people_outline,
            title: 'Commuters',
            route: RouteName.commuterScreen,
            isSelected: currentRoute == RouteName.commuterScreen,
          ),
          _DrawerNavTile(
            icon: Icons.location_on_outlined,
            title: 'Pick-up Points',
            route: RouteName.popScreen,
            isSelected: currentRoute == RouteName.popScreen,
          ),
          _DrawerNavTile(
            icon: Icons.directions_bus_outlined,
            title: 'Batches',
            route: RouteName.batchScreen,
            isSelected: currentRoute == RouteName.batchScreen,
          ),
          _DrawerNavTile(
            icon: Icons.directions_car_outlined,
            title: 'Cabs',
            route: RouteName.cabScreen,
            isSelected: currentRoute == RouteName.cabScreen,
          ),
          _DrawerNavTile(
            icon: Icons.badge_outlined,
            title: 'Drivers',
            route: RouteName.driverScreen,
            isSelected: currentRoute == RouteName.driverScreen,
          ),
          _DrawerNavTile(
            icon: Icons.route_outlined,
            title: 'Routes',
            route: RouteName.routeScreen,
            isSelected: currentRoute == RouteName.routeScreen,
          ),
          if (showOfflineDrawerTile()) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'OFFLINE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            _DrawerNavTile(
              icon: Icons.cloud_off_outlined,
              title: 'Offline Mode',
              route: RouteName.offlineTempHome,
              isSelected: currentRoute == RouteName.offlineTempHome,
            ),
          ],
        ],
        const SizedBox(height: 24),
        const _DrawerLogoutTile(),
        SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
      ],
    );
  }
}

class _DrawerShell extends StatelessWidget {
  const _DrawerShell({
    required this.children,
    this.scrollable = false,
  });

  final List<Widget> children;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final cream = Theme.of(context).scaffoldBackgroundColor;

    if (scrollable) {
      return ColoredBox(
        color: cream,
        child: ListView(
          padding: EdgeInsets.zero,
          children: children,
        ),
      );
    }

    return ColoredBox(
      color: cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Quiet cream header: C2S kicker, name, mobile, hairline. No gradient avatar art.
class _DrawerQuietHeader extends StatelessWidget {
  const _DrawerQuietHeader();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final name = _drawerDisplayName();
    final mobile = _drawerDisplayMobile();
    final initials = _drawerInitials(name);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topInset + 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'C2S',
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.surface,
                foregroundColor: scheme.onSurface,
                child: Text(
                  initials,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mobile,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.onSurface.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

String _drawerDisplayName() {
  final userName = AppManager.instance.getString(ManagerKey.userName);
  final name = AppManager.instance.getString(ManagerKey.name);
  if (name.isNotEmpty && name != '0') return name;
  if (userName.isNotEmpty && userName != '0') return userName;
  return SessionRole.roleLabel;
}

String _drawerDisplayMobile() {
  final mobile = AppManager.instance.getString(ManagerKey.mobile);
  if (mobile.isNotEmpty && mobile != '0') return mobile;
  return 'No mobile available';
}

String _drawerInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final s = parts.first;
    return s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
  }
  return ('${parts.first[0]}${parts.last[0]}').toUpperCase();
}

class _DrawerNavTile extends StatelessWidget {
  const _DrawerNavTile({
    required this.icon,
    required this.title,
    required this.route,
    required this.isSelected,
  });

  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final cts = context.cts;
    final fg = scheme.onSurface;
    final selectedBg = scheme.surface;

    return Material(
      color: isSelected ? selectedBg : Colors.transparent,
      child: InkWell(
        onTap: () {
          final scaffoldState = Scaffold.maybeOf(context);
          if (scaffoldState?.isDrawerOpen ?? false) {
            Navigator.of(context).pop();
          }
          if (ModalRoute.of(context)?.settings.name != route) {
            context.push(route);
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 3,
                  color: isSelected ? cts.navy : Colors.transparent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 22,
                          color: isSelected
                              ? cts.navy
                              : fg.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isSelected ? cts.navy : fg,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerLogoutTile extends StatelessWidget {
  const _DrawerLogoutTile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: scheme.onSurface.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 4),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final scaffoldState = Scaffold.maybeOf(context);
                if (scaffoldState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }

                final signInProvider = Provider.of<SignInProvider>(
                  context,
                  listen: false,
                );

                try {
                  await signInProvider.logout();
                } catch (_) {}

                if (!context.mounted) return;
                ControllerResetUtil.resetAllControllers(context);
                await context.read<SessionAuthNotifier>().refresh();
                if (!context.mounted) return;
                context.go(RouteName.signIn);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      size: 22,
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Logout',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Consumer<SyncManager>(
      builder: (context, sync, _) {
        if (!sync.hasPendingWork && sync.failedCount == 0) {
          return const SizedBox.shrink();
        }

        final hasFailures = sync.failedCount > 0;
        final accent = hasFailures ? scheme.error : scheme.secondary;
        final label = hasFailures
            ? '${sync.pendingCount} pending · ${sync.failedCount} failed'
            : '${sync.pendingCount} change${sync.pendingCount == 1 ? '' : 's'} waiting to sync';

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                hasFailures
                    ? Icons.sync_problem_outlined
                    : Icons.cloud_upload_outlined,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (sync.isSyncing)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accent,
                  ),
                )
              else
                TextButton(
                  onPressed: () => sync.syncPending(),
                  style: TextButton.styleFrom(
                    foregroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Sync now'),
                ),
            ],
          ),
        );
      },
    );
  }
}
