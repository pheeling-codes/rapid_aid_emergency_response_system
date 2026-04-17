import 'package:flutter/material.dart';

class RapidAidInput extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const RapidAidInput({
    Key? key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<RapidAidInput> createState() => _RapidAidInputState();
}

class _RapidAidInputState extends State<RapidAidInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        // Bottom stroke only during the focused state using the primary token
        border: Border(
          bottom: BorderSide(
            color: _isFocused ? theme.colorScheme.primary : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscureText,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
