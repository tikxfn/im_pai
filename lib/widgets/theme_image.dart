import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

class ThemeImage extends StatelessWidget {
  final Widget? child;

  const ThemeImage({this.child, super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Stack(
      children: [
        Column(
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                // gradient: LinearGradient(
                //   begin: Alignment.centerLeft,
                //   end: Alignment.centerRight,
                //   colors: [myColors.bgStart, myColors.bgEnd],
                // ),
                color: myColors.themeBackgroundColor,
                // image: DecorationImage(
                //   image: ExactAssetImage(assetPath('images/thumb_bg.png')),
                //   alignment: Alignment.topCenter,
                //   fit: BoxFit.cover,
                // ),
              ),
            ),
            Expanded(
                child: Container(
              color: myColors.themeBackgroundColor,
            ))
          ],
        ),
        if (child != null) child!,
      ],
    );
  }
}
