import 'package:cts/app/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:cts/appManager/snackbar_service.dart';
import 'package:cts/appManager/view_state.dart';
import 'package:cts/features/auth/providers/sign_up_sign_in_controller.dart';
import 'package:cts/utils/validators.dart';
import 'package:cts/widgets/provider_listener.dart';
import 'package:cts/widgets/common_button.dart';
import 'package:cts/widgets/common_text_formfield.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _listenToSignUpState(BuildContext context, SignUpProvider provider) {
    if (provider.state == ViewState.error) {
      SnackBarService.showErrorSnackbar(
        provider.errorMessage ?? 'An unknown error occurred.',
      );
    } else if (provider.state == ViewState.success) {
      SnackBarService.showsSuccessSnackbar(
        'Registration successful! Please sign in.',
        '',
      );
      if (mounted) {
        context.go(RouteName.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context);
    final scheme = Theme.of(context).colorScheme;

    return ProviderListener<SignUpProvider>(
      provider: signUpProvider,
      onChange: _listenToSignUpState,
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
                      _buildNameField(signUpProvider, scheme),
                      const SizedBox(height: 16.0),
                      _buildMobileField(signUpProvider, scheme),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(signUpProvider, scheme),
                      const SizedBox(height: 16.0),
                      _buildConfirmPasswordField(signUpProvider, scheme),
                      const SizedBox(height: 32.0),
                      _buildRegisterButton(signUpProvider, scheme),
                      const SizedBox(height: 24.0),
                      _buildSignInLink(signUpProvider, scheme),
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
          'Create Account',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Join our community and get started',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: onSurfaceMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildNameField(SignUpProvider provider, ColorScheme scheme) {
    return CommonTextFormField(
      controller: provider.nameCtrl,
      enabled: provider.state != ViewState.loading,
      hintText: 'Full Name',
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      prefixIcon: Icon(Icons.person_outline, color: scheme.onSurface),
      validator: (value) => Validators.name(value),
      obscureText: false,
    );
  }

  Widget _buildMobileField(SignUpProvider provider, ColorScheme scheme) {
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
      validator: (value) => Validators.mobileNumber(value),
      obscureText: false,
    );
  }

  Widget _buildPasswordField(SignUpProvider provider, ColorScheme scheme) {
    return CommonTextFormField(
      controller: provider.passwordCtrl,
      enabled: provider.state != ViewState.loading,
      hintText: 'Password',
      obscureText: !_isPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
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

  Widget _buildConfirmPasswordField(
    SignUpProvider provider,
    ColorScheme scheme,
  ) {
    return CommonTextFormField(
      controller: _confirmPasswordController,
      enabled: provider.state != ViewState.loading,
      hintText: 'Confirm Password',
      obscureText: !_isConfirmPasswordVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      prefixIcon: Icon(Icons.lock_outline, color: scheme.onSurface),
      suffixIcon: IconButton(
        tooltip:
            _isConfirmPasswordVisible ? 'Hide password' : 'Show password',
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
          color: scheme.onSurface,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != provider.passwordCtrl.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton(SignUpProvider provider, ColorScheme scheme) {
    return CommonPrimaryButton(
      label: provider.state == ViewState.loading ? 'REGISTERING...' : 'REGISTER',
      fontSize: 18,
      onPressed: provider.state == ViewState.loading
          ? null
          : () {
              if (_formKey.currentState?.validate() ?? false) {
                provider.signUp();
              }
            },
      backgroundColor: scheme.inverseSurface,
      textColor: scheme.onInverseSurface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: BorderRadius.circular(8),
    );
  }

  Widget _buildSignInLink(SignUpProvider provider, ColorScheme scheme) {
    final onSurfaceMuted = scheme.onSurface.withValues(alpha: 0.6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Already have an account? ',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: onSurfaceMuted,
                ),
          ),
        ),
        TextButton(
          onPressed: provider.state == ViewState.loading
              ? null
              : () => context.go(RouteName.signIn),
          child: Text(
            'Sign In',
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
