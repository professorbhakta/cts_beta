import 'package:cts/theme/cts_colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/providers/commuter_controller.dart';
import 'package:cts/features/commuters/providers/commuter_form_provider.dart';
import 'package:cts/features/commuters/models/commuter_model.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/widgets/catalog_list_chrome.dart';
import 'package:cts/widgets/coming_today_switch.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/dashboard_shell.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CommuterListScreen extends StatefulWidget {
  final String batchId;
  final String batchName;

  const CommuterListScreen({
    super.key,
    required this.batchId,
    required this.batchName,
  });

  @override
  State<CommuterListScreen> createState() => _CommuterListScreenState();
}

class _CommuterListScreenState extends State<CommuterListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommuterController>().fetchCommutersByBatch(widget.batchId);
    });
  }

  Future<void> _makePhoneCall(String? mobile) async {
    if (mobile == null || mobile.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: mobile);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showEditDialog(CommuterModel commuter) {
    context.read<CommuterFormProvider>().fillFromCommuter(commuter);
    context.push(RouteName.commuterForm);
  }

  Future<void> _handleIsComingToggle(
    CommuterModel commuter,
    bool newValue,
  ) async {
    final controller = context.read<CommuterController>();
    final userId = commuter.userId?.id;

    if (userId == null) {
      SnackBarService.showErrorSnackbar('Invalid commuter ID');
      return;
    }

    final success = await controller.updateCommuterIsComing(userId, newValue);

    if (!success && mounted) {
      SnackBarService.showErrorSnackbar(
        controller.errorMessage ?? 'Failed to update commuter status.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Batch: ${widget.batchName}',
      quietBrandAppBar: true,
      titleWidget: const CtsBrandLogo(height: 32),
      child: Consumer<CommuterController>(
        builder: (context, provider, child) {
          final cts = context.cts;

          if (provider.state == ViewState.loading &&
              provider.commuters.isEmpty) {
            return const LoadingIndicator();
          }

          if (provider.state == ViewState.error) {
            return StatusMessage(
              icon: Icons.error_outline,
              title: 'Failed to load commuters',
              message: provider.errorMessage ?? 'Please try again.',
              onRetry: () => provider.fetchCommutersByBatch(widget.batchId),
            );
          }

          if (provider.commuters.isEmpty) {
            return const StatusMessage(
              icon: Icons.people_outline,
              title: 'No commuters found for this batch',
            );
          }

          final sortedCommuters =
              sortListAZMultiple<CommuterModel>(provider.commuters, [
            (commuter) => commuter.userId?.username ?? '',
            (commuter) => commuter.userId?.mobileNumber ?? '',
          ]);

          return RefreshIndicator(
            onRefresh: () => provider.fetchCommutersByBatch(widget.batchId),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: sortedCommuters.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 16 : 10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return CatalogPageTitle(
                    title: 'Batch: ${widget.batchName}',
                  );
                }

                final commuter = sortedCommuters[index - 1];
                final mobile = commuter.userId?.mobileNumber;
                final pop = commuter.popId?.pickUpPointName ?? 'No POP';

                return Slidable(
                  key: ValueKey(commuter.userId?.id),
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => _showEditDialog(commuter),
                        backgroundColor: cts.yellow,
                        foregroundColor: cts.navy,
                        icon: Icons.edit,
                        label: 'EDIT',
                      ),
                      SlidableAction(
                        onPressed: (_) => _makePhoneCall(mobile),
                        backgroundColor: cts.navy,
                        foregroundColor: Colors.white,
                        icon: Icons.call,
                        label: 'CALL',
                      ),
                    ],
                  ),
                  child: CatalogCard(
                    title: commuter.userId?.username ?? 'No Name',
                    trailing: ComingTodaySwitch(
                      value: commuter.isComing ?? false,
                      onChanged: (value) =>
                          _handleIsComingToggle(commuter, value),
                    ),
                    children: [
                      CatalogField(
                        label: 'Mobile',
                        value: mobile ?? 'No Mobile',
                      ),
                      CatalogField(
                        label: 'POP',
                        value: pop,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
