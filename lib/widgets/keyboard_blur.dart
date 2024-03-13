import 'package:flutter/material.dart';

//点击空白收起键盘容器
class KeyboardBlur extends StatelessWidget {
  final Widget? child;
  final Function()? onTap;

  const KeyboardBlur({this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
        if (onTap != null) onTap!();
      },
      child: child,
    );
  }
}
