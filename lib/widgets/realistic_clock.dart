import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RealisticClock extends StatefulWidget {
  final Size size;
  final Color color;
  final double speed;
  const RealisticClock({
    super.key,
    required this.size,
    this.color = Colors.black,
    this.speed = 1.0,
  });

  @override
  createState() => _RealisticClockState();
}

class _RealisticClockState extends State<RealisticClock>
    with TickerProviderStateMixin {
  late AnimationController _hourController;
  late AnimationController _minuteController;

  @override
  void initState() {
    super.initState();
    int cycle = 3000 ~/ widget.speed;

    // 时针控制器：每12小时转一圈
    _hourController = AnimationController(
      duration: Duration(milliseconds: cycle * 60),
      vsync: this,
    )..repeat();

    // 分针控制器：每60分钟转一圈
    _minuteController = AnimationController(
      duration: Duration(milliseconds: cycle),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // 时针
        RotationTransition(
          turns: _hourController,
          child: CustomPaint(
            painter: ClockPainter(
              now,
              bg: true,
              minute: true,
              second: false,
              color: widget.color,
            ),
            size: widget.size,
          ), // 可以更换为更适合的图标
        ),
        RotationTransition(
          turns: _minuteController,
          child: CustomPaint(
            painter: ClockPainter(
              now,
              bg: false,
              minute: false,
              second: true,
              color: widget.color,
            ),
            size: widget.size, // 可以根据需要调整时钟的大小
          ), // 可以更换为更适合的图标
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime dateTime;
  final bool bg;
  final bool minute;
  final bool second;
  final Color color;

  static const Size _defaultSize = Size(200, 200);

  ClockPainter(
    this.dateTime, {
    this.bg = true,
    this.minute = true,
    this.second = true,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    // 绘制时钟圆面
    double radius = min(centerX, centerY);
    Paint dialPaint = Paint()
      ..color = Colors.transparent // 白色填充
      ..style = PaintingStyle.fill;
    Paint borderPaint = Paint()
      ..color = color // 黑色边框
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 * size.width / _defaultSize.width;

    if (bg) {
      canvas.drawCircle(center, radius, dialPaint);
      canvas.drawCircle(center, radius, borderPaint);
    }

    if (minute) {
      double hourX = centerX +
          radius *
              0.5 *
              math.cos(
                  (dateTime.hour * 30 + dateTime.minute * 0.5) * math.pi / 180 -
                      math.pi / 2);
      double hourY = centerY +
          radius *
              0.4 *
              math.sin(
                  (dateTime.hour * 30 + dateTime.minute * 0.5) * math.pi / 180 -
                      math.pi / 2);
      canvas.drawLine(
          center,
          Offset(hourX, hourY),
          Paint()
            ..color = color
            ..strokeWidth = 14 * size.width / _defaultSize.width);
    }
    if (second) {
      double minuteX = centerX +
          radius *
              0.6 *
              math.cos(dateTime.minute * 6 * math.pi / 180 - math.pi / 2);
      double minuteY = centerY +
          radius *
              0.7 *
              math.sin(dateTime.minute * 6 * math.pi / 180 - math.pi / 2);

      canvas.drawLine(
          center,
          Offset(minuteX, minuteY),
          Paint()
            ..color = color
            ..strokeWidth = 11 * size.width / _defaultSize.width);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
