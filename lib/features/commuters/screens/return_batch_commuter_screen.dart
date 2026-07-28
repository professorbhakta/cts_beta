import 'dart:async';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/batches/providers/return_batch_provider.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/headline_widget.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnCommuterListScreen extends StatefulWidget {
  final String batchId;
  const ReturnCommuterListScreen({super.key, required this.batchId});

  @override
  State<ReturnCommuterListScreen> createState() =>
      _ReturnCommuterListScreenState();
}

class _ReturnCommuterListScreenState extends State<ReturnCommuterListScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      // Use the new dedicated provider
      context.read<ReturnBatchProvider>().fetchReturnCommuters(widget.batchId);
    });
  }

  Future<void> makePhoneCall(String mobile) async {
    final Uri launchUri = Uri(scheme: 'tel', path: mobile);
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Consumer<ReturnBatchProvider>(
          builder: (context, provider, child) {
            if (provider.state == ViewState.loading) {
              return const LoadingIndicator();
            }
            if (provider.state == ViewState.error) {
              return StatusMessage.error(
                title: provider.errorMessage ?? 'An error occurred',
                onRetry: () =>
                    provider.fetchReturnCommuters(widget.batchId),
              );
            }
            return ListView.builder(
              itemCount: provider.returnCommuters.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Headline(
                    headline: "Manage Return Trip",
                    fontSize: 21,
                  );
                }

                final commuter = provider.returnCommuters[index - 1];
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const StretchMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          // TODO: Implement remove logic
                        },
                        backgroundColor: AppColors.acRed,
                        icon: Icons.remove_circle_outline,
                        label: "REMOVE",
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(commuter.userId?.username ?? 'N/A'),
                    subtitle: Text(commuter.popId?.pickUpPointName ?? 'N/A'),
                    trailing: IconButton(
                      tooltip: 'Call commuter',
                      icon: const Icon(Icons.call),
                      onPressed: () => makePhoneCall(
                        commuter.userId?.mobileNumber ?? '',
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

