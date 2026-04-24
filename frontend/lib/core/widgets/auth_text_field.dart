import 'package:flutter/material.dart';

/// Minimalist text field with surfaceContainerHigh fill
/// and primary-token bottom-stroke only on focus.
/// Adheres to the "No-Line" rule: no 1px borders at rest.
class AuthTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool forceLowercase;
  final Function(bool)? onErrorStateChanged;

  const AuthTextField({
    Key? key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.forceLowercase = false,
    this.onErrorStateChanged,
  }) : super(key: key);

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasLowercaseError = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    
    if (widget.forceLowercase && widget.controller != null) {
      widget.controller!.addListener(_validateLowercase);
    }
  }

  void _validateLowercase() {
    final text = widget.controller!.text;
    final hasError = text.isNotEmpty && text != text.toLowerCase();
    if (_hasLowercaseError != hasError) {
      setState(() => _hasLowercaseError = hasError);
      if (widget.onErrorStateChanged != null) {
        widget.onErrorStateChanged!(hasError);
      }
    }
  }

  @override
  void dispose() {
    if (widget.forceLowercase && widget.controller != null) {
      widget.controller!.removeListener(_validateLowercase);
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 0.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(
                color: _hasLowercaseError 
                    ? const Color(0xFFD32F2F) // Emergency Red
                    : (_isFocused ? cs.primary : Colors.transparent),
                width: 2.5,
              ),
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurface.withOpacity(0.4),
              ),
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
