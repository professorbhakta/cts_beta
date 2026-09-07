import 'package:cts/theme/cts_colors.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:flutter/material.dart';

/// Return batch picker tile — cream hairline card (admin picker mock).
class ReturnBatchPickerCard extends StatelessWidget {
  const ReturnBatchPickerCard({
    super.key,
    required this.batch,
    required this.status,
    required this.onTap,
    this.compact = false,
  });

  final BatchModel batch;
  final ReturnBatchStatusModel? status;
  final VoidCallback? onTap;
  final bool compact;

  String get _driverLabel {
    final user = batch.driver?.userId;
    final full = [
      user?.firstName,
      user?.lastName,
    ].whereType<String>().where((n) => n.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    final username = user?.username;
    if (username != null && username.isNotEmpty) return username;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);
    final isLive = status?.isActive == true;
    final pad = compact ? 12.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hairline, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch.batchName ?? 'N/A',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cts.navy,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_driverLabel.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              _driverLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cts.navy.withValues(alpha: 0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(isLive: isLive),
                  ],
                ),
                SizedBox(height: compact ? 10 : 12),
                _MetricGrid(
                  returnTime: batch.returnTime?.length != null &&
                          (batch.returnTime!.length >= 5)
                      ? batch.returnTime!.substring(0, 5)
                      : (batch.returnTime ?? 'N/A'),
                  available: status != null ? '${status!.availableCount}' : '…',
                  seatsLeft: status != null
                      ? '${status!.remainingCapacity}/${status!.totalCapacity}'
                      : '…',
                  confirmed:
                      status != null ? '${status!.confirmedCount}' : '…',
                ),
                if (status?.hasPoolExtras == true) ...[
                  SizedBox(height: compact ? 10 : 12),
                  Divider(height: 1, thickness: 1, color: hairline),
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    [
                      'Home hold ${status!.homeHold}',
                      'Overflow in ${status!.overflowConfirmed}',
                      'Overflow open ${status!.overflowRemaining}',
                      if (status!.cutoffApplied) 'Cutoff T-15',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cts.navy.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    if (isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: cts.navy,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'LIVE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: hairline, width: 1),
      ),
      child: Text(
        'IDLE',
        style: theme.textTheme.labelSmall?.copyWith(
          color: cts.navy,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.returnTime,
    required this.available,
    required this.seatsLeft,
    required this.confirmed,
  });

  final String returnTime;
  final String available;
  final String seatsLeft;
  final String confirmed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCell(value: returnTime, label: 'Return time'),
            ),
            Expanded(
              child: _MetricCell(value: available, label: 'Available'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricCell(value: seatsLeft, label: 'Seats left'),
            ),
            Expanded(
              child: _MetricCell(value: confirmed, label: 'Confirmed'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

/// Picks list vs grid layout for the return batch picker.
class ReturnBatchPickerLayout {
  ReturnBatchPickerLayout._();

  static const double listLayoutMaxWidth = 400;

  static bool useListLayout({
    required double screenWidth,
    required bool anyPoolExtras,
  }) {
    return screenWidth < listLayoutMaxWidth || anyPoolExtras;
  }

  static double gridChildAspectRatio({required bool anyPoolExtras}) {
    // Width/height — lower = taller tiles for metric grid + optional extras.
    return anyPoolExtras ? 0.48 : 0.58;
  }
}
