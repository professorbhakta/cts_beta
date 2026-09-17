import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
import 'package:cts/features/d2d/models/odometer_models.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/repositories/d2d_repository.dart';
import 'package:cts/features/d2d/widgets/boarding_qr_panel.dart';
import 'package:cts/features/d2d/widgets/d2d_add_commuter_sheet.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/features/d2d/widgets/odometer_km_sheet.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';

/// Shared cream stacked live-trip body used by Admin channel + Driver log.
///
/// Screens stay separate; this widget is the shared composition surface.
/// Admin Add stays on the channel FAB (`showAddCommuter: false` there).
class D2dCreamTripBody extends StatefulWidget {
  const D2dCreamTripBody({
    super.key,
    required this.batchId,
    required this.provider,
    required this.batchLabel,
    required this.onCallCommuter,
    required this.membership,
    this.showQr = false,
    this.qrKey,
    this.onRefreshQr,
    this.showAddCommuter = false,
    this.showStartKmAction = false,
    this.bottomPadding = 88,
  });

  final String batchId;
  final D2dChannelProvider provider;
  final String batchLabel;
  final void Function(String? mobile) onCallCommuter;
  final D2dBatchMembership membership;
  final bool showQr;
  final GlobalKey<BoardingQrPanelState>? qrKey;
  final VoidCallback? onRefreshQr;
  final bool showAddCommuter;
  final bool showStartKmAction;
  final double bottomPadding;

  @override
  State<D2dCreamTripBody> createState() => _D2dCreamTripBodyState();
}

class _D2dCreamTripBodyState extends State<D2dCreamTripBody> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isOther(D2dCommuterModel c) => widget.membership.isOtherBatch(
        c.id,
        widget.batchId,
        knownHomeBatchId: c.homeBatchId,
      );

  List<D2dCommuterModel> _filteredRemaining(List<D2dCommuterModel> remaining) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return remaining;
    return remaining.where((c) {
      final haystack = [
        c.username,
        c.mobileNumber,
        c.popId?.pickUpPointName,
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  String _tripStatusLabel(D2dTripStatus tripStatus) {
    switch (tripStatus) {
      case D2dTripStatus.active:
        return 'TRIP ACTIVE';
      case D2dTripStatus.ended:
        return 'TRIP ENDED';
      case D2dTripStatus.none:
      case D2dTripStatus.unknown:
        return '';
    }
  }

  void _openAddCommuter() {
    final liveCommuterIds =
        widget.provider.commuters.map((c) => c.id).whereType<int>().toSet();
    final alreadyInIds = widget.provider.alreadyInCommuters
        .map((c) => c.id)
        .whereType<int>()
        .toSet();
    D2dAddCommuterSheet.show(
      context,
      batchId: widget.batchId,
      d2dProvider: widget.provider,
      liveCommuterIds: liveCommuterIds,
      alreadyInCommuterIds: alreadyInIds,
    );
  }

  Future<void> _openStartKm() async {
    await OdometerKmSheet.show(
      context,
      batchId: widget.batchId,
      mode: OdometerSheetMode.start,
      leg: OdometerLeg.morning,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final theme = Theme.of(context);
    final provider = widget.provider;
    final tripLabel = _tripStatusLabel(provider.tripStatus);
    final qrEnabled = widget.showQr &&
        !provider.isTripEnded &&
        provider.tripStatus != D2dTripStatus.ended;
    final canAdd = widget.showAddCommuter &&
        D2dChannelRolePolicy.can(
          SessionRole.userType,
          D2dChannelAction.addCommuter,
        );

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, widget.bottomPadding),
      children: [
        D2dConnectionLostBanner(
          provider: provider,
          batchId: widget.batchId,
        ),
        Text(
          tripLabel.isEmpty
              ? 'LIVE COMMUTER LOG'
              : 'LIVE COMMUTER LOG · $tripLabel',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                widget.batchLabel,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
            ),
            if (qrEnabled && widget.onRefreshQr != null)
              TextButton(
                onPressed: widget.onRefreshQr,
                style: TextButton.styleFrom(
                  foregroundColor: cts.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'QR refresh',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (widget.showStartKmAction) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openStartKm,
              icon: Icon(Icons.speed_outlined, color: cts.navy, size: 18),
              label: Text(
                'Start / edit KM',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        if (widget.showQr) ...[
          const SizedBox(height: 8),
          BoardingQrPanel(
            key: widget.qrKey,
            batchId: widget.batchId,
            compact: true,
            enabled: qrEnabled,
          ),
        ],
        const SizedBox(height: 12),
        D2dTripCountsRow(
          remainingCount: provider.commuters.length,
          waitingLineCount: provider.waitingCommuters.length,
          onBoardCount: provider.alreadyInCommuters.length,
          onWaitingLineTap: provider.waitingCommuters.isEmpty
              ? null
              : () => showD2dWaitingLineDialog(
                    context,
                    commuters: provider.waitingCommuters,
                    onCall: (c) => widget.onCallCommuter(c.mobileNumber),
                    isOtherBatch: _isOther,
                  ),
          onOnBoardTap: provider.alreadyInCommuters.isEmpty
              ? null
              : () => showD2dAlreadyInDialog(
                    context,
                    commuters: provider.alreadyInCommuters,
                    onCall: (c) => widget.onCallCommuter(c.mobileNumber),
                    isOtherBatch: _isOther,
                  ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Riders',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CreamRidersSearch(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              onPressed: provider.toggleSortOrder,
              icon: Icon(Icons.sort, color: cts.navy, size: 18),
              label: Text(
                provider.isAscending ? 'Asc' : 'Desc',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: cts.navy.withValues(alpha: 0.12),
        ),
        Builder(
          builder: (context) {
            final remaining = provider.commuters;
            final visible = _filteredRemaining(remaining);
            if (remaining.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: StatusMessage(
                  icon: Icons.hourglass_empty,
                  title: 'No riders waiting pickup',
                  message: 'Remaining commuters will appear here.',
                ),
              );
            }
            if (visible.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: StatusMessage(
                  icon: Icons.search_off,
                  title: 'No matches',
                  message: 'No remaining riders match “$_searchQuery”.',
                ),
              );
            }
            return Column(
              children: [
                for (var i = 0; i < visible.length; i++)
                  D2dDriverCommuterTile(
                    commuter: visible[i],
                    provider: provider,
                    onCall: () =>
                        widget.onCallCommuter(visible[i].mobileNumber),
                    showDivider: i < visible.length - 1,
                    isOtherBatch: _isOther(visible[i]),
                  ),
              ],
            );
          },
        ),
        if (canAdd) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openAddCommuter,
              icon: Icon(Icons.person_add_outlined, color: cts.navy, size: 18),
              label: Text(
                'Add commuter',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CreamRidersSearch extends StatelessWidget {
  const _CreamRidersSearch({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cts = context.cts;
    final idle = cts.navy.withValues(alpha: 0.2);

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Search',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: cts.navy.withValues(alpha: 0.35),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 18,
              color: cts.navy.withValues(alpha: 0.45),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: cts.navy.withValues(alpha: 0.45),
                    ),
                  ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: idle, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.primary, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        );
      },
    );
  }
}
