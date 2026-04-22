import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../domain/auth_enums.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import '../../../core/widgets/auth_text_field.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/role_segmented_control.dart';

/// Stage 2: Universal Login
/// Matches the universal_login.png design:
/// - Logo + "Welcome Back" heading
/// - Role segmented control (Citizen | Responder | Admin)
/// - Email + Password fields
/// - Forgot Password link
/// - Sign In button (Emergency Red)
/// - Verify Email link
/// - "New to the framework? Request Access" signup link
/// - Footer with legal links
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.citizen;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        if (state.status == AuthStatus.authenticated) {
          // Show success toast
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage ?? 'Login Successful'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 1),
            ),
          );
          // Navigate to role-specific splash
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              context.go('/role-splash/${state.selectedRole.name}');
            }
          });
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
                      // App brand header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '✳',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Rapid Aid',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

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
                            // Icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '✳',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Welcome Back',
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Access your critical dashboard',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurface.withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Access Level label
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ACCESS LEVEL',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            RoleSegmentedControl(
                              selectedRole: _selectedRole,
                              onRoleChanged: (role) {
                                setState(() => _selectedRole = role);
                              },
                            ),
                            const SizedBox(height: 24),

                            // Email field
                            AuthTextField(
                              label: '',
                              hintText: 'Email Address',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Password field
                            AuthTextField(
                              label: '',
                              hintText: 'Password',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurface.withOpacity(0.4),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.go('/forgot-password'),
                                child: Text(
                                  'Forgot Password?',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: cs.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In button
                            ActionButton(
                              label: 'Sign In  →',
                              isEmergency: true,
                              isLoading: isLoading,
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                      AuthLoginRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                        role: _selectedRole,
                                      ),
                                    );
                              },
                            ),
                            const SizedBox(height: 20),

                            // Verify email
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'Verify Email',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: cs.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Divider using surface shift (no hard line)
                            Container(
                              height: 1,
                              color: cs.surfaceContainerLow,
                            ),
                            const SizedBox(height: 16),

                            // Sign up redirect
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New to the framework? ',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                    color: cs.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/signup'),
                                  child: Text(
                                    'Request Access',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontSize: 14,
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Footer
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 24,
                        children: [
                          Text(
                            'TERMS OF SERVICE',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'PRIVACY POLICY',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'CONTACT SUPPORT',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                              letterSpacing: 1.0,
                            ),
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
