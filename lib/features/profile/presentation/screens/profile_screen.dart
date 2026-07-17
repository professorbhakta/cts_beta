import 'package:cts/appManager/app_class.dart' as app;
import 'package:cts/appManager/controller_reset_util.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/controllers/sign_up_sign_in_controller.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/provider_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _listenToLogoutState(BuildContext context, SignInProvider provider) {
    if (provider.state == ViewState.idle) {
      if (mounted) {
        ControllerResetUtil.resetAllControllers(context);
        context.read<SessionAuthNotifier>().refresh().then((_) {
          if (!context.mounted) return;
          context.go(RouteName.signIn);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = context.watch<SignInProvider>();

    return ProviderListener<SignInProvider>(
      provider: signInProvider,
      onChange: _listenToLogoutState,
      child: DashboardShell(
        title: 'Profile',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileRow(
                        context,
                        Icons.person,
                        'Name',
                        app.AppManager.instance.getString(
                          app.ManagerKey.userName,
                        ),
                      ),
                      const Divider(),
                      _buildProfileRow(
                        context,
                        Icons.phone,
                        'Mobile',
                        app.AppManager.instance.getString(
                          app.ManagerKey.mobile,
                        ),
                      ),
                      if (app.AppClass.userType == 1 ||
                          app.AppClass.userType == 2) ...[
                        const Divider(),
                        _buildProfileRow(
                          context,
                          Icons.event_note,
                          'Batch',
                          app.AppManager.instance.getString(
                            app.ManagerKey.batchName,
                          ),
                        ),
                      ],
                      if (app.AppClass.userType == 1 ||
                          app.AppClass.userType == 2) ...[
                        const Divider(),
                        _buildProfileRow(
                          context,
                          Icons.access_time,
                          'Time',
                          app.AppManager.instance.getString(
                            app.ManagerKey.batchTime,
                          ),
                        ),
                      ],
                      if (app.AppClass.userType == 1 ||
                          app.AppClass.userType == 2) ...[
                        const Divider(),
                        _buildProfileRow(
                          context,
                          Icons.directions_car,
                          'Cab',
                          app.AppManager.instance.getString(
                            app.ManagerKey.cabNumb,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: signInProvider.state == ViewState.loading
                      ? const CircularProgressIndicator()
                      : Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: signInProvider.state == ViewState.loading
                      ? null
                      : () {
                          signInProvider.logout();
                        },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

