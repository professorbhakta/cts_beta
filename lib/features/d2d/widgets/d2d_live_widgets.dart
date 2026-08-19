import 'package:cts/appManager/colors.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Shown when the WebSocket dropped but stale rider data is still visible.
class D2dConnectionLostBanner extends StatelessWidget {
  const D2dConnectionLostBanner({
    super.key,
    required this.provider,
    required this.batchId,
  });

  final D2dChannelProvider provider;
  final String batchId;

  @override
  Widget build(BuildContext context) {
    if (!provider.connectionLost || provider.isTripEnded) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final message = provider.errorMessage ?? 'Live connection lost. Reconnecting…';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                color: theme.colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => provider.connect(batchId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class D2dTripHeader extends StatelessWidget {
  const D2dTripHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isLive = false,
  });

  final String title;
  final String? subtitle;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminFormHeader(
          icon: Icons.directions_bus_filled_rounded,
          title: title,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.acYellowWarm.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  color: AppColors.acYellowWarm,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtitle!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _LiveStatusChip(isLive: isLive),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LiveStatusChip extends StatelessWidget {
  const _LiveStatusChip({required this.isLive});

  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final color = isLive ? AppColors.acGreen : AppColors.acRed;
    final label = isLive ? 'LIVE' : 'WAITING';

    return Semantics(
      label: isLive ? 'Trip live' : 'Waiting for commuters',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
        ),
      ),
    );
  }
}

class D2dLiveControlsBar extends StatelessWidget {
  const D2dLiveControlsBar({
    super.key,
    required this.callLabel,
    required this.onToggleSort,
    required this.isAscending,
    required this.isLive,
    this.onCall,
  });

  final String callLabel;
  final VoidCallback? onCall;
  final VoidCallback onToggleSort;
  final bool isAscending;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text(callLabel),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: isLive ? 'Connection live' : 'Connection waiting',
            child: Icon(
              Icons.circle,
              size: 12,
              color: isLive ? AppColors.acGreen : AppColors.acRed,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onToggleSort,
            icon: const Icon(Icons.sort_rounded, size: 18),
            label: Text(isAscending ? 'Asc' : 'Desc'),
          ),
        ],
      ),
    );
  }
}

class D2dDriverCommuterTile extends StatelessWidget {
  const D2dDriverCommuterTile({
    super.key,
    required this.commuter,
    required this.provider,
    required this.onCall,
  });

  final D2dCommuterModel commuter;
  final D2dChannelProvider provider;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final commuterId = commuter.id?.toString();

    return Slidable(
      key: ValueKey(commuterId ?? commuter.inLine ?? commuter.hashCode),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              if (commuterId != null) {
                provider.denyCommuter(commuterId);
              }
            },
            backgroundColor: AppColors.acRed,
            foregroundColor: AppColors.acWhite,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            flex: 1,
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              if (commuterId != null) {
                provider.confirmCommuter(commuterId);
              }
            },
            backgroundColor: AppColors.acGreen,
            foregroundColor: AppColors.acWhite,
            icon: Icons.check_circle_rounded,
            label: 'Picked up',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            flex: 1,
          ),
        ],
      ),
      child: ModernListCard(
        title: commuter.username,
        subtitle: 'Stop #${commuter.inLine ?? '?'}',
        icon: Icons.person_rounded,
        iconColor: AppColors.acYellowWarm,
        trailing: IconButton(
          tooltip: 'Call commuter',
          onPressed: onCall,
          icon: Icon(
            Icons.call_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        children: [
          InfoRow(
            icon: Icons.location_on_rounded,
            label: 'POP:',
            value: commuter.popId?.pickUpPointName ?? 'N/A',
            iconColor: AppColors.acBlue,
          ),
          if (commuter.mobileNumber?.isNotEmpty ?? false)
            InfoRow(
              icon: Icons.phone_android_rounded,
              label: 'Mobile:',
              value: commuter.mobileNumber,
              iconColor: AppColors.acYellowDark,
            ),
        ],
      ),
    );
  }
}

class D2dAdminCommuterTile extends StatelessWidget {
  const D2dAdminCommuterTile({
    super.key,
    required this.commuter,
    required this.provider,
    required this.onCall,
  });

  final D2dCommuterModel commuter;
  final D2dChannelProvider provider;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final commuterId = commuter.id?.toString();

    return Slidable(
      key: ValueKey(commuterId ?? commuter.inLine ?? commuter.hashCode),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              if (commuterId != null) {
                provider.removeCommuter(commuterId);
              }
            },
            backgroundColor: AppColors.acRed,
            foregroundColor: AppColors.acWhite,
            icon: Icons.delete_rounded,
            label: 'Delete',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            flex: 1,
          ),
        ],
      ),
      child: ModernListCard(
        title: commuter.username,
        subtitle: 'ID ${commuter.id ?? '?'}',
        icon: Icons.person_rounded,
        iconColor: AppColors.acYellowWarm,
        trailing: IconButton(
          tooltip: 'Call commuter',
          onPressed: onCall,
          icon: Icon(
            Icons.call_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        children: [
          InfoRow(
            icon: Icons.location_on_rounded,
            label: 'POP:',
            value: commuter.popId?.pickUpPointName ?? 'N/A',
            iconColor: AppColors.acBlue,
          ),
          InfoRow(
            icon: Icons.format_list_numbered_rounded,
            label: 'Stop #:',
            value: commuter.inLine?.toString() ?? 'N/A',
            iconColor: AppColors.acYellowDark,
          ),
        ],
      ),
    );
  }
}
