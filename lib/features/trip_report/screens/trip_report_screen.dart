import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/trip_report/helpers/trip_report_photo_url.dart';
import 'package:cts/features/trip_report/helpers/trip_report_review.dart';
import 'package:cts/widgets/trip_review_banner.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/models/trip_report_month_models.dart';
import 'package:cts/features/trip_report/providers/trip_report_provider.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/authenticated_network_image.dart';
import 'package:cts/widgets/catalog_list_chrome.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TripReportScreen extends StatefulWidget {
  const TripReportScreen({super.key});

  @override
  State<TripReportScreen> createState() => _TripReportScreenState();
}

class _TripReportScreenState extends State<TripReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripReportProvider>().bootstrap();
    });
  }

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<TripReportProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && context.mounted) {
      await provider.setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Trip Report',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      actions: [
        IconButton(
          tooltip: 'Pick date',
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: () => _pickDate(context),
        ),
      ],
      child: Consumer<TripReportProvider>(
        builder: (context, provider, _) {
          return _TripReportBody(
            provider: provider,
            onPickDate: () => _pickDate(context),
          );
        },
      ),
    );
  }
}

class _TripReportBody extends StatelessWidget {
  const _TripReportBody({
    required this.provider,
    required this.onPickDate,
  });

  final TripReportProvider provider;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final items = provider.visibleItems;
    final allItems = provider.items;

    if (provider.state == ViewState.loading && allItems.isEmpty) {
      return const LoadingIndicator(height: 280);
    }

    if (provider.state == ViewState.error && allItems.isEmpty) {
      return StatusMessage(
        icon: Icons.error_outline,
        title: 'Unable to load trip report',
        message: provider.errorMessage ??
            'Please pull to refresh or try again later.',
        color: theme.colorScheme.error,
        onRetry: () => provider.bootstrap(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.bootstrap(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.isEmpty ? 4 : items.length + 3,
        separatorBuilder: (_, index) =>
            SizedBox(height: index == 0 ? 12 : 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const CatalogPageTitle(title: 'Daily Trip Report');
          }
          if (index == 1) {
            return _MonthStrip(provider: provider);
          }
          if (index == 2) {
            final needsReview = tripReportNeedsEndKmReview(provider.report);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateBar(
                  dateIso: provider.selectedDateIso,
                  count: provider.report?.count ?? allItems.length,
                  onPick: onPickDate,
                ),
                const SizedBox(height: 10),
                _DayFilterChips(provider: provider),
                if (needsReview) ...[
                  const SizedBox(height: 12),
                  const TripReviewBanner(
                    message:
                        'Trips need end km review (incomplete or auto-closed). Scroll to a flagged batch below.',
                  ),
                ],
              ],
            );
          }
          if (items.isEmpty) {
            return StatusMessage(
              icon: Icons.info_outline,
              title: allItems.isEmpty
                  ? 'No trips for this day'
                  : 'No trips match filters',
              message: allItems.isEmpty
                  ? 'Pick another day in the month strip or pull to refresh.'
                  : 'Clear filter chips to see all batches for this day.',
              color: cts.navy,
              onRetry: allItems.isEmpty
                  ? () => provider.load()
                  : () => provider.clearDayFilters(),
            );
          }
          final item = items[index - 3];
          return _BatchTripCard(
            item: item,
            onEdit: (leg, currentEndKm) => _showEditDialog(
              context,
              provider: provider,
              item: item,
              leg: leg,
              currentEndKm: currentEndKm,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context, {
    required TripReportProvider provider,
    required TripReportBatchItem item,
    required TripReportLegKind leg,
    required int? currentEndKm,
  }) async {
    final controller = TextEditingController(
      text: currentEndKm?.toString() ?? '',
    );
    provider.clearEditError();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Consumer<TripReportProvider>(
          builder: (context, p, _) {
            return AlertDialog(
              title: Text(
                'Edit ${leg == TripReportLegKind.morning ? 'morning' : 'return'} end km',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.batchName.isEmpty ? item.batchId : item.batchName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'end_km',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  if (p.editError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      p.editError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: p.saving
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: p.saving
                      ? null
                      : () async {
                          final parsed = int.tryParse(controller.text.trim());
                          if (parsed == null) {
                            return;
                          }
                          final ok = await p.editEndKm(
                            batchId: item.batchId,
                            leg: leg,
                            endKm: parsed,
                          );
                          if (ok && dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        },
                  child: p.saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('end_km updated')),
      );
    }
  }
}

class _DateBar extends StatelessWidget {
  const _DateBar({
    required this.dateIso,
    required this.count,
    required this.onPick,
  });

  final String dateIso;
  final int count;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: hairline),
      ),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.event_outlined, color: cts.navy, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateIso,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cts.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$count batch${count == 1 ? '' : 'es'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cts.navy.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Change',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchTripCard extends StatelessWidget {
  const _BatchTripCard({
    required this.item,
    required this.onEdit,
  });

  final TripReportBatchItem item;
  final void Function(TripReportLegKind leg, int? currentEndKm) onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.batchName.isEmpty ? 'Batch ${item.batchId}' : item.batchName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'id ${item.batchId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cts.navy.withValues(alpha: 0.55),
              ),
            ),
            if (item.anyIncomplete || item.anyEdited || item.anyAutoClosed) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (item.anyIncomplete)
                    const _CloseKindChip(kind: TripCloseKind.incomplete),
                  if (item.anyEdited)
                    const _CloseKindChip(kind: TripCloseKind.edited),
                  if (item.anyAutoClosed)
                    const _CloseKindChip(kind: TripCloseKind.autoClosed),
                ],
              ),
            ],
            const SizedBox(height: 12),
            _LegRow(
              label: 'Morning',
              batchId: item.batchId,
              legKind: TripReportLegKind.morning,
              leg: item.morning,
              onEdit: () => onEdit(
                TripReportLegKind.morning,
                item.morning?.endKm,
              ),
            ),
            const SizedBox(height: 10),
            _LegRow(
              label: 'Return',
              batchId: item.batchId,
              legKind: TripReportLegKind.ret,
              leg: item.returnLeg,
              onEdit: () => onEdit(
                TripReportLegKind.ret,
                item.returnLeg?.endKm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegRow extends StatelessWidget {
  const _LegRow({
    required this.label,
    required this.batchId,
    required this.legKind,
    required this.leg,
    required this.onEdit,
  });

  final String label;
  final String batchId;
  final TripReportLegKind legKind;
  final TripReportLeg? leg;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final effective = leg ?? const TripReportLeg(closeKind: TripCloseKind.absent);
    final canEdit = effective.closeKind != TripCloseKind.absent &&
        effective.startKm != null;
    final showPhotos = effective.closeKind != TripCloseKind.absent;

    final startUrl = showPhotos
        ? resolveTripReportPhotoUrl(
            wirePhotoUrl: effective.startPhotoUrl,
            batchId: batchId,
            leg: legKind,
            kind: 'start',
          )
        : null;
    final endUrl = showPhotos
        ? resolveTripReportPhotoUrl(
            wirePhotoUrl: effective.endPhotoUrl,
            batchId: batchId,
            leg: legKind,
            kind: 'end',
          )
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cts.navy.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cts.navy,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (canEdit)
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Edit end km'),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final chip in effective.displayChips)
                _CloseKindChip(kind: chip),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _kmLine(effective),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cts.navy.withValues(alpha: 0.8),
            ),
          ),
          if (showPhotos) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _OdometerThumb(
                  label: 'Start',
                  url: startUrl,
                  hairline: cts.navy.withValues(alpha: 0.14),
                ),
                const SizedBox(width: 10),
                _OdometerThumb(
                  label: 'End',
                  url: endUrl,
                  hairline: cts.navy.withValues(alpha: 0.14),
                ),
              ],
            ),
          ],
          if (effective.closeKind != TripCloseKind.absent) ...[
            const SizedBox(height: 10),
            _BoardedSection(leg: effective),
          ],
        ],
      ),
    );
  }

  String _kmLine(TripReportLeg leg) {
    if (leg.closeKind == TripCloseKind.absent) {
      return 'No trip logged';
    }
    final start = leg.startKm?.toString() ?? '—';
    final end = leg.endKm?.toString() ?? '—';
    final dist = leg.distanceKm?.toString() ?? '—';
    return 'start $start  ·  end $end  ·  distance $dist km';
  }
}

class _BoardedSection extends StatelessWidget {
  const _BoardedSection({required this.leg});

  final TripReportLeg leg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final riders = leg.boarded;
    final count = leg.effectiveBoardedCount;
    final driver = leg.driverName?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Boarded ($count)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        if (driver != null && driver.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            'Driver $driver',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cts.navy.withValues(alpha: 0.65),
            ),
          ),
        ],
        const SizedBox(height: 6),
        if (riders.isEmpty)
          Text(
            'No riders boarded',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cts.navy.withValues(alpha: 0.55),
            ),
          )
        else
          for (var i = 0; i < riders.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _BoardedRiderRow(rider: riders[i]),
          ],
      ],
    );
  }
}

class _BoardedRiderRow extends StatelessWidget {
  const _BoardedRiderRow({required this.rider});

  final TripReportBoardedRider rider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final secondary = rider.displaySecondary;
    final at = rider.boardedAt?.trim();
    final source = rider.source?.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.person_outline,
          size: 16,
          color: cts.navy.withValues(alpha: 0.45),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rider.displayPrimary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (secondary != null)
                Text(
                  secondary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.65),
                  ),
                ),
              if ((at != null && at.isNotEmpty) ||
                  (source != null && source.isNotEmpty))
                Text(
                  [
                    if (at != null && at.isNotEmpty) at,
                    if (source != null && source.isNotEmpty) source,
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cts.navy.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OdometerThumb extends StatelessWidget {
  const _OdometerThumb({
    required this.label,
    required this.url,
    required this.hairline,
  });

  final String label;
  final String? url;
  final Color hairline;

  static const double _size = 56;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final radius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cts.navy.withValues(alpha: 0.65),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: hairline),
            color: cts.navy.withValues(alpha: 0.04),
          ),
          child: AuthenticatedNetworkImage(
            url: url,
            width: _size,
            height: _size,
            fit: BoxFit.cover,
            borderRadius: radius,
            errorBuilder: (_) => Icon(
              Icons.image_not_supported_outlined,
              size: 20,
              color: cts.navy.withValues(alpha: 0.28),
            ),
            onTap: url == null
                ? null
                : () => showAuthenticatedPhotoViewer(
                      context,
                      url: url,
                      title: '$label odometer',
                    ),
          ),
        ),
      ],
    );
  }
}

class _CloseKindChip extends StatelessWidget {
  const _CloseKindChip({required this.kind});

  final TripCloseKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final (bg, fg) = _colors(cts);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        kind.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  (Color, Color) _colors(CtsColors cts) {
    switch (kind) {
      case TripCloseKind.absent:
        return (cts.navy.withValues(alpha: 0.08), cts.navy.withValues(alpha: 0.55));
      case TripCloseKind.open:
        return (cts.yellowSoft, cts.navy);
      case TripCloseKind.normal:
        return (cts.success.withValues(alpha: 0.15), cts.success);
      case TripCloseKind.incomplete:
        return (cts.orangeSoft, cts.navy);
      case TripCloseKind.edited:
        return (cts.info.withValues(alpha: 0.12), cts.info);
      case TripCloseKind.autoClosed:
        return (cts.yellowWarm.withValues(alpha: 0.35), cts.navy);
    }
  }
}


class _MonthStrip extends StatelessWidget {
  const _MonthStrip({required this.provider});

  final TripReportProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final label = '${_monthName(provider.viewMonth)} ${provider.viewYear}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Previous month',
              onPressed: () => provider.shiftMonth(-1),
              icon: Icon(Icons.chevron_left, color: cts.navy),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cts.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Next month',
              onPressed: () => provider.shiftMonth(1),
              icon: Icon(Icons.chevron_right, color: cts.navy),
            ),
          ],
        ),
        if (provider.monthState == ViewState.loading &&
            provider.monthDays.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 2),
          )
        else if (provider.monthState == ViewState.error)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              provider.monthError ?? 'Month index unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          )
        else
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: provider.monthDays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, i) {
                final day = provider.monthDays[i];
                final selected = day.date == provider.selectedDateIso;
                return _MonthDayChip(
                  day: day,
                  selected: selected,
                  onTap: () {
                    final parts = day.date.split('-');
                    if (parts.length != 3) return;
                    final y = int.tryParse(parts[0]);
                    final m = int.tryParse(parts[1]);
                    final d = int.tryParse(parts[2]);
                    if (y == null || m == null || d == null) return;
                    provider.setDate(DateTime(y, m, d));
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  static String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return '';
    return names[month];
  }
}

class _MonthDayChip extends StatelessWidget {
  const _MonthDayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final TripReportMonthDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final dayNum = day.date.length >= 10 ? day.date.substring(8, 10) : day.date;
    final border = selected
        ? cts.navy
        : cts.navy.withValues(alpha: day.hasTrip ? 0.35 : 0.12);
    final bg = selected
        ? cts.yellowSoft
        : theme.scaffoldBackgroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 48,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNum,
              style: theme.textTheme.labelLarge?.copyWith(
                color: cts.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (day.anyIncomplete)
                  _Dot(color: cts.navy),
                if (day.anyAutoClosed)
                  _Dot(color: cts.yellowWarm),
                if (day.anyEdited)
                  _Dot(color: theme.colorScheme.primary),
                if (!day.hasFlag && day.hasTrip)
                  _Dot(color: cts.navy.withValues(alpha: 0.25)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DayFilterChips extends StatelessWidget {
  const _DayFilterChips({required this.provider});

  final TripReportProvider provider;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;
    Widget chip(TripReportDayFilter filter, String label) {
      final selected = provider.dayFilters.contains(filter);
      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => provider.toggleDayFilter(filter),
        selectedColor: cts.yellowSoft,
        checkmarkColor: cts.navy,
        labelStyle: TextStyle(
          color: cts.navy,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        chip(TripReportDayFilter.incomplete, 'Incomplete'),
        chip(TripReportDayFilter.autoClosed, 'Auto-closed'),
        chip(TripReportDayFilter.edited, 'Edited'),
        if (provider.dayFilters.isNotEmpty)
          TextButton(
            onPressed: provider.clearDayFilters,
            child: const Text('Clear'),
          ),
      ],
    );
  }
}
