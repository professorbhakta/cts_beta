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
    final scheme = theme.colorScheme;
    final message =
        provider.errorMessage ?? 'Live connection lost. Reconnecting…';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: scheme.onErrorContainer,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onErrorContainer,
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
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: scheme.primary, size: 20),
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

/// Connection / trip LIVE status — not a remaining-queue occupancy indicator.
class D2dLiveStatusChip extends StatelessWidget {
  const D2dLiveStatusChip({
    super.key,
    required this.isLive,
    this.prominent = false,
  });

  final bool isLive;

  /// Kept for call-site compatibility; both modes use quiet status text.
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    final label = isLive ? 'LIVE' : 'OFFLINE';
    final color = isLive
        ? cts.navy
        : cts.navy.withValues(alpha: 0.45);

    return Semantics(
      label: isLive ? 'Trip live' : 'Connection offline',
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

/// Remaining / On board counts in a quiet split row (not cartoon cards).
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
    final theme = Theme.of(context);
    final hairline = cts.navy.withValues(alpha: 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: hairline),
          bottom: BorderSide(color: hairline),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remaining',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cts.navy.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$waitingCount',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(width: 1, thickness: 1, color: hairline),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On board',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cts.navy.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$onBoardCount',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Name + outlined navy Board. Swipe confirm/remove unchanged.
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
                  icon: Icons.delete_outline,
                  label: 'Remove',
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
                  icon: Icons.check,
                  label: 'Board',
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onCall,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commuter.username,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: cts.navy,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (commuter.popId?.pickUpPointName != null)
                            Text(
                              commuter.popId!.pickUpPointName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cts.navy.withValues(alpha: 0.55),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: !canConfirm || commuterId == null
                        ? null
                        : () => provider.confirmCommuter(commuterId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cts.navy,
                      side: BorderSide(color: cts.navy.withValues(alpha: 0.55)),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Board',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w600,
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
              color: cts.navy.withValues(alpha: 0.1),
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
    final hairline = cts.navy.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Already in · ${widget.commuters.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cts.navy.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: cts.navy.withValues(alpha: 0.55),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: hairline),
        if (_expanded) ...[
          for (var i = 0; i < widget.commuters.length; i++) ...[
            D2dAlreadyInTile(
              commuter: widget.commuters[i],
              onCall: widget.onCall == null
                  ? null
                  : () => widget.onCall!(widget.commuters[i]),
            ),
            if (i < widget.commuters.length - 1)
              Divider(height: 1, thickness: 1, color: hairline),
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
    final cts = context.cts;
    if (commuters.isEmpty) return const SizedBox.shrink();

    final hairline = cts.navy.withValues(alpha: 0.12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Waiting line · ${commuters.length}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cts.navy.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'First come, first served — boarded when a seat opens.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 8),
        Divider(height: 1, thickness: 1, color: hairline),
        for (var i = 0; i < commuters.length; i++) ...[
          D2dWaitingTile(
            position: i + 1,
            commuter: commuters[i],
            onCall: onCall == null ? null : () => onCall!(commuters[i]),
          ),
          if (i < commuters.length - 1)
            Divider(height: 1, thickness: 1, color: hairline),
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
    final cts = context.cts;
    final theme = Theme.of(context);
    final name = commuter.username;
    final pop = commuter.popId?.pickUpPointName ?? 'Waiting for seat';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$position',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cts.navy.withValues(alpha: 0.55),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  pop,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          if (onCall != null)
            IconButton(
              tooltip: 'Call commuter',
              onPressed: onCall,
              icon: Icon(Icons.call_outlined, color: cts.navy, size: 18),
            ),
        ],
      ),
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
    final theme = Theme.of(context);
    final pop = commuter.popId?.pickUpPointName ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commuter.username,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Stop #${commuter.inLine ?? '?'} · $pop',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          if (onCall != null)
            IconButton(
              tooltip: 'Call commuter',
              onPressed: onCall,
              icon: Icon(Icons.call_outlined, color: cts.navy, size: 18),
            ),
        ],
      ),
    );
  }
}

/// Remaining rider row: name + call, swipe Picked up / Delete (beta behavior).
class D2dDriverCommuterTile extends StatelessWidget {
  const D2dDriverCommuterTile({
    super.key,
    required this.commuter,
    required this.provider,
    required this.onCall,
    this.showDivider = true,
  });

  final D2dCommuterModel commuter;
  final D2dChannelProvider provider;
  final VoidCallback onCall;
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
    final pop = commuter.popId?.pickUpPointName;

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
                  icon: Icons.delete_outline,
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
                  icon: Icons.check,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commuter.username,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (commuter.inLine != null) 'Stop #${commuter.inLine}',
                          if (pop != null && pop.isNotEmpty) pop,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cts.navy.withValues(alpha: 0.55),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Call commuter',
                  onPressed: onCall,
                  icon: Icon(Icons.call_outlined, color: cts.navy, size: 20),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: cts.navy.withValues(alpha: 0.1),
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
    final canRemove = D2dChannelRolePolicy.can(
      SessionRole.userType,
      D2dChannelAction.removeFromQueue,
    );

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
            icon: Icons.delete_outline,
            label: 'Remove',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            flex: 1,
          ),
        ],
      ),
      child: card,
    );
  }
}

/// Legacy controls bar kept for admin / older channel screens.
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call_outlined, size: 18),
              label: Text(callLabel),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            label: isLive ? 'Connection live' : 'Connection waiting',
            child: Icon(
              Icons.circle,
              size: 10,
              color: isLive ? cts.success : scheme.error,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onToggleSort,
            icon: const Icon(Icons.sort, size: 18),
            label: Text(isAscending ? 'Asc' : 'Desc'),
          ),
        ],
      ),
    );
  }
}
