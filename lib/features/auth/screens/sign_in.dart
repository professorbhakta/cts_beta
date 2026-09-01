import 'package:cts/app/router/route_names.dart';
import 'package:cts/app/router/session_auth_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/widgets/provider_listener.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/common_text_formfield.dart';
import 'package:cts/widgets/cts_brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  Future<void> _listenToLoginState(
    BuildContext context,
    SignInProvider provider,
  ) async {
    if (provider.state == ViewState.error) {
      SnackBarService.showErrorSnackbar(
        provider.errorMessage ?? 'An unknown error occurred.',
      );
    } else if (provider.state == ViewState.success) {
      if (!mounted) return;
      final route = switch (provider.userType) {
        'ADMIN' => RouteName.adminHomeScreen,
        'DRIVER' => RouteName.driverHomeScreen,
        'COMMUTER' => RouteName.commuterHomeScreen,
        _ => RouteName.signIn,
      };
      if (route == RouteName.signIn) {
        SnackBarService.showErrorSnackbar('Could not determine user type.');
      }
      await context.read<SessionAuthNotifier>().refresh();
      if (!context.mounted) return;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Cream page via theme (scaffoldBackground / surfaceContainerHighest).
    final cream = theme.scaffoldBackgroundColor;

    return ProviderListener<SignInProvider>(
      provider: signInProvider,
      onChange: _listenToLoginState,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: theme.brightness,
        ),
        child: Scaffold(
          backgroundColor: cream,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal =
                    constraints.maxWidth >= 600 ? 32.0 : 24.0;

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(horizontal, 28, horizontal, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: CtsBrandLogo(height: 48),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Sign in',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use your mobile number and password.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Mobile',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildMobileField(signInProvider, scheme),
                            const SizedBox(height: 16),
                            Text(
                              'Password',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildPasswordField(signInProvider, scheme),
                            const SizedBox(height: 28),
                            _buildLoginButton(signInProvider, scheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField(SignInProvider provider, ColorScheme scheme) {
    return CommonTextFormField(
      controller: provider.mobileCtrl,
      enabled: provider.state != ViewState.loading,
      hintText: '10-digit mobile number',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      prefixIcon: Icon(Icons.phone_android, color: scheme.onSurfaceVariant),
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your mobile number';
        }
        if (value.length != 10) {
          return 'Mobile number must be 10 digits';
        }
        return null;
      },
      obscureText: false,
    );
  }

  Widget _buildPasswordField(SignInProvider provider, ColorScheme scheme) {
    return CommonTextFormField(
      controller: provider.passwordCtrl,
      enabled: provider.state != ViewState.loading,
      hintText: 'Password',
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurfaceVariant),
      suffixIcon: IconButton(
        tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: scheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      validator: (value) => Validators.password(value),
    );
  }

  Widget _buildLoginButton(SignInProvider provider, ColorScheme scheme) {
    // Yellow primary from theme — do not invent hexes.
    return CommonPrimaryButton(
      label: provider.state == ViewState.loading ? 'LOGGING IN...' : 'LOGIN',
      fontSize: 16,
      isLoading: provider.state == ViewState.loading,
      onPressed: provider.state == ViewState.loading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                provider.login();
              }
            },
      backgroundColor: scheme.primary,
      textColor: scheme.onPrimary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(4),
    );
  }
}
