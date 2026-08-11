import 'package:cts/appManager/app_class.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/controller_reset_util.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/core/sync/sync_manager.dart';
import 'package:cts/offline_temp/screens/offline_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Drawer(
      backgroundColor: Colors.transparent,
      child: AdminNavList(),
    );
  }
}

class AdminNavList extends StatelessWidget {
  const AdminNavList({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    final isAdmin = SessionRole.isAdmin;
    final homeRoute = SessionRole.homeRoute;

    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.acBlack, AppColors.acBlackLight],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Header — top padding respects notch / Dynamic Island / status bar
          Container(
            padding: EdgeInsets.fromLTRB(20, topInset + 16, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.acYellowWarm, AppColors.acYellowBright],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.acYellowWarm.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.acWhite.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.acBlack.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/driver.png'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getDisplayName(),
                  style: const TextStyle(
                    color: AppColors.acWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDisplayMobile(),
                  style: TextStyle(
                    color: AppColors.acWhite.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Navigation Items
          _navTile(
            context,
            icon: isAdmin
                ? Icons.dashboard_customize_rounded
                : Icons.home_rounded,
            title: isAdmin ? 'Dashboard' : 'Home',
            route: homeRoute,
            color: AppColors.acYellowWarm,
            isSelected: currentRoute == homeRoute,
          ),
          _navTile(
            context,
            icon: Icons.person_rounded,
            title: 'Profile',
            route: RouteName.profileScreen,
            color: AppColors.acYellowBright,
            isSelected: currentRoute == RouteName.profileScreen,
          ),

          if (isAdmin) ...[
            _syncStatusBanner(context),
            const SizedBox(height: 8),

            // Section Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                'MANAGEMENT',
                style: TextStyle(
                  color: AppColors.acYellowBright.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            _navTile(
              context,
              icon: Icons.people_alt_rounded,
              title: 'Commuters',
              route: RouteName.commuterScreen,
              color: AppColors.acYellowWarm,
              isSelected: currentRoute == RouteName.commuterScreen,
            ),
            _navTile(
              context,
              icon: Icons.location_on_rounded,
              title: 'Pick-up Points',
              route: RouteName.popScreen,
              color: AppColors.acYellowDark,
              isSelected: currentRoute == RouteName.popScreen,
            ),
            _navTile(
              context,
              icon: Icons.directions_bus_rounded,
              title: 'Batches',
              route: RouteName.batchScreen,
              color: AppColors.acYellowBright,
              isSelected: currentRoute == RouteName.batchScreen,
            ),
            _navTile(
              context,
              icon: Icons.directions_car_rounded,
              title: 'Cabs',
              route: RouteName.cabScreen,
              color: AppColors.acYellowWarm,
              isSelected: currentRoute == RouteName.cabScreen,
            ),
            _navTile(
              context,
              icon: Icons.person_outline_rounded,
              title: 'Drivers',
              route: RouteName.driverScreen,
              color: AppColors.acYellowDark,
              isSelected: currentRoute == RouteName.driverScreen,
            ),
            _navTile(
              context,
              icon: Icons.route_rounded,
              title: 'Routes',
              route: RouteName.routeScreen,
              color: AppColors.acYellowBright,
              isSelected: currentRoute == RouteName.routeScreen,
            ),

            if (showOfflineDrawerTile()) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(
                  'OFFLINE',
                  style: TextStyle(
                    color: AppColors.acYellowBright.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              _navTile(
                context,
                icon: Icons.cloud_off_rounded,
                title: 'Offline Mode',
                route: RouteName.offlineTempHome,
                color: Colors.tealAccent.shade400,
                isSelected: currentRoute == RouteName.offlineTempHome,
              ),
            ],
          ],

          const SizedBox(height: 16),

          // Divider
          const Divider(
            color: AppColors.acBlackLighter,
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          const SizedBox(height: 8),

          // Logout Button
          _logoutTile(context),
        ],
      ),
    );
  }

  String _getDisplayName() {
    final userName = AppManager.instance.getString(ManagerKey.userName);
    final name = AppManager.instance.getString(ManagerKey.name);

    // Prefer name over userName, fallback to role label if both are empty
    if (name.isNotEmpty && name != '0') {
      return name;
    } else if (userName.isNotEmpty && userName != '0') {
      return userName;
    } else {
      return SessionRole.roleLabel;
    }
  }

  String _getDisplayMobile() {
    final mobile = AppManager.instance.getString(ManagerKey.mobile);

    // Return mobile if available, otherwise show a placeholder
    if (mobile.isNotEmpty && mobile != '0') {
      return mobile;
    } else {
      return 'No mobile available';
    }
  }

  Widget _syncStatusBanner(BuildContext context) {
    return Consumer<SyncManager>(
      builder: (context, sync, _) {
        if (!sync.hasPendingWork && sync.failedCount == 0) {
          return const SizedBox.shrink();
        }

        final hasFailures = sync.failedCount > 0;
        final accent = hasFailures ? AppColors.acRed : AppColors.acYellowBright;
        final label = hasFailures
            ? '${sync.pendingCount} pending · ${sync.failedCount} failed'
            : '${sync.pendingCount} change${sync.pendingCount == 1 ? '' : 's'} waiting to sync';

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(
                hasFailures ? Icons.sync_problem_rounded : Icons.cloud_upload_rounded,
                color: accent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.acWhite.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required Color color,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: color.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final scaffoldState = Scaffold.maybeOf(context);
            final isDrawerOpen = scaffoldState?.isDrawerOpen ?? false;
            if (isDrawerOpen) {
              Navigator.of(context).pop();
            }
            if (ModalRoute.of(context)?.settings.name != route) {
              context.push(route);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.3)
                        : color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? color : color.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.acWhite
                          : AppColors.acWhite.withValues(alpha: 0.85),
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.chevron_right_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.acRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.acRed.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final scaffoldState = Scaffold.maybeOf(context);
            final isDrawerOpen = scaffoldState?.isDrawerOpen ?? false;
            if (isDrawerOpen) {
              Navigator.of(context).pop();
            }

            final signInProvider = Provider.of<SignInProvider>(
              context,
              listen: false,
            );

            try {
              await signInProvider.logout();
            } catch (_) {
              // Continue with reset/navigation even if logout fails.
            }

            if (!context.mounted) return;
            ControllerResetUtil.resetAllControllers(context);
            await context.read<SessionAuthNotifier>().refresh();
            if (!context.mounted) return;
            context.go(RouteName.signIn);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.acRed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: AppColors.acRed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: AppColors.acRed,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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

