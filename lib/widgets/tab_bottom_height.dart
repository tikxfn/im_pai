import 'package:flutter/material.dart';

class TabBottomHeight extends StatelessWidget {
  final double height;
  const TabBottomHeight({this.height = 60, super.key});

  @override
  Widget build(BuildContext context) {
    // return Container();
    return SafeArea(
      top: false,
      child: Container(height: height),
    );
  }
}
