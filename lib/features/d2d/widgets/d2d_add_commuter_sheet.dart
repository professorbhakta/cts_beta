import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/features/commuters/repositories/commuter_repository.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Bottom sheet for admin to manually add commuters to the live D2D list.
///
/// Loads all commuters for the logged-in admin via
/// `GET user/admin/commuter/{adminCode}` (same as the main Commuters screen).
class D2dAddCommuterSheet extends StatefulWidget {  const D2dAddCommuterSheet({
    super.key,
    required this.batchId,
    required this.d2dProvider,
    required this.liveCommuterIds,
  });

  final String batchId;
  final D2dChannelProvider d2dProvider;
  final Set<int> liveCommuterIds;

  static Future<void> show(
    BuildContext context, {
    required String batchId,
    required D2dChannelProvider d2dProvider,
    required Set<int> liveCommuterIds,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => D2dAddCommuterSheet(
        batchId: batchId,
        d2dProvider: d2dProvider,
        liveCommuterIds: liveCommuterIds,
      ),
    );
  }

  @override
  State<D2dAddCommuterSheet> createState() => _D2dAddCommuterSheetState();
}

class _D2dAddCommuterSheetState extends State<D2dAddCommuterSheet> {
  ViewState _state = ViewState.loading;
  String? _errorMessage;
  List<CommuterModel> _commuters = [];

  @override
  void initState() {
    super.initState();
    _loadCommuters();
  }

  Future<void> _loadCommuters() async {
    setState(() {
      _state = ViewState.loading;
      _errorMessage = null;
    });

    final result = await context.read<CommuterRepository>().getCommuters();

    if (!mounted) return;

    if (result.isSuccess) {
      final available = (result.data ?? []).where((commuter) {
        final id = commuter.userId?.id;
        return id != null && !widget.liveCommuterIds.contains(id);
      }).toList();

      _commuters = sortListAZMultiple<CommuterModel>(available, [
        (commuter) => commuter.userId?.username ?? '',
        (commuter) => commuter.userId?.mobileNumber ?? '',
      ]);
      _state = ViewState.success;
    } else {
      _errorMessage = result.failure?.message;
      _state = ViewState.error;
    }

    setState(() {});
  }

  void _addCommuter(CommuterModel commuter) {
    final id = commuter.userId?.id;
    if (id == null) return;

    widget.d2dProvider.addCommuter(id.toString());
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${commuter.userId?.username ?? 'Commuter'} added to live list',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.65;

    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add Commuter',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                'All commuters — tap + to add to batch #${widget.batchId} live channel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),              const SizedBox(height: 16),
              Expanded(
                child: switch (_state) {
                  ViewState.loading => const LoadingIndicator(),
                  ViewState.error => StatusMessage.error(
                      title: _errorMessage ?? 'Failed to load commuters',
                      onRetry: _loadCommuters,
                    ),
                  _ when _commuters.isEmpty => const StatusMessage(
                      icon: Icons.people_outline,
                      title: 'No commuters available to add',
                      message:
                          'Everyone in this batch is already on the live list.',
                    ),
                  _ => ListView.separated(
                      itemCount: _commuters.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final commuter = _commuters[index];
                        final name =
                            commuter.userId?.username ?? 'Unknown commuter';
                        final pop = commuter.popId?.pickUpPointName ??
                            'No pick-up point';

                        return ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: AppColors.acYellowWarm.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          tileColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          leading: CircleAvatar(
                            backgroundColor:
                                AppColors.acYellowWarm.withValues(alpha: 0.2),
                            child: Text(
                              '${commuter.userId?.id ?? '?'}',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(pop),
                          trailing: IconButton(
                            tooltip: 'Add to live list',
                            onPressed: () => _addCommuter(commuter),
                            icon: Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.acGreen,
                            ),
                          ),
                        );
                      },
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
