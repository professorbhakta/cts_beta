import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/appManager/controller_reset_util.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/features/profile/providers/profile_provider.dart';
import 'package:cts/widgets/confirmation_dialog.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/provider_listener.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().load();
    });
  }

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

  Future<void> _confirmLogout(SignInProvider signInProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return ConfirmationDialog(
          title: 'Log out?',
          message: 'You will need to sign in again to continue.',
          confirmLabel: 'Logout',
          confirmColor: scheme.error,
          icon: Icons.logout,
          iconColor: scheme.error,
        );
      },
    );
    if (confirmed == true && mounted) {
      signInProvider.logout();
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
        child: Consumer<ProfileProvider>(
          builder: (context, profile, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
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
                            profile.name,
                          ),
                          const Divider(),
                          _buildProfileRow(
                            context,
                            Icons.phone,
                            'Mobile',
                            profile.mobile,
                          ),
                          const Divider(),
                          _buildProfileRow(
                            context,
                            Icons.badge_outlined,
                            'Role',
                            profile.roleLabel,
                          ),
                          if (profile.showAssignment) ...[
                            const Divider(),
                            _buildProfileRow(
                              context,
                              Icons.event_note,
                              'Batch',
                              profile.batchName,
                            ),
                            const Divider(),
                            _buildProfileRow(
                              context,
                              Icons.access_time,
                              'Time',
                              profile.batchTime,
                            ),
                            const Divider(),
                            _buildProfileRow(
                              context,
                              Icons.directions_car,
                              'Cab',
                              profile.cabNumber,
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
                          : () => _confirmLogout(signInProvider),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
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
