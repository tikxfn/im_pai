import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';

// ignore: must_be_immutable
class PCsingleChildScrollview extends StatefulWidget {
  Widget child;

  PCsingleChildScrollview({
    super.key,
    required this.child,
  });

  @override
  State<PCsingleChildScrollview> createState() =>
      _PCsingleChildScrollviewState();
}

class _PCsingleChildScrollviewState extends State<PCsingleChildScrollview> {
  final ScrollController _scrollController = ScrollController();
  double _startHorizontalDrag = 0.0;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        HorizontalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
          () => HorizontalDragGestureRecognizer(),
          (HorizontalDragGestureRecognizer instance) {
            instance
              ..onStart = _onStart
              ..onUpdate = _onUpdate;
          },
        ),
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: widget.child,
      ),
    );
  }

  void _onStart(DragStartDetails details) {
    if (platformPhone) return;
    _startHorizontalDrag = details.globalPosition.dx;
  }

  void _onUpdate(DragUpdateDetails details) {
    if (platformPhone) return;
    final offset = _scrollController.offset +
        _startHorizontalDrag -
        details.globalPosition.dx;
    _scrollController.jumpTo(offset);
    _startHorizontalDrag = details.globalPosition.dx;
  }
}
