import 'package:cts/theme/cts_colors.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/d2d/models/d2d_channel_role_policy.dart';
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
    final scheme = context.scheme;

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
                color: scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  color: scheme.primary,
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
    final scheme = context.scheme;
    final cts = context.cts;

    final color = isLive ? cts.success : scheme.error;
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
    final cts = context.cts;

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
              icon: Icon(Icons.call_rounded, size: 18),
              label: Text(callLabel),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: isLive ? 'Connection live' : 'Connection waiting',
            child: Icon(
              Icons.circle,
              size: 12,
              color: isLive ? cts.success : scheme.error,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onToggleSort,
            icon: Icon(Icons.sort_rounded, size: 18),
            label: Text(isAscending ? 'Asc' : 'Desc'),
          ),
        ],
      ),
    );
  }
}

class D2dAlreadyInSection extends StatelessWidget {
  const D2dAlreadyInSection({
    super.key,
    required this.commuters,
    this.onCall,
  });

  final List<D2dCommuterModel> commuters;
  final void Function(D2dCommuterModel commuter)? onCall;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;

    if (commuters.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 20,
              color: cts.success,
            ),
            const SizedBox(width: 8),
            Text(
              'Already IN (${commuters.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cts.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Confirmed in the cab — removed from the live queue.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < commuters.length; i++) ...[
          D2dAlreadyInTile(
            commuter: commuters[i],
            onCall: onCall == null
                ? null
                : () => onCall!(commuters[i]),
          ),
          if (i < commuters.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class D2dAlreadyInTile extends StatelessWidget {
  const D2dAlreadyInTile({
    super.key,
    required this.commuter,
    this.onCall,
  });

  final D2dCommuterModel commuter;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;

    return ModernListCard(
      title: commuter.username,
      subtitle: 'Picked up · Stop #${commuter.inLine ?? '?'}',
      icon: Icons.check_circle_outline_rounded,
      iconColor: cts.success,
      trailing: onCall == null
          ? null
          : IconButton(
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
          iconColor: cts.info,
        ),
        if (commuter.mobileNumber?.isNotEmpty ?? false)
          InfoRow(
            icon: Icons.phone_android_rounded,
            label: 'Mobile:',
            value: commuter.mobileNumber,
            iconColor: cts.yellowDark,
          ),
      ],
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
    final scheme = context.scheme;
    final cts = context.cts;

    final commuterId = commuter.id?.toString();
    final role = SessionRole.userType;
    final canConfirm =
        D2dChannelRolePolicy.can(role, D2dChannelAction.confirmPickup);
    final canRemove =
        D2dChannelRolePolicy.can(role, D2dChannelAction.removeFromQueue);

    return Slidable(
      key: ValueKey(commuterId ?? commuter.inLine ?? commuter.hashCode),
      startActionPane: canRemove
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    if (commuterId != null) {
                      provider.denyCommuter(commuterId);
                    }
                  },
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.surface,
                  icon: Icons.delete_rounded,
                  label: 'Delete',
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  flex: 1,
                ),
              ],
            )
          : null,
      endActionPane: canConfirm
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) {
                    if (commuterId != null) {
                      provider.confirmCommuter(commuterId);
                    }
                  },
                  backgroundColor: cts.success,
                  foregroundColor: scheme.surface,
                  icon: Icons.check_circle_rounded,
                  label: 'Picked up',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  flex: 1,
                ),
              ],
            )
          : null,
      child: ModernListCard(
        title: commuter.username,
        subtitle: 'Stop #${commuter.inLine ?? '?'}',
        icon: Icons.person_rounded,
        iconColor: scheme.primary,
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
            iconColor: cts.info,
          ),
          if (commuter.mobileNumber?.isNotEmpty ?? false)
            InfoRow(
              icon: Icons.phone_android_rounded,
              label: 'Mobile:',
              value: commuter.mobileNumber,
              iconColor: cts.yellowDark,
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
    final scheme = context.scheme;
    final cts = context.cts;

    final commuterId = commuter.id?.toString();
    final canRemove =
        D2dChannelRolePolicy.can(SessionRole.userType, D2dChannelAction.removeFromQueue);

    final card = ModernListCard(
      title: commuter.username,
      subtitle: 'ID ${commuter.id ?? '?'}',
      icon: Icons.person_rounded,
      iconColor: scheme.primary,
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
          iconColor: cts.info,
        ),
        InfoRow(
          icon: Icons.format_list_numbered_rounded,
          label: 'Stop #:',
          value: commuter.inLine?.toString() ?? 'N/A',
          iconColor: cts.yellowDark,
        ),
      ],
    );

    if (!canRemove) {
      return card;
    }

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
            backgroundColor: scheme.error,
            foregroundColor: scheme.surface,
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
      child: card,
    );
  }
}
