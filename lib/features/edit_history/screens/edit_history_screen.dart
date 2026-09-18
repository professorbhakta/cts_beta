import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/edit_history/models/edit_record_models.dart';
import 'package:cts/features/edit_history/providers/edit_history_provider.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// System Admin (`SUPER_ADMIN`) audit history — records only, no QR.
class EditHistoryScreen extends StatefulWidget {
  const EditHistoryScreen({super.key});

  @override
  State<EditHistoryScreen> createState() => _EditHistoryScreenState();
}

class _EditHistoryScreenState extends State<EditHistoryScreen> {
  late final TextEditingController _userIdController;
  late final TextEditingController _pathController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<EditHistoryProvider>();
    _userIdController = TextEditingController(text: provider.userIdFilter);
    _pathController = TextEditingController(text: provider.pathFilter);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<EditHistoryProvider>().load();
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final provider = context.read<EditHistoryProvider>();
    final initial = provider.selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && mounted) {
      provider.setDate(picked);
      await provider.load();
    }
  }

  Future<void> _clearDate() async {
    final provider = context.read<EditHistoryProvider>();
    provider.setDate(null);
    await provider.load();
  }

  Future<void> _applyFilters() async {
    final provider = context.read<EditHistoryProvider>();
    provider.setUserIdFilter(_userIdController.text);
    provider.setPathFilter(_pathController.text);
    await provider.load();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Edit History',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      actions: [
        IconButton(
          tooltip: 'Pick date',
          icon: const Icon(Icons.calendar_today_outlined),
          onPressed: _pickDate,
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<EditHistoryProvider>().load(),
        ),
      ],
      child: Consumer<EditHistoryProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: provider.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _FilterBar(
                  provider: provider,
                  userIdController: _userIdController,
                  pathController: _pathController,
                  onPickDate: _pickDate,
                  onClearDate: _clearDate,
                  onApply: _applyFilters,
                ),
                const SizedBox(height: 16),
                if (provider.state == ViewState.loading && provider.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 48),
                    child: LoadingIndicator(height: 160),
                  )
                else if (provider.state == ViewState.error &&
                    provider.items.isEmpty)
                  StatusMessage(
                    icon: Icons.error_outline,
                    title: 'Unable to load edit history',
                    message: provider.errorMessage ??
                        'System Admin only. Pull to refresh.',
                    color: Theme.of(context).colorScheme.error,
                    onRetry: provider.load,
                  )
                else if (provider.items.isEmpty)
                  StatusMessage(
                    icon: Icons.history_toggle_off,
                    title: 'No edit records',
                    message:
                        'Try another date, clear path filter, or edit end_km as Admin first.',
                    color: context.cts.navy,
                    onRetry: provider.load,
                  )
                else
                  ...provider.items.map((item) => _EditRecordTile(item: item)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.provider,
    required this.userIdController,
    required this.pathController,
    required this.onPickDate,
    required this.onClearDate,
    required this.onApply,
  });

  final EditHistoryProvider provider;
  final TextEditingController userIdController;
  final TextEditingController pathController;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final dateLabel = provider.selectedDateIso ?? 'Any day';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'System Admin · who changed what',
          style: theme.textTheme.titleSmall?.copyWith(
            color: cts.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ActionChip(
              avatar: const Icon(Icons.event, size: 18),
              label: Text(dateLabel),
              onPressed: onPickDate,
            ),
            if (provider.selectedDate != null)
              TextButton(onPressed: onClearDate, child: const Text('Clear date')),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: userIdController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'User id (optional)',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => onApply(),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: pathController,
          decoration: const InputDecoration(
            labelText: 'Path contains (optional)',
            hintText: 'edit_end_km',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => onApply(),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: onApply,
            icon: const Icon(Icons.filter_list),
            label: const Text('Apply filters'),
          ),
        ),
      ],
    );
  }
}

class _EditRecordTile extends StatelessWidget {
  const _EditRecordTile({required this.item});

  final EditRecordItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final who = item.username?.isNotEmpty == true
        ? '${item.username} (#${item.userId ?? '—'})'
        : 'User #${item.userId ?? '—'}';
    final change = item.endKmChangeLabel;
    final leg = item.payloadSummary['leg']?.toString();
    final summaryBits = <String>[
      if (item.resourceType != null) item.resourceType!,
      if (leg != null && leg.isNotEmpty) 'leg=$leg',
      ?change,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              who,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cts.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.editedAt ?? '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.method ?? '?'} ${item.path ?? ''}',
              style: theme.textTheme.bodyMedium,
            ),
            if (summaryBits.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                summaryBits.join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (item.payloadSummary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.payloadSummary.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
