import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:cts/appManager/app_class.dart';
import 'package:cts/features/splash/providers/splash_provider.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:cts/widgets/provider_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SessionAuthNotifier>().refresh(validateWithServer: true);
      if (!mounted) return;
      // Runtime permissions (incl. camera for odometer + QR) — not shown at install.
      await AppManager.instance.getPermissions();
      if (!mounted) return;
      await context.read<SplashProvider>().determineInitialRoute();
    });
  }

  void _listenToSplashState(BuildContext context, SplashProvider provider) {
    final route = provider.initialRoute;
    if (route != null) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final splashProvider = Provider.of<SplashProvider>(context);
    final scheme = Theme.of(context).colorScheme;

    return ProviderListener<SplashProvider>(
      provider: splashProvider,
      onChange: _listenToSplashState,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: scheme.onSurface,
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CtsBrandLogo(height: 100),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to c2s',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onInverseSurface,
                        ),
                  ),
                  const SizedBox(height: 48),
                  CircularProgressIndicator(
                    color: scheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
