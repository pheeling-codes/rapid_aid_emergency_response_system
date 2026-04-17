import 'package:flutter/material.dart';

class RapidAidButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isLoading;

  const RapidAidButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<RapidAidButton> createState() => _RapidAidButtonState();
}

class _RapidAidButtonState extends State<RapidAidButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 100),
    );
    // Subtle scaleDown (98%) animation on press/hover
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final backgroundColor = widget.isPrimary ? colorScheme.primary : colorScheme.surfaceContainerLow;
    final textColor = widget.isPrimary ? Colors.white : colorScheme.onSurface;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: MouseRegion(
        onEnter: (_) => _controller.forward(),
        onExit: (_) => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56), // Min-height: 56px
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24), // 1.5rem (xl)
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: widget.isLoading 
              ? SizedBox(
                  width: 24, height: 24, 
                  child: CircularProgressIndicator(color: textColor, strokeWidth: 2.5)
                )
              : Text(
                  widget.label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontSize: 18,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
