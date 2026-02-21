import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final Color? dotColor;
  final double dotSize;

  const TypingIndicator({
    super.key,
    this.dotColor,
    this.dotSize = 6.0,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim1;
  late Animation<double> _anim2;
  late Animation<double> _anim3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _anim1 = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 4),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _anim2 = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 3),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _anim3 = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 2),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, animation.value),
          child: Container(
            width: widget.dotSize,
            height: widget.dotSize,
            decoration: BoxDecoration(
              color: widget.dotColor ??
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(_anim1),
          const SizedBox(width: 4),
          _buildDot(_anim2),
          const SizedBox(width: 4),
          _buildDot(_anim3),
        ],
      ),
    );
  }
}
