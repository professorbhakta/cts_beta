import 'package:cts/appManager/colors.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/models/return_batch_status_model.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:flutter/material.dart';

/// Return batch picker tile — fixed height, no nested scroll.
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: compact ? EdgeInsets.zero : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BatchHeader(batch: batch, status: status),
              SizedBox(height: compact ? 8 : 12),
              InfoRow(
                icon: Icons.assignment_return,
                label: 'Return Time',
                value: batch.returnTime?.substring(0, 5) ?? 'N/A',
              ),
              InfoRow(
                icon: Icons.people,
                label: 'Available',
                value: status != null ? '${status!.availableCount}' : '…',
              ),
              InfoRow(
                icon: Icons.event_seat,
                label: 'Seats left',
                value: status != null
                    ? '${status!.remainingCapacity}/${status!.totalCapacity}'
                    : '…',
              ),
              InfoRow(
                icon: Icons.check_circle_outline,
                label: 'Confirmed',
                value: status != null ? '${status!.confirmedCount}' : '…',
              ),
              if (status?.hasPoolExtras == true) ...[
                InfoRow(
                  icon: Icons.home_outlined,
                  label: 'Home hold',
                  value: '${status!.homeHold}',
                ),
                InfoRow(
                  icon: Icons.swap_horiz,
                  label: 'Overflow in',
                  value: '${status!.overflowConfirmed}',
                ),
                InfoRow(
                  icon: Icons.airline_seat_recline_normal,
                  label: 'Overflow open',
                  value: '${status!.overflowRemaining}',
                ),
                if (status!.cutoffApplied)
                  const InfoRow(
                    icon: Icons.timer_off_outlined,
                    label: 'Cutoff',
                    value: 'Holds released (T−15)',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchHeader extends StatelessWidget {
  const _BatchHeader({required this.batch, required this.status});

  final BatchModel batch;
  final ReturnBatchStatusModel? status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                batch.batchName ?? 'N/A',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (batch.driver?.userId?.username != null &&
                  batch.driver!.userId!.username!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  batch.driver!.userId!.username!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        if (status?.isActive == true)
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.acGreen,
              shape: BoxShape.circle,
            ),
          )
        else
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
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
    return anyPoolExtras ? 0.52 : 0.72;
  }
}
