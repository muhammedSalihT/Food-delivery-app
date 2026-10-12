import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/api_constants.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(
    text: ApiConstants.demoUsername,
  );
  final _passwordController = TextEditingController(
    text: ApiConstants.demoPassword,
  );
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: AppColors.loginHeaderYellow,
      body: Column(
        children: [
          // ── Yellow Header with Back Button and Title ──
          const SizedBox(height: 30),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.loginButtonOrange,
                        size: 34,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                  ),
                  const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),

          // ── White Rounded Container Card ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.loginCardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Delivery Logo
                      Center(
                        child: Container(
                          width: 84,
                          height: 84,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE85324).withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Welcome title
                      const Text(
                        'Welcome',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.loginDarkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle lorem ipsum
                      const Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.loginSubText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Error message banner if authentication fails
                      if (authState.status == AuthStatus.error &&
                          authState.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.errorMessage!,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Email or Mobile Number Label
                      const Text(
                        'Email or Mobile Number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.loginDarkText,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Username / Email input field
                      TextFormField(
                        key: const Key('login_username_field'),
                        controller: _usernameController,
                        enabled: !isLoading,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.loginDarkText,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'example@example.com',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: AppColors.loginDarkText.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          fillColor: AppColors.loginFieldBg,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.loginButtonOrange,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),

                      // Password Label
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.loginDarkText,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Password input field
                      TextFormField(
                        key: const Key('login_password_field'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.loginDarkText,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: '*************',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: AppColors.loginDarkText.withValues(
                              alpha: 0.5,
                            ),
                            letterSpacing: 1.5,
                          ),
                          fillColor: AppColors.loginFieldBg,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.loginButtonOrange,
                              size: 22,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.loginButtonOrange,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Forget Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forget Password',
                            style: TextStyle(
                              color: AppColors.loginForgotColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Log In Pill Button
                      Center(
                        child: SizedBox(
                          width: 250,
                          height: 52,
                          child: ElevatedButton(
                            key: const Key('login_submit_button'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.loginButtonOrange,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // "or sign up with"
                      const Center(
                        child: Text(
                          'or sign up with',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.loginSubText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Social Buttons Row (Google, Facebook, Fingerprint)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialCircle(
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.loginSocialIconColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          _buildSocialCircle(
                            child: const Icon(
                              Icons.facebook_rounded,
                              size: 26,
                              color: AppColors.loginSocialIconColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          _buildSocialCircle(
                            child: const Icon(
                              Icons.fingerprint_rounded,
                              size: 26,
                              color: AppColors.loginSocialIconColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Don't have an account? Sign Up
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.loginSubText,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.loginButtonOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCircle({required Widget child}) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.loginSocialCircleBg,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}
