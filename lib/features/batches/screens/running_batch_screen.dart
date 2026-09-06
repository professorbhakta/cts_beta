import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/catalog_list_chrome.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RunningBatchScreen extends StatefulWidget {
  const RunningBatchScreen({super.key});

  @override
  State<RunningBatchScreen> createState() => _RunningBatchScreenState();
}

class _RunningBatchScreenState extends State<RunningBatchScreen> {
  late final RunningBatchProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<RunningBatchProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchOnce();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Running Batches',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      child: Consumer<RunningBatchProvider>(
        builder: (context, provider, _) {
          return _RunningBatchBody(provider: provider);
        },
      ),
    );
  }
}

class _RunningBatchBody extends StatelessWidget {
  const _RunningBatchBody({required this.provider});

  final RunningBatchProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final batches = provider.runningBatches;

    if (provider.state == ViewState.loading && batches.isEmpty) {
      return const LoadingIndicator(height: 280);
    }

    if (provider.state == ViewState.error && batches.isEmpty) {
      return StatusMessage(
        icon: Icons.error_outline,
        title: 'Unable to load batches',
        message:
            provider.errorMessage ??
            'Please pull to refresh or try again later.',
        color: theme.colorScheme.error,
        onRetry: () => provider.fetchOnce(),
      );
    }

    if (batches.isEmpty) {
      return StatusMessage(
        icon: Icons.info_outline,
        title: 'No running batches right now',
        message: 'As soon as a batch goes live, it will appear here.',
        color: cts.navy,
        onRetry: () => provider.fetchOnce(),
      );
    }

    final sortedBatches = sortListAZ<RunningBatches>(
      batches,
      (batch) => batch.batchId?.batchName ?? '',
    );

    return RefreshIndicator(
      onRefresh: provider.fetchOnce,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: sortedBatches.length + 1,
        separatorBuilder: (_, index) =>
            SizedBox(height: index == 0 ? 16 : 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const CatalogPageTitle(title: 'Running Batches');
          }
          final batch = sortedBatches[index - 1];
          final user = batch.driver?.userId;
          final driverName = [
            user?.firstName,
            user?.lastName,
          ].whereType<String>().where((n) => n.isNotEmpty).join(' ');
          final fallback = user?.username;
          final driverLabel = driverName.isNotEmpty
              ? driverName
              : (fallback != null && fallback.isNotEmpty ? fallback : null);

          return _RunningBatchTile(
            batchName: batch.batchId?.batchName ?? 'Unknown batch',
            driverName: driverLabel,
            onTap: () async {
              final id = batch.batchId?.id?.toString();
              if (id == null) return;
              await context.push('${RouteName.d2dChannel}/$id');
              if (!context.mounted) return;
              provider.fetchOnce();
            },
          );
        },
      ),
    );
  }
}

class _RunningBatchTile extends StatelessWidget {
  const _RunningBatchTile({
    required this.batchName,
    required this.onTap,
    this.driverName,
  });

  final String batchName;
  final String? driverName;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cts = context.cts;
    final hairline = cts.navy.withValues(alpha: 0.14);

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batchName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: cts.navy,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (driverName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Driver: $driverName',
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: cts.navy.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
