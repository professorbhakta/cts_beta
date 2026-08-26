import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/models/batch_model.dart';
import 'package:cts/features/batches/providers/running_batch_provider.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
        color: theme.colorScheme.primary,
        onRetry: () => provider.fetchOnce(),
      );
    }

    final sortedBatches = sortListAZ<RunningBatches>(
      batches,
      (batch) => batch.batchId?.batchName ?? '',
    );

    return RefreshIndicator(
      onRefresh: provider.fetchOnce,
      child: LayoutBuilder(
        builder: (context, constraints) {

          final crossAxisCount = _crossAxisCount(constraints.maxWidth);
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text('Live batches', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                'Monitor running routes and open their door-to-door channels instantly.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: crossAxisCount == 1 ? 16 / 9 : 4 / 3,
                ),
                itemCount: sortedBatches.length,
                itemBuilder: (context, index) {
                  final batch = sortedBatches[index];
                  return _RunningBatchCard(
                    batchName: batch.batchId?.batchName ?? 'Unknown batch',
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
            ],
          );
        },
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

class _RunningBatchCard extends StatelessWidget {
  const _RunningBatchCard({required this.batchName, required this.onTap});

  final String batchName;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final cts = context.cts;

    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Live batch',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cts.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'LIVE NOW',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cts.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                batchName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: Icon(Icons.arrow_outward_rounded, size: 18),
                  label: const Text('Open channel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
