import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/action_button.dart';

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

  @override
  void dispose() {
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        if (state.status == AuthStatus.resetSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Reset link sent'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand centered
                            Center(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '✳',
                                        style: TextStyle(
                                          fontSize: 28,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rapid Aid',
                                        style:
                                            theme.textTheme.titleLarge?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Red accent bar
                                  Container(
                                    width: 48,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: cs.tertiary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            Text(
                              'Forgot Password',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your email to receive a secure password reset link.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurface.withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Email field
                            AuthTextField(
                              label: '',
                              hintText: 'name@organization.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),

                            // Send Reset Link
                            ActionButton(
                              label: 'Send Reset Link',
                              icon: Icons.history,
                              isEmergency: true,
                              isLoading: isLoading,
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      AuthForgotPasswordRequested(
                                        email: _emailController.text.trim(),
                                      ),
                                    );
                              },
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '© 2024 RAPID AID FRAMEWORK. CLINICAL PRECISION SYSTEM.',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.35),
                                letterSpacing: 0.8,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Wrap(
                            spacing: 16,
                            children: [
                              Text(
                                'PRIVACY POLICY',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.4),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'TERMS OF SERVICE',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.4),
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                'SECURITY PROTOCOL',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.4),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
