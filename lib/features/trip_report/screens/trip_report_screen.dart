import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/trip_report/models/trip_report_models.dart';
import 'package:cts/features/trip_report/providers/trip_report_provider.dart';
import 'package:cts/theme/cts_colors.dart';
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
      context.read<TripReportProvider>().load();
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
    final items = provider.items;

    if (provider.state == ViewState.loading && items.isEmpty) {
      return const LoadingIndicator(height: 280);
    }

    if (provider.state == ViewState.error && items.isEmpty) {
      return StatusMessage(
        icon: Icons.error_outline,
        title: 'Unable to load trip report',
        message: provider.errorMessage ??
            'Please pull to refresh or try again later.',
        color: theme.colorScheme.error,
        onRetry: () => provider.load(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.isEmpty ? 3 : items.length + 2,
        separatorBuilder: (_, index) =>
            SizedBox(height: index == 0 ? 12 : 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const CatalogPageTitle(title: 'Daily Trip Report');
          }
          if (index == 1) {
            return _DateBar(
              dateIso: provider.selectedDateIso,
              count: provider.report?.count ?? items.length,
              onPick: onPickDate,
            );
          }
          if (items.isEmpty) {
            return StatusMessage(
              icon: Icons.info_outline,
              title: 'No trips for this day',
              message: 'Pick another date or pull to refresh.',
              color: cts.navy,
              onRetry: () => provider.load(),
            );
          }
          final item = items[index - 2];
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
              leg: item.morning,
              onEdit: () => onEdit(
                TripReportLegKind.morning,
                item.morning?.endKm,
              ),
            ),
            const SizedBox(height: 10),
            _LegRow(
              label: 'Return',
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
    required this.leg,
    required this.onEdit,
  });

  final String label;
  final TripReportLeg? leg;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final effective = leg ?? const TripReportLeg(closeKind: TripCloseKind.absent);
    final canEdit = effective.closeKind != TripCloseKind.absent &&
        effective.startKm != null;

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
