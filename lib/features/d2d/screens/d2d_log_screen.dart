import 'package:cts/api/api_list.dart';
import 'package:cts/api/base_api_services.dart';
import 'package:cts/appManager/colors.dart';
import 'package:cts/appManager/functions_and_tools.dart';
import 'package:cts/app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/d2d/providers/d2d_channel_provider.dart';
import 'package:cts/features/d2d/widgets/d2d_live_widgets.dart';
import 'package:cts/features/drivers/providers/driver_home_provider.dart';
import 'package:cts/widgets/admin_form_header.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/brand_app_bar.dart';
import 'package:cts/widgets/loading_indicator.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _PreConnectTripState { unknown, none, active, ended }

class D2DLogScreen extends StatefulWidget {
  const D2DLogScreen({super.key, required this.batchId});

  final String batchId;

  @override
  State<D2DLogScreen> createState() => _D2DLogScreenState();
}

class _D2DLogScreenState extends State<D2DLogScreen> {
  D2dChannelProvider? _d2dProvider;
  _PreConnectTripState _preConnectState = _PreConnectTripState.unknown;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<D2dChannelProvider>();
    if (!identical(_d2dProvider, provider)) {
      _d2dProvider?.removeListener(_onD2dProviderChanged);
      _d2dProvider = provider;
      _d2dProvider!.addListener(_onD2dProviderChanged);
    }
  }

  void _onD2dProviderChanged() {
    final message = _d2dProvider?.actionErrorMessage;
    if (message == null || !mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
    _d2dProvider?.clearActionError();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final driverHome = context.read<DriverHomeProvider>();
      if (driverHome.driverProfile == null) {
        driverHome.fetchDriverProfile();
      }
      _fetchPreConnectStatus();
      _d2dProvider?.connect(widget.batchId);
    });
  }

  Future<void> _fetchPreConnectStatus() async {
    try {
      final response = await context.read<BaseApiServices>().getApi(
            '${ApiUrl.d2dLogStatus}${widget.batchId}',
          );
      if (!mounted) return;

      if (response is! Map) {
        setState(() => _preConnectState = _PreConnectTripState.none);
        return;
      }

      final map = Map<String, dynamic>.from(response);
      final status = map['status']?.toString();
      final isActive = map['is_active'] == true;

      setState(() {
        if (status == 'ended' || !isActive) {
          _preConnectState = _PreConnectTripState.ended;
        } else {
          _preConnectState = _PreConnectTripState.active;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _preConnectState = _PreConnectTripState.none);
    }
  }

  @override
  void dispose() {
    _d2dProvider?.removeListener(_onD2dProviderChanged);
    _d2dProvider?.disconnect(notify: false);
    super.dispose();
  }

  String? _adminMobile(BuildContext context) {
    final driverProfile = context.read<DriverHomeProvider>().driverProfile;
    final fromProfile = driverProfile?.adminCode?.userId?.mobileNumber;
    if (fromProfile != null && fromProfile.isNotEmpty) {
      return fromProfile;
    }

    final fromChannel =
        context.read<D2dChannelProvider>().driver?.adminCode?.userId?.mobileNumber;
    if (fromChannel != null && fromChannel.isNotEmpty) {
      return fromChannel;
    }

    return null;
  }

  Future<void> _callAdmin() async {
    final mobile = _adminMobile(context);
    if (mobile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin contact is not available yet.'),
        ),
      );
      return;
    }

    final launched = await calling(mobile);
    if (!mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer.')),
    );
  }

  Future<void> _callCommuter(String? mobile) async {
    if (mobile == null || mobile.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commuter contact is not available.')),
      );
      return;
    }

    final launched = await calling(mobile);
    if (!mounted || launched) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open the phone dialer.')),
    );
  }

  void _stopTrip() {
    _d2dProvider?.stopTrip();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteName.driverHomeScreen);
    }
  }

  Widget _buildPreConnectBadge(BuildContext context) {
    if (_preConnectState == _PreConnectTripState.unknown ||
        _preConnectState == _PreConnectTripState.none) {
      return const SizedBox.shrink();
    }

    final isEnded = _preConnectState == _PreConnectTripState.ended;
    final color = isEnded ? AppColors.acRed : AppColors.acGreen;
    final label = isEnded ? 'TRIP ENDED TODAY' : 'TRIP ACTIVE';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripContent(
    BuildContext context,
    D2dChannelProvider provider,
    double fabPadding,
  ) {
    final isLive = provider.commuters.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, fabPadding),
      children: [
        D2dTripHeader(
          title: 'Live Commuter Log',
          subtitle: 'Batch #${widget.batchId}',
          isLive: isLive,
        ),
        _buildPreConnectBadge(context),
        D2dLiveControlsBar(
          callLabel: 'Call Admin',
          onCall: _callAdmin,
          isLive: isLive,
          isAscending: provider.isAscending,
          onToggleSort: provider.toggleSortOrder,
        ),
        const SizedBox(height: 16),
        if (provider.commuters.isEmpty)
          const StatusMessage(
            icon: Icons.hourglass_empty_rounded,
            title: 'Waiting for commuter data...',
            message: 'Riders will appear here as they board.',
          )
        else ...[
          Text(
            '${provider.commuters.length} commuter${provider.commuters.length == 1 ? '' : 's'} on trip',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < provider.commuters.length; i++) ...[
            D2dDriverCommuterTile(
              commuter: provider.commuters[i],
              provider: provider,
              onCall: () => _callCommuter(provider.commuters[i].mobileNumber),
            ),
            if (i < provider.commuters.length - 1) const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final fabPadding = d2dFabScrollPadding(context);

    return Scaffold(
      appBar: const BrandAppBar(),
      drawer: const AppDrawer(),
      body: SafeArea(
        top: false,
        child: Consumer<D2dChannelProvider>(
          builder: (context, provider, child) {
            if (provider.state == ViewState.loading) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  D2dTripHeader(
                    title: 'Live Commuter Log',
                    subtitle: 'Batch #${widget.batchId}',
                    isLive: false,
                  ),
                  _buildPreConnectBadge(context),
                  const SizedBox(height: 24),
                  const LoadingIndicator(),
                ],
              );
            }
            if (provider.state == ViewState.error) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  D2dTripHeader(
                    title: 'Live Commuter Log',
                    subtitle: 'Batch #${widget.batchId}',
                    isLive: false,
                  ),
                  _buildPreConnectBadge(context),
                  const SizedBox(height: 24),
                  StatusMessage.error(
                    title: provider.errorMessage ?? 'Connection failed',
                    onRetry: provider.isTripEnded
                        ? null
                        : () => provider.connect(widget.batchId),
                  ),
                ],
              );
            }

            return _buildTripContent(context, provider, fabPadding);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _stopTrip,
        label: const Text('STOP TRIP'),
        icon: const Icon(Icons.stop_circle_outlined),
        backgroundColor: AppColors.acRed,
        foregroundColor: AppColors.acWhite,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
