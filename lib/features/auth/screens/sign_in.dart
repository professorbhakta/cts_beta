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
import 'package:flutter/foundation.dart';
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

  Future<void> _listenToLoginState(BuildContext context, SignInProvider provider) async {
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
    final scheme = Theme.of(context).colorScheme;

    return ProviderListener<SignInProvider>(
      provider: signInProvider,
      onChange: _listenToLoginState,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
          statusBarBrightness: Theme.of(context).brightness,
        ),
        child: Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(scheme),
                      const SizedBox(height: 48.0),
                      _buildMobileField(signInProvider, scheme),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(signInProvider, scheme),
                      const SizedBox(height: 32.0),
                      _buildLoginButton(signInProvider, scheme),
                      const SizedBox(height: 24.0),
                      _buildSignUpLink(scheme),
                      if (kDebugMode) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.push(
                              RouteName.designWireframeGallery,
                            ),
                            child: Text(
                              'Preview UI wireframes (debug)',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    final onSurfaceMuted = scheme.onSurface.withValues(alpha: 0.6);

    return Column(
      children: [
        Image.asset(
          'assets/images/c2s.png',
          height: 100,
        ),
        const SizedBox(height: 24.0),
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: onSurfaceMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildMobileField(SignInProvider provider, ColorScheme scheme) {
    return CommonTextFormField(
      controller: provider.mobileCtrl,
      enabled: provider.state != ViewState.loading,
      hintText: 'Mobile Number',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      prefixIcon: Icon(Icons.phone_android, color: scheme.onSurface),
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
      prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurface),
      suffixIcon: IconButton(
        tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
        icon: Icon(
          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: scheme.onSurface,
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
    return CommonPrimaryButton(
      label: provider.state == ViewState.loading ? 'LOGGING IN...' : 'LOGIN',
      fontSize: 18,
      onPressed: provider.state == ViewState.loading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                provider.login();
              }
            },
      backgroundColor: scheme.inverseSurface,
      textColor: scheme.onInverseSurface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildSignUpLink(ColorScheme scheme) {
    final onSurfaceMuted = scheme.onSurface.withValues(alpha: 0.6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Not registered yet? ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: onSurfaceMuted,
                ),
          ),
        ),
        TextButton(
          onPressed: () => context.push(RouteName.signUp),
          child: Text(
            'Create an account',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
