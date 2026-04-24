import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import '../../../core/widgets/action_button.dart';
import '../../../core/widgets/rapid_aid_logo.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final int _codeLength = 6;
  final List<FocusNode> _focusNodes = [];
  final List<TextEditingController> _controllers = [];

  int _focusedIndex = -1;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _codeLength; i++) {
      _focusNodes.add(FocusNode());
      _controllers.add(TextEditingController());

      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _focusedIndex = i;
          });
        }
      });
    }
    _startTimer();

    // Autofocus first box
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    });
  }

  void _startTimer() {
    setState(() => _resendTimer = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty) {
      if (index < _codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        setState(() => _focusedIndex = -1);
        _submitCode(); // Auto-Submit
      }
    }
  }

  void _submitCode() {
    final code = _controllers.map((c) => c.text).join().trim();
    if (code.length == _codeLength) {
      context.read<AuthBloc>().add(
            AuthVerifyResetCodeRequested(email: widget.email, code: code),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the full 6-digit code.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
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
        if (state.status == AuthStatus.codeVerified) {
          final code = _controllers.map((c) => c.text).join();
          context.go('/reset-password',
              extra: {'email': widget.email, 'code': code});
        }
        if (state.status == AuthStatus.resetSent) {
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('A new code has been sent to ${widget.email}'),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: cs.onSurface),
              onPressed: () => context.go('/forgot-password'),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Brand
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
                      const SizedBox(height: 60),

                      // Title & Subtitle
                      Text(
                        'ACCOUNT VERIFICATION',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.8),
                          letterSpacing: 2.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'A 6-digit verification code has been sent to\n${widget.email}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Code partition boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_codeLength, (index) {
                          final isFocused = _focusedIndex == index;
                          return Container(
                            width: 45,
                            height: 55,
                            margin: EdgeInsets.symmetric(
                                horizontal: index == 2 ? 12 : 4),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              border: Border(
                                bottom: BorderSide(
                                  color: isFocused
                                      ? cs.primary
                                      : cs.surfaceContainerHighest,
                                  width: isFocused ? 2.5 : 1.0,
                                ),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Focus(
                              onKeyEvent: (node, event) {
                                if (event is KeyDownEvent &&
                                    event.logicalKey ==
                                        LogicalKeyboardKey.backspace) {
                                  if (_controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                    return KeyEventResult.handled;
                                  }
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                maxLength: 1,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                readOnly: isLoading,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onChanged: (value) =>
                                    _onDigitEntered(index, value),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      ActionButton(
                        label: 'Verify Code  →',
                        isEmergency: false,
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_controllers
                                    .where((c) => c.text.isEmpty)
                                    .isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Please enter the full 6-digit code.'),
                                      backgroundColor: cs.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _submitCode();
                              },
                      ),
                      const SizedBox(height: 24),

                      // Resend Code logic
                      TextButton(
                        onPressed: _resendTimer == 0 && !isLoading
                            ? () {
                                context.read<AuthBloc>().add(
                                      AuthForgotPasswordRequested(
                                          email: widget.email),
                                    );
                              }
                            : null,
                        child: Text(
                          _resendTimer > 0
                              ? 'Resend Code in 00:${_resendTimer.toString().padLeft(2, '0')}'
                              : 'Resend Recovery Code',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _resendTimer == 0
                                ? cs.primary
                                : cs.onSurface.withOpacity(0.4),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
