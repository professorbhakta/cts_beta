import 'dart:async';

import 'package:cts/features/commuters/constants/fleet_tracking_mobile_css.dart';
import 'package:cts/features/commuters/constants/fleet_tracking_urls.dart';
import 'package:cts/widgets/app_drawer.dart';
import 'package:cts/widgets/status_message.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// In-app live cab tracking via Tata Motors Fleet Edge.
class TrackCabScreen extends StatefulWidget {
  const TrackCabScreen({super.key, this.vehicleId});

  /// Optional fleet tracking vehicle id; falls back to [FleetTrackingUrls.defaultVehicleId].
  final String? vehicleId;

  @override
  State<TrackCabScreen> createState() => _TrackCabScreenState();
}

class _TrackCabScreenState extends State<TrackCabScreen> {
  static const _mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 14; K) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

  static final _mobileLayoutScript = FleetTrackingMobileCss.injectionScript(
    cssRules: FleetTrackingMobileCss.overrideRules,
    viewportWidth: FleetTrackingMobileCss.mobileViewportWidth,
  );

  WebViewController? _controller;
  late final String _trackingUrl;

  var _isLoading = true;
  var _loadProgress = 0;
  var _webViewReady = false;
  var _needsViewportReload = true;
  var _browserPromptShown = false;
  String? _errorMessage;

  Timer? _browserPromptTimer;
  static const _browserPromptDelay = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _trackingUrl = FleetTrackingUrls.trackingUrl(vehicleId: widget.vehicleId);
    _initWebView();
    _browserPromptTimer = Timer(_browserPromptDelay, _showBrowserPromptIfNeeded);
  }

  @override
  void dispose() {
    _browserPromptTimer?.cancel();
    super.dispose();
  }
  Future<void> _initWebView() async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0xFFF5F5F5));
    await controller.enableZoom(true);

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setUserAgent(_mobileUserAgent);
      await androidController.setUseWideViewPort(false);
      await androidController.setTextZoom(100);
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    } else if (controller.platform is WebKitWebViewController) {
      await (controller.platform as WebKitWebViewController)
          .setUserAgent(_mobileUserAgent);
    }

    controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          if (!mounted) return;
          setState(() => _loadProgress = progress);
        },
        onPageStarted: (_) {
          if (!mounted) return;
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        },
        onPageFinished: (_) => _handlePageFinished(controller),
        onWebResourceError: (error) {
          if (!mounted) return;
          if (error.isForMainFrame ?? false) {
            setState(() {
              _isLoading = false;
              _errorMessage = error.description;
            });
          }
        },
      ),
    );

    await _loadTrackingPage(controller);

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _webViewReady = true;
    });
  }

  Future<void> _loadTrackingPage(WebViewController controller) {
    return controller.loadRequest(
      Uri.parse(_trackingUrl),
      headers: const {'User-Agent': _mobileUserAgent},
    );
  }

  Future<void> _handlePageFinished(WebViewController controller) async {
    if (!mounted) return;

    if (_needsViewportReload) {
      _needsViewportReload = false;
      await controller.runJavaScript(_mobileLayoutScript);
      await controller.reload();
      return;
    }

    await _applyMobileLayoutFixes(controller);
    setState(() => _isLoading = false);
  }

  Future<void> _applyMobileLayoutFixes(WebViewController controller) async {
    await controller.runJavaScript(_mobileLayoutScript);
    for (final delay in const [400, 1200, 2500]) {
      await Future<void>.delayed(Duration(milliseconds: delay));
      if (!mounted) return;
      await controller.runJavaScript(_mobileLayoutScript);
    }
  }

  Future<void> _reloadTrackingPage() async {
    final controller = _controller;
    if (controller == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _needsViewportReload = true;
    });
    await _loadTrackingPage(controller);
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(_trackingUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open tracking page')),
      );
    }
  }

  void _showBrowserPromptIfNeeded() {
    if (!mounted || _browserPromptShown) return;
    _browserPromptShown = true;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('Open in browser?'),
          content: Text(
            'Live cab tracking may look better in your phone browser. '
            'You can open it there or stay on this page.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _openInBrowser();
              },
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: const Text('Open in browser'),
            ),
          ],
        );
      },
    );
  }
  Widget _buildWebView() {
    final controller = _controller!;

    PlatformWebViewWidgetCreationParams params =
        PlatformWebViewWidgetCreationParams(
      controller: controller.platform,
      layoutDirection: TextDirection.ltr,
    );

    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewWidgetCreationParams
          .fromPlatformWebViewWidgetCreationParams(
        params,
        displayWithHybridComposition: true,
      );
    } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewWidgetCreationParams
          .fromPlatformWebViewWidgetCreationParams(params);
    }

    return WebViewWidget.fromPlatformCreationParams(params: params);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Track your Cab'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Open menu',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading || !_webViewReady ? null : _reloadTrackingPage,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Open in browser',
            onPressed: _openInBrowser,
            icon: const Icon(Icons.open_in_browser_rounded),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isLoading && _loadProgress < 100)
            LinearProgressIndicator(
              value: _loadProgress == 0 ? null : _loadProgress / 100,
              minHeight: 3,
              backgroundColor: scheme.surfaceContainerHighest,
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return ColoredBox(
        color: const Color(0xFFF5F5F5),
        child: StatusMessage.error(
          title: 'Unable to load tracking page',
          message: _errorMessage!,
          onRetry: _reloadTrackingPage,
        ),
      );
    }

    if (!_webViewReady || _controller == null) {
      return const ColoredBox(
        color: Color(0xFFF5F5F5),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: _buildWebView(),
    );
  }
}
