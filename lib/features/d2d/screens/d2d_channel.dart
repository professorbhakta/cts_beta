import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/no_data_found.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class D2dChannel extends StatefulWidget {
  final String batchId;
  const D2dChannel({super.key, required this.batchId});

  @override
  State<D2dChannel> createState() => _D2dChannelState();
}

class _D2dChannelState extends State<D2dChannel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<D2dChannelProvider>().connect(widget.batchId);
    });
  }

  @override
  void dispose() {
    final provider = context.read<D2dChannelProvider>();
    provider.disconnect();
    super.dispose();
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _closeChannel() {
    context.read<D2dChannelProvider>().disconnect();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fabPadding = d2dFabScrollPadding(context);

    return DashboardShell(
      title: 'D2D Channel',
      fab: FloatingActionButton.extended(
        onPressed: _closeChannel,
        backgroundColor: AppColors.acRed,
        icon: const Icon(Icons.close_rounded),
        label: const Text('Close channel'),
      ),
      child: Consumer<D2dChannelProvider>(
        builder: (context, provider, child) {
          if (provider.state == ViewState.loading) {
            return const LoadingIndicator(height: 280);
          }

          if (provider.state == ViewState.error) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusMessage.error(
                  title: 'Connection failed',
                  message: provider.errorMessage ?? 'Unable to connect to channel.',
                  onRetry: () => provider.connect(widget.batchId),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ],
            );
          }

          if (provider.commuters.isEmpty) {
            return const NoDataFound(
              message: 'Waiting for commuter data...',
            );
          }

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(0, 8, 0, fabPadding),
            itemCount: provider.commuters.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Divider(color: Theme.of(context).colorScheme.outlineVariant);
              }
              if (index == 1) {
                return Column(
                  children: [
                    Text(
                      'Currently Running',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildControls(context, provider),
                    Divider(color: Theme.of(context).colorScheme.outlineVariant),
                  ],
                );
              }

              final commuter = provider.commuters[index - 2];
              return _buildCommuterTile(context, provider, commuter);
            },
          );
        },
      ),
    );
  }

  Widget _buildControls(BuildContext context, D2dChannelProvider provider) {
    final isLive = provider.commuters.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: provider.driver?.userId?.mobileNumber != null
                ? () => _makePhoneCall(provider.driver!.userId!.mobileNumber)
                : null,
            icon: const Icon(Icons.call),
            label: const Text('Call Driver'),
          ),
          Semantics(
            label: isLive ? 'Channel live' : 'Channel offline',
            child: Icon(
              Icons.circle,
              color: isLive ? AppColors.acGreen : AppColors.acRed,
              semanticLabel: isLive ? 'Live' : 'Offline',
            ),
          ),
          ElevatedButton.icon(
            onPressed: provider.toggleSortOrder,
            icon: const Icon(Icons.sort),
            label: Text(provider.isAscending ? 'Asc' : 'Desc'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommuterTile(
    BuildContext context,
    D2dChannelProvider provider,
    D2dCommuterModel commuter,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final onCard = scheme.onSurface;

    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (commuter.userId?.id != null) {
                provider.removeCommuter(commuter.userId!.id.toString());
              }
            },
            backgroundColor: AppColors.acRed,
            icon: Icons.remove_circle_outline,
            label: 'REMOVE',
          ),
        ],
      ),
      child: Card(
        color: AppColors.acBlackLighter,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.acYellowWarm,
            child: Text(
              commuter.userId?.id.toString() ?? '?',
              style: TextStyle(
                color: AppColors.acBlack,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            commuter.userId?.username ?? 'N/A',
            style: TextStyle(
              color: onCard,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                commuter.popId?.pickUpPointName ?? 'N/A',
                style: TextStyle(color: onCard.withValues(alpha: 0.7)),
              ),
              Text(
                'SORT: ${commuter.inLine ?? 0}',
                style: TextStyle(color: onCard.withValues(alpha: 0.7)),
              ),
            ],
          ),
          trailing: IconButton(
            tooltip: 'Call commuter',
            onPressed: () => _makePhoneCall(commuter.userId?.mobileNumber),
            icon: Icon(Icons.call, color: scheme.primary, size: 24),
          ),
        ),
      ),
    );
  }
}
