import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/commuters/presentation/providers/commuter_controller.dart';
import 'package:cts/features/commuters/presentation/providers/commuter_form_provider.dart';
import 'package:cts/features/commuters/domain/models/commuter_model.dart';
import 'package:cts/utils/sort_utils.dart';
import 'package:cts/shared/widgets/dashboard_shell.dart';
import 'package:cts/shared/widgets/loading_indicator.dart';
import 'package:cts/shared/widgets/status_message.dart';
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
      // Call the correct method on the correct provider
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

  void _showEditDialog(BuildContext context, int index) {
    final commuterProvider = context.read<CommuterController>();
    final formProvider = context.read<CommuterFormProvider>();
    final commuter = commuterProvider.commuters[index];

    formProvider.updateId = commuter.userId?.id ?? 0;
    formProvider.commName.text = commuter.userId?.username ?? "";
    formProvider.commMob.text = commuter.userId?.mobileNumber ?? "";
    // formProvider.commAddr.text = commuter.userId?.address ?? "";
    formProvider.commClg.text = commuter.collegeName ?? "";
    formProvider.selectedBatchId = commuter.batchId?.id;
    formProvider.selectedCabId = commuter.cabId?.id;
    formProvider.selectedPopId = commuter.popId?.id;
    formProvider.forUpdate = true;

    context.push(RouteName.commuterForm);
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      title: 'Batch: ${widget.batchName}',
      child: Consumer<CommuterController>(
        builder: (context, provider, child) {
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

          // Sort commuters A-Z by name, then by mobile
          final sortedCommuters =
              sortListAZMultiple<CommuterModel>(provider.commuters, [
                (commuter) => commuter.userId?.username ?? '',
                (commuter) => commuter.userId?.mobileNumber ?? '',
              ]);

          return RefreshIndicator(
            onRefresh: () => provider.fetchCommutersByBatch(widget.batchId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedCommuters.length,
              itemBuilder: (context, index) {
                final commuter = sortedCommuters[index];
                final initial =
                    commuter.userId?.username?.substring(0, 1).toUpperCase() ??
                    'C';

                return Slidable(
                  key: ValueKey(commuter.userId?.id),
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showEditDialog(context, index),
                        backgroundColor: AppColors.acYellow,
                        icon: Icons.edit,
                        label: "EDIT",
                      ),
                      SlidableAction(
                        onPressed: (context) =>
                            _makePhoneCall(commuter.userId?.mobileNumber),
                        backgroundColor: AppColors.acGreen,
                        icon: Icons.call,
                        label: "CALL",
                      ),
                    ],
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.acBlackLight,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        commuter.userId?.username ?? "No Name",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  commuter.userId?.mobileNumber ?? 'No Mobile',
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    commuter.popId?.pickUpPointName ?? 'No POP',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      trailing: Switch(
                        value: commuter.isComing ?? false,
                        onChanged: null, // Display only, no action
                      ),
                    ),
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
