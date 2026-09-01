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
                D2dLiveStatusChip(isLive: isLive),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Connection / trip LIVE chip — not a remaining-queue occupancy indicator.
class D2dLiveStatusChip extends StatelessWidget {
  const D2dLiveStatusChip({
    super.key,
    required this.isLive,
    this.prominent = false,
  });

  final bool isLive;

  /// Solid high-contrast fill for driver live trip (not a faint tint).
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;

    final Color bg;
    final Color fg;
    if (prominent) {
      bg = isLive ? cts.yellow : scheme.inverseSurface;
      fg = isLive ? scheme.onPrimary : scheme.onInverseSurface;
    } else {
      bg = (isLive ? cts.success : scheme.error).withValues(alpha: 0.15);
      fg = isLive ? cts.success : scheme.error;
    }
    final label = isLive ? 'LIVE' : 'WAITING';

    return Semantics(
      label: isLive ? 'Trip live' : 'Connection waiting',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: prominent ? 12 : 10,
          vertical: prominent ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: prominent
              ? Border.all(
                  color: isLive ? cts.navy : scheme.onInverseSurface,
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
        ),
      ),
    );
  }
}

/// High-contrast live status strip: connection LIVE + remaining / boarded counts.
/// Sits above the queue — never behind the QR.
class D2dLiveStatusStrip extends StatelessWidget {
  const D2dLiveStatusStrip({
    super.key,
    required this.isLive,
    required this.remainingCount,
    required this.boardedCount,
  });

  final bool isLive;
  final int remainingCount;
  final int boardedCount;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);

    return Semantics(
      label: isLive
          ? 'Trip live. $remainingCount remaining. $boardedCount boarded.'
          : 'Connection waiting. $remainingCount remaining. $boardedCount boarded.',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            D2dLiveStatusChip(isLive: isLive, prominent: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isLive ? 'Trip live' : 'Reconnecting…',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              'Rem $remainingCount',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cts.yellow,
                fontWeight: FontWeight.w800,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '·',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onInverseSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Text(
              'Boarded $boardedCount',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cts.yellow,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
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

class D2dAlreadyInSection extends StatefulWidget {
  const D2dAlreadyInSection({
    super.key,
    required this.commuters,
    this.onCall,
  });

  final List<D2dCommuterModel> commuters;
  final void Function(D2dCommuterModel commuter)? onCall;

  @override
  State<D2dAlreadyInSection> createState() => _D2dAlreadyInSectionState();
}

class _D2dAlreadyInSectionState extends State<D2dAlreadyInSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;

    if (widget.commuters.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: cts.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Already IN (${widget.commuters.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cts.success,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          Text(
            'Confirmed in the cab — removed from the remaining queue.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < widget.commuters.length; i++) ...[
            D2dAlreadyInTile(
              commuter: widget.commuters[i],
              onCall: widget.onCall == null
                  ? null
                  : () => widget.onCall!(widget.commuters[i]),
            ),
            if (i < widget.commuters.length - 1) const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class D2dWaitingSection extends StatelessWidget {
  const D2dWaitingSection({
    super.key,
    required this.commuters,
    this.onCall,
  });

  final List<D2dCommuterModel> commuters;
  final void Function(D2dCommuterModel commuter)? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = context.scheme;
    final cts = context.cts;

    if (commuters.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.hourglass_top_rounded,
              size: 20,
              color: cts.yellowDark,
            ),
            const SizedBox(width: 8),
            Text(
              'Waiting line (${commuters.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cts.yellowDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'First come, first served — auto-boarded when a seat opens.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < commuters.length; i++) ...[
          D2dWaitingTile(
            position: i + 1,
            commuter: commuters[i],
            onCall: onCall == null ? null : () => onCall!(commuters[i]),
          ),
          if (i < commuters.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class D2dWaitingTile extends StatelessWidget {
  const D2dWaitingTile({
    super.key,
    required this.position,
    required this.commuter,
    this.onCall,
  });

  final int position;
  final D2dCommuterModel commuter;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final name = commuter.username;

    return ModernListCard(
      title: '#$position · $name',
      subtitle: commuter.popId?.pickUpPointName ?? 'Waiting for seat',
      icon: Icons.schedule_rounded,
      iconColor: scheme.primary,
      trailing: onCall == null
          ? null
          : IconButton(
              tooltip: 'Call commuter',
              onPressed: onCall,
              icon: Icon(Icons.call_rounded, color: scheme.primary),
            ),
      children: [
        if (commuter.mobileNumber != null && commuter.mobileNumber!.isNotEmpty)
          InfoRow(
            icon: Icons.phone_rounded,
            label: 'Mobile:',
            value: commuter.mobileNumber!,
          ),
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

/// Waiting vs On board summary for driver live trip.
class D2dTripCountsRow extends StatelessWidget {
  const D2dTripCountsRow({
    super.key,
    required this.waitingCount,
    required this.onBoardCount,
  });

  final int waitingCount;
  final int onBoardCount;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final scheme = context.scheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cts.navy.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waiting',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$waitingCount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: scheme.inverseSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'On board',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cts.yellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$onBoardCount',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: cts.yellow,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Tall name + yellow Board row for driver live trip.
class D2dBoardRow extends StatelessWidget {
  const D2dBoardRow({
    super.key,
    required this.commuter,
    required this.provider,
    this.onCall,
    this.showDivider = true,
  });

  final D2dCommuterModel commuter;
  final D2dChannelProvider provider;
  final VoidCallback? onCall;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final cts = context.cts;
    final theme = Theme.of(context);
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
              extentRatio: 0.22,
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
                ),
              ],
            )
          : null,
      endActionPane: canConfirm
          ? ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.22,
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
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCall,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        commuter.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: !canConfirm || commuterId == null
                        ? null
                        : () => provider.confirmCommuter(commuterId),
                    style: FilledButton.styleFrom(
                      backgroundColor: cts.yellow,
                      foregroundColor: scheme.onPrimary,
                      disabledBackgroundColor:
                          cts.yellow.withValues(alpha: 0.45),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Board',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: cts.navy.withValues(alpha: 0.08),
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
    return D2dBoardRow(
      commuter: commuter,
      provider: provider,
      onCall: onCall,
      showDivider: false,
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
