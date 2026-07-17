import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/presentation/providers/commuter_home_provider.dart';
import 'package:cts/shared/widgets/app_drawer.dart';
import 'package:cts/shared/widgets/brand_app_bar.dart';
import 'package:cts/shared/widgets/confirmation_dialog.dart';
import 'package:cts/shared/widgets/loading_indicator.dart';
import 'package:cts/shared/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommuterHomePage extends StatefulWidget {
  const CommuterHomePage({super.key});

  @override
  State<CommuterHomePage> createState() => _CommuterHomePageState();
}

class _CommuterHomePageState extends State<CommuterHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommuterHomeProvider>().fetchCommuterProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () =>
              context.read<CommuterHomeProvider>().fetchCommuterProfile(),
          child: Consumer<CommuterHomeProvider>(
            builder: (context, provider, child) {
              if (provider.state == ViewState.loading) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200, child: LoadingIndicator()),
                  ],
                );
              } else if (provider.state == ViewState.error) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    StatusMessage.error(
                      title: provider.errorMessage ?? 'An error occurred',
                      onRetry: () => provider.fetchCommuterProfile(),
                    ),
                  ],
                );
              } else if (provider.commuterProfile == null) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    StatusMessage(
                      icon: Icons.person_outline,
                      title: 'Could not load your profile.',
                      message: 'Pull to refresh.',
                    ),
                  ],
                );
              }
              return _buildContent(context, provider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CommuterHomeProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final commuter = provider.commuterProfile!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hey, ${commuter.userId?.username ?? 'Commuter'}',
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 12),
        Card(
          color: scheme.inverseSurface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMEd().format(DateTime.now()),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onInverseSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Switch(
                  value: commuter.isComing ?? false,
                  onChanged: provider.isUpdating
                      ? null
                      : (newValue) {
                          _showConfirmationDialog(
                            context,
                            provider,
                            newValue,
                          );
                        },
                ),
              ],
            ),
          ),
        ),
        if (provider.isUpdating)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LoadingIndicator(),
          ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    CommuterHomeProvider provider,
    bool newValue,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const ConfirmationDialog(
        title: 'Confirm Change',
        message: 'Are you sure you want to update your status?',
        confirmLabel: 'CONFIRM',
        cancelLabel: 'CANCEL',
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await provider.updateIsComing(newValue);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Status updated')),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update status',
          ),
        ),
      );
    }
  }
}
