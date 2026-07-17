import 'package:cts/appManager/colors.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/d2d/presentation/providers/d2d_channel_provider.dart';
import 'package:cts/models/d2d_commuter_model.dart';
import 'package:cts/shared/widgets/admin_form_header.dart';
import 'package:cts/shared/widgets/app_drawer.dart';
import 'package:cts/shared/widgets/brand_app_bar.dart';
import 'package:cts/shared/widgets/loading_indicator.dart';
import 'package:cts/shared/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class D2DLogScreen extends StatefulWidget {
  const D2DLogScreen({super.key, required this.batchId});

  final String batchId;

  @override
  State<D2DLogScreen> createState() => _D2DLogScreenState();
}

class _D2DLogScreenState extends State<D2DLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<D2dChannelProvider>().connect(widget.batchId);
    });
  }

  @override
  void dispose() {
    final provider = context.read<D2dChannelProvider>();
    provider.disconnect();
    super.dispose();
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _stopTrip() {
    final provider = context.read<D2dChannelProvider>();
    provider.disconnect();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteName.driverHomeScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fabPadding = d2dFabScrollPadding(context);
    final dividerColor = Theme.of(context).colorScheme.outlineVariant;

    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, child) {
            if (provider.state == ViewState.loading) {
              return const LoadingIndicator();
            }
            if (provider.state == ViewState.error) {
              return StatusMessage.error(
                title: provider.errorMessage ?? 'Connection failed',
                onRetry: () => provider.connect(widget.batchId),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: fabPadding),
              child: Column(
                children: [
                  Divider(color: dividerColor),
                  Text(
                    'Live Commuter Log',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Divider(color: dividerColor),
                  if (provider.commuters.isEmpty)
                    const StatusMessage(
                      icon: Icons.hourglass_empty,
                      title: 'Waiting for commuter data...',
                    )
                  else ...[
                    _buildControls(provider),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.commuters.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final commuter = provider.commuters[index];
                        return _buildCommuterTile(provider, commuter);
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _stopTrip,
        label: const Text('STOP TRIP'),
        icon: const Icon(Icons.stop_circle_outlined),
        backgroundColor: AppColors.acRed,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildControls(D2dChannelProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement call admin functionality.
            },
            icon: const Icon(Icons.call),
            label: const Text('Call Admin'),
          ),
          Icon(
            Icons.circle,
            color: provider.commuters.isNotEmpty
                ? AppColors.acGreen
                : AppColors.acRed,
          ),
          ElevatedButton.icon(
            onPressed: provider.toggleSortOrder,
            icon: const Icon(Icons.sort),
            label: Text(provider.isAscending ? 'Asc' : 'Desc'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommuterTile(
    D2dChannelProvider provider,
    D2dCommuterModel commuter,
  ) {
    return Slidable(
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (commuter.userId?.id != null) {
                provider.denyCommuter(commuter.userId!.id.toString());
              }
            },
            backgroundColor: AppColors.acRed,
            icon: Icons.do_not_disturb_on,
            label: 'No Show',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (commuter.userId?.id != null) {
                provider.confirmCommuter(commuter.userId!.id.toString());
              }
            },
            backgroundColor: AppColors.acGreen,
            icon: Icons.check_circle_outline,
            label: 'Boarded',
          ),
        ],
      ),
      child: Card(
        color: AppColors.acBlack,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.acYellowWarm,
            child: Text(
              commuter.inLine?.toString() ?? '?',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            commuter.userId?.username ?? 'N/A',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            commuter.popId?.pickUpPointName ?? 'N/A',
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: IconButton(
            tooltip: 'Call commuter',
            onPressed: () => _makePhoneCall(commuter.userId?.mobileNumber),
            icon: const Icon(Icons.call, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
