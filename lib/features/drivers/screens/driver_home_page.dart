import 'package:cts/app/router/route_names.dart';
import 'package:cts/offline_temp/offline_auto_redirect.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/loading_indicator.dart';
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

  @override
  Widget build(BuildContext context) {
    return OfflineAutoRedirect(
      child: Scaffold(
        appBar: const BrandAppBar(),
        drawer: const AppDrawer(),
        body: SafeArea(
          top: false,
          child: Consumer<DriverHomeProvider>(
            builder: (context, provider, child) {
              return switch (provider.state) {
                ViewState.loading => const LoadingIndicator(),
                ViewState.error => StatusMessage.error(
                    title: provider.errorMessage ?? 'An error occurred',
                    onRetry: () => provider.fetchDriverProfile(),
                  ),
                _ when provider.driverProfile == null => const StatusMessage(
                    icon: Icons.assignment_outlined,
                    title: 'No assignment details found.',
                  ),
                _ => _buildContent(context, provider),
              };
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DriverHomeProvider provider) {
    final w = MediaQuery.sizeOf(context).width;
    final scheme = Theme.of(context).colorScheme;
    final driverProfile = provider.driverProfile!;
    final adminMobile = driverProfile.adminCode?.userId?.mobileNumber;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            color: AppColors.acBlackLight,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMEd().format(DateTime.now()),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.acWhite,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (adminMobile != null && adminMobile.isNotEmpty)
                        IconButton.outlined(
                          tooltip: 'Call admin',
                          onPressed: () => calling(adminMobile),
                          style: IconButton.styleFrom(
                            foregroundColor: AppColors.acWhite,
                            side: const BorderSide(
                              color: AppColors.acYellowWarm,
                            ),
                          ),
                          icon: const Icon(Icons.call),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final useColumn = constraints.maxWidth < 360;
                      final info = [
                        _buildInfoColumn(
                          'Batch',
                          driverProfile.batchId?.batchName ?? 'N/A',
                        ),
                        _buildInfoColumn(
                          'Start Time',
                          driverProfile.batchId?.batchTime ?? 'N/A',
                        ),
                        _buildInfoColumn(
                          'Cab',
                          driverProfile.cabId?.regNumber ?? 'N/A',
                        ),
                      ];
                      if (useColumn) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < info.length; i++) ...[
                              info[i],
                              if (i < info.length - 1) const SizedBox(height: 12),
                            ],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          for (var i = 0; i < info.length; i++) ...[
                            Expanded(child: info[i]),
                            if (i < info.length - 1) const SizedBox(width: 8),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          CommonPrimaryButton(
            width: w * 0.7,
            radius: 12,
            borderColor: scheme.primary,
            backgroundColor: scheme.inverseSurface,
            textColor: scheme.onInverseSurface,
            label: 'START TRIP',
            fontSize: 20,
            padding: const EdgeInsets.symmetric(vertical: 16),
            onPressed: () {
              final batchId = driverProfile.batchId?.id;
              if (batchId != null) {
                context.push(
                  '${RouteName.d2dLog}/$batchId',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.acYellowWarm,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.acWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}
