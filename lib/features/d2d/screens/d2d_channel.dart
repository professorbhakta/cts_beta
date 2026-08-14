import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/admin_home/providers/admin_provider.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/widgets/d2d_action_error_listener.dart';
import 'package:cts/features/d2d/widgets/d2d_add_commuter_sheet.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class D2dChannel extends StatefulWidget {
  final String batchId;
  const D2dChannel({super.key, required this.batchId});

  @override
  State<D2dChannel> createState() => _D2dChannelState();
}

class _D2dChannelState extends State<D2dChannel> {
  D2dChannelProvider? _d2dProvider;
  bool _didSyncAfterTripEnd = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<D2dChannelProvider>();
    attachD2dActionErrorListener(
      current: _d2dProvider,
      next: provider,
      listener: _onD2dProviderChanged,
    );
    _d2dProvider = provider;
  }

  void _onD2dProviderChanged() {
    if (!mounted) return;
    handleD2dActionError(context, _d2dProvider);
    _syncRunningListIfTripEnded();
  }

  void _syncRunningListIfTripEnded() {
    if (_didSyncAfterTripEnd) return;
    if (_d2dProvider?.isTripEnded != true) return;
    _didSyncAfterTripEnd = true;
    context.read<RunningBatchProvider>().fetchOnce();
    context.read<AdminProvider>().refreshRunningBatches();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _d2dProvider?.connect(widget.batchId);
    });
  }

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
  }

  void _closeChannel() {
    _d2dProvider?.disconnect(notify: false);
    Navigator.of(context).pop();
  }

  Future<void> _callDriver(D2dChannelProvider provider) async {
    final mobile = provider.driverMobile;
    if (mobile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver contact is not available for this batch yet.'),
        ),
      );
      return;
    }

    final launched = await calling(mobile);
    if (!mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fabPadding = d2dFabScrollPadding(context);

    return DashboardShell(
      title: 'D2D Channel',
      fab: FloatingActionButton.extended(
        onPressed: _closeChannel,
        backgroundColor: AppColors.acRed,
        foregroundColor: AppColors.acWhite,
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
                  title: provider.errorMessage ?? 'Unable to connect to channel.',
                  onRetry: provider.isTripEnded
                      ? null
                      : () => provider.connect(widget.batchId),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go back'),
                ),
              ],
            );
          }

          final isLive = provider.commuters.isNotEmpty;
          final driverName = provider.driverName;
          final liveCommuterIds = provider.commuters
              .map((commuter) => commuter.id)
              .whereType<int>()
              .toSet();

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(0, 8, 0, fabPadding + 72),
                children: [
              D2dTripHeader(
                title: 'Currently Running',
                subtitle: driverName != null && driverName.isNotEmpty
                    ? 'Batch #${widget.batchId} · $driverName'
                    : 'Batch #${widget.batchId}',
                isLive: isLive,
              ),
              const SizedBox(height: 16),
              D2dLiveControlsBar(
                callLabel: driverName != null && driverName.isNotEmpty
                    ? 'Call $driverName'
                    : 'Call Driver',
                onCall: () => _callDriver(provider),
                isLive: isLive,
                isAscending: provider.isAscending,
                onToggleSort: provider.toggleSortOrder,
              ),
              const SizedBox(height: 16),
              if (provider.commuters.isEmpty)
                const StatusMessage(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'Waiting for commuter data...',
                  message: 'Live riders will appear here shortly.',
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${provider.commuters.length} commuter${provider.commuters.length == 1 ? '' : 's'} on board',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                for (var i = 0; i < provider.commuters.length; i++) ...[
                  D2dAdminCommuterTile(
                    commuter: provider.commuters[i],
                    provider: provider,
                    onCall: () {
                      final mobile = provider.commuters[i].mobileNumber;
                      if (mobile != null && mobile.isNotEmpty) {
                        calling(mobile);
                      }
                    },
                  ),
                  if (i < provider.commuters.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ],
              ),
              Positioned(
                right: 16,
                bottom: fabPadding,
                child: FloatingActionButton(
                  heroTag: 'd2dAddCommuter',
                  tooltip: 'Add commuter',
                  backgroundColor: AppColors.acYellowWarm,
                  foregroundColor: AppColors.acBlack,
                  onPressed: () => D2dAddCommuterSheet.show(
                    context,
                    batchId: widget.batchId,
                    d2dProvider: provider,
                    liveCommuterIds: liveCommuterIds,
                  ),
                  child: const Icon(Icons.person_add_rounded),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
