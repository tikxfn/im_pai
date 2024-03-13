import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const MarqueeText({required this.text, this.style, super.key});

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Animation<double>? _animation;
  final GlobalKey _textKey = GlobalKey();
  final GlobalKey _boxKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  double textWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      // Adjust the duration based on your requirement
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getTextWidth();
      _setupAnimation();
    });
  }

  _getTextWidth() {
    if (_textKey.currentContext == null) return;
    final RenderBox renderBox =
        _textKey.currentContext!.findRenderObject() as RenderBox;
    textWidth = renderBox.size.width;
  }

  _setupAnimation() {
    // Set a default animation value
    _animation = Tween<double>(begin: 0, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    if (_boxKey.currentContext == null) return;
    final screenWidth = _boxKey.currentContext!.size!.width;
    if (textWidth > screenWidth) {
      _controller.duration =
          Duration(seconds: ((textWidth - screenWidth) / 70).ceil());
      _animation = Tween<double>(begin: 0, end: textWidth - screenWidth)
          .animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ))
        ..addListener(() {
          if (_animation == null) return;
          if(_scrollController.hasClients) {
            _scrollController.jumpTo(_animation!.value);
          }
        });
      _controller.repeat(reverse: true);
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   child: widget.child,
    // );
    var text = Text(
      widget.text,
      key: _textKey,
      style: widget.style,
    );
    return Container(
      key: _boxKey,
      child: _animation == null
          ? SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: text,
            )
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // logger.d(_animation!.value);
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  // controller: ScrollController(initialScrollOffset: _animation!.value),
                  child: child,
                );
              },
              child: text,
            ),
    );
  }
}
