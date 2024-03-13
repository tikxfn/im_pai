import 'package:flutter/material.dart';

class AnimatedFadeOut extends StatefulWidget {
  final int animatedTime;
  final Widget child;

  const AnimatedFadeOut({
    this.animatedTime = 500,
    required this.child,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _AnimatedFadeOutState();
  }
}

class _AnimatedFadeOutState extends State<AnimatedFadeOut>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: widget.animatedTime),
    vsync: this,
  )..forward();

  late final Animation<double> _animation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
