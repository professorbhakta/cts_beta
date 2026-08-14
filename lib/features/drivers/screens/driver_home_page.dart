import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/models/driver_model.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/modern_list_card.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverHomeProvider>().fetchDriverProfile();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatBatchTime(String? batchTime) {
    if (batchTime == null || batchTime.isEmpty) return 'N/A';
    if (batchTime.length >= 5) return batchTime.substring(0, 5);
    return batchTime;
  }

  @override
  Widget build(BuildContext context) {
    return OfflineAutoRedirect(
      child: Scaffold(
        appBar: const BrandAppBar(),
        drawer: const AppDrawer(),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<DriverHomeProvider>().fetchDriverProfile(),
            child: Consumer<DriverHomeProvider>(
              builder: (context, provider, child) {
                return switch (provider.state) {
                  ViewState.loading => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200, child: LoadingIndicator()),
                      ],
                    ),
                  ViewState.error => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        StatusMessage.error(
                          title: provider.errorMessage ?? 'An error occurred',
                          onRetry: () => provider.fetchDriverProfile(),
                        ),
                      ],
                    ),
                  _ when provider.driverProfile == null =>
                    ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        StatusMessage(
                          icon: Icons.assignment_outlined,
                          title: 'No assignment details found.',
                          message: 'Pull to refresh.',
                        ),
                      ],
                    ),
                  _ => _buildContent(context, provider),
                };
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DriverHomeProvider provider) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final driverProfile = provider.driverProfile!;
    final adminMobile = driverProfile.adminCode?.userId?.mobileNumber;
    final batchId = driverProfile.batchId?.id;
    final driverName = driverProfile.userId?.username ?? 'Driver';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${_greeting()}, $driverName',
          style: textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          'Review today\'s assignment and start your trip when ready.',
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 20),
        const AdminFormHeader(
          icon: Icons.assignment_rounded,
          title: 'Today\'s Assignment',
        ),
        const SizedBox(height: 12),
        _buildDateStrip(context),
        const SizedBox(height: 12),
        _buildAssignmentCard(context, driverProfile, adminMobile),
        const SizedBox(height: 32),
        CommonPrimaryButton(
          width: double.infinity,
          radius: 12,
          borderColor: scheme.primary,
          backgroundColor: scheme.inverseSurface,
          textColor: scheme.onInverseSurface,
          label: 'START TRIP',
          fontSize: 20,
          padding: const EdgeInsets.symmetric(vertical: 16),
          icon: const Icon(Icons.play_arrow_rounded),
          onPressed: batchId != null
              ? () => context.push('${RouteName.d2dLog}/$batchId')
              : null,
        ),
        if (batchId != null) ...[
          const SizedBox(height: 12),
          CommonPrimaryButton(
            width: double.infinity,
            radius: 12,
            borderColor: scheme.primary,
            backgroundColor: scheme.surface,
            textColor: scheme.primary,
            label: 'RETURN LIST',
            fontSize: 18,
            padding: const EdgeInsets.symmetric(vertical: 14),
            icon: const Icon(Icons.assignment_return_outlined),
            onPressed: () => context.push(
              '${RouteName.driverReturnCommuter}/$batchId',
            ),
          ),
        ],
        if (batchId == null) ...[
          const SizedBox(height: 12),
          Text(
            'No batch assigned yet. Contact admin if this looks wrong.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
            Icons.calendar_today_rounded,
            color: AppColors.acYellowWarm,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat.yMMMEd().format(DateTime.now()),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.acGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'READY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.acGreen,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    DriverModel driverProfile,
    String? adminMobile,
  ) {
    final batchName = driverProfile.batchId?.batchName ?? 'No batch assigned';
    final startTime = _formatBatchTime(driverProfile.batchId?.batchTime);
    final cabNumber = driverProfile.cabId?.regNumber ?? 'N/A';

    return ModernListCard(
      title: batchName,
      subtitle: 'Assigned route for today',
      icon: Icons.directions_bus_filled_rounded,
      iconColor: AppColors.acYellowWarm,
      trailing: adminMobile != null && adminMobile.isNotEmpty
          ? IconButton(
              tooltip: 'Call admin',
              onPressed: () => calling(adminMobile),
              icon: Icon(
                Icons.call_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      children: [
        InfoRow(
          icon: Icons.event_rounded,
          label: 'Batch:',
          value: batchName,
          iconColor: AppColors.acYellowDark,
        ),
        InfoRow(
          icon: Icons.access_time_rounded,
          label: 'Start:',
          value: startTime,
          iconColor: AppColors.acYellowWarm,
        ),
        InfoRow(
          icon: Icons.directions_car_rounded,
          label: 'Cab:',
          value: cabNumber,
          iconColor: AppColors.acBlue,
        ),
      ],
    );
  }
}
