import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

class ThemeBody extends StatelessWidget {
  final double topPadding;
  final Widget? child;
  final Color? bodyColor;

  const ThemeBody({this.child, this.topPadding = 0, this.bodyColor, super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Container(
        padding: EdgeInsets.only(top: topPadding),
        decoration: BoxDecoration(
          color: bodyColor ?? myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
