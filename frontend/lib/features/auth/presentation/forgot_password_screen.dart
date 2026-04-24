import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

/// Forgot Password screen matching forgot_password_screen.png.
/// - Logo + Red accent bar
/// - "Forgot Password" heading
/// - Email field
/// - "Send Reset Link" Emergency Red button
/// - "← Return to Login" link
/// - Footer with legal links
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final text = _emailController.text;
    final regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    setState(() {
      _isEmailValid = text.trim().isNotEmpty && regex.hasMatch(text.trim());
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.errorMessage != null) {
          final isNotFound = state.errorMessage == 'Email not found. Please check and try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  if (isNotFound) ...[
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(state.errorMessage!)),
                ],
              ),
              backgroundColor: isNotFound ? const Color(0xFFD32F2F) : cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state.status == AuthStatus.resetSent) {
          context.go('/verify-code', extra: _emailController.text);
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Brand
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const RapidAidLogo(),
                                const SizedBox(width: 10),
                                Text(
                                  'Rapid Aid',
                                  style: theme.textTheme.headlineLarge?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Main card
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 440),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Forgot Password',
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Enter your email to receive a secure password reset link.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.onSurface.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email field
                            AuthTextField(
                              label: '',
                              hintText: 'name@organization.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              forceLowercase: true,
                            ),
                            const SizedBox(height: 24),

                            // Send Reset Link
                            ActionButton(
                              label: 'Send Reset Link',
                              icon: Icons.history,
                              isEmergency: true,
                              isLoading: isLoading,
                              onPressed: _isEmailValid
                                  ? () {
                                      final email = _emailController.text.trim();
                                      if (email.isNotEmpty && email != email.toLowerCase()) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Email must be in strictly lowercase letters.'),
                                            backgroundColor: cs.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      context.read<AuthBloc>().add(
                                            AuthForgotPasswordRequested(
                                              email: email,
                                            ),
                                          );
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // Return to Login
                            Center(
                              child: GestureDetector(
                                onTap: () => context.go('/login'),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_back,
                                      size: 16,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Return to Login',
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 14,
                                        color: cs.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              '© 2026 RAPID AID.   AI AIDED EMERGENCY RESPONSE SYSTEM',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.35),
                                letterSpacing: 0.8,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
