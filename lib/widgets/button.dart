import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

enum AppButtonTheme {
  primary,
  grey,
  greenBlack,
  greenWhite,
  red,
  blue0,
  blue,
}

extension AppButtonThemeExt on AppButtonTheme {
  Color get getBackgroundColor {
    switch (this) {
      case AppButtonTheme.primary:
        return ThemeNotifier().circleBlueButtonBg;
      case AppButtonTheme.grey:
        return ThemeNotifier().textGrey;
      case AppButtonTheme.greenBlack:
        return ThemeNotifier().imGreenBlack;
      case AppButtonTheme.greenWhite:
        return ThemeNotifier().greenButtonBg;
      case AppButtonTheme.red:
        return ThemeNotifier().redButtonBg;
      case AppButtonTheme.blue0:
        return ThemeNotifier().circleBlue0ButtonBg;
      case AppButtonTheme.blue:
        return ThemeNotifier().circleBlueButtonBg;
    }
  }

  Color get getFontColor {
    switch (this) {
      case AppButtonTheme.primary:
        // return myColors.primary;
        return ThemeNotifier().white;
      case AppButtonTheme.grey:
        return ThemeNotifier().white;
      case AppButtonTheme.greenBlack:
        return ThemeNotifier().white;
      case AppButtonTheme.greenWhite:
        return ThemeNotifier().white;
      case AppButtonTheme.red:
        return ThemeNotifier().white;
      case AppButtonTheme.blue0:
        return ThemeNotifier().circleBlueButtonBg;
      case AppButtonTheme.blue:
        return ThemeNotifier().white;
    }
  }
}

//好友详情消息、视频按钮
class AppBlockButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final double height;
  final EdgeInsetsGeometry? margin;
  final double fontSize;
  final double iconSize;
  final Color? color;
  final String? icon;
  final bool borderTop; //是否显示顶部边框

  const AppBlockButton({
    required this.text,
    this.onTap,
    this.height = 50,
    this.margin,
    this.fontSize = 14,
    this.iconSize = 23,
    this.color,
    this.icon,
    this.borderTop = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color chatInputBoderColor = myColors.chatInputBoderColor;
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 10),
      child: Material(
        color: bgColor,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                top: borderTop
                    ? BorderSide(
                        color: chatInputBoderColor,
                        width: .5,
                      )
                    : BorderSide.none,
                bottom: BorderSide(
                  color: chatInputBoderColor,
                  width: .5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10,
                    ),
                    child: Image.asset(
                      assetPath(icon!),
                      color: color,
                      width: iconSize,
                      height: iconSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    height: 1,
                    fontSize: fontSize,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// //圈子button
// class CircleButton extends StatelessWidget {
//   final Function()? onTap;
//   final String? icon;
//   final String title;
//   final double? width;
//   final double height;
//   final double radius;
//   final double fontSize;
//   final AppButtonTheme theme;
//   final bool disabled;
//   final double elevation;
//   final Color? shadowColor;

//   const CircleButton({
//     super.key,
//     this.icon,
//     this.onTap,
//     this.width,
//     this.height = 24,
//     this.radius = 12,
//     this.fontSize = 12,
//     this.theme = AppButtonTheme.greenBlack,
//     this.disabled = false,
//     this.elevation = 0,
//     this.shadowColor,
//     required this.title,
//     // required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Color backgroundColor = disabled
//         ? AppButtonTheme.grey.getBackgroundColor
//         : theme.getBackgroundColor;
//     Color fontColor = theme.getFontColor;
//     return Material(
//       borderRadius: BorderRadius.circular(radius),
//       clipBehavior: Clip.antiAlias,
//       color: backgroundColor,
//       shadowColor: shadowColor,
//       elevation: elevation,
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           alignment: Alignment.center,
//           width: width,
//           height: height,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               if (icon != null)
//                 Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: Image.asset(
//                     width: 19,
//                     height: 19,
//                     assetPath(icon!),
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: fontColor,
//                   fontSize: fontSize,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class CircleButton extends StatefulWidget {
  final Function()? onTap;
  final String? icon;
  final String title;
  final double? width;
  final double height;
  final double radius;
  final double fontSize;
  final AppButtonTheme theme;
  final bool disabled;
  final double elevation;
  final Color? shadowColor;
  final bool waiting;
  const CircleButton({
    super.key,
    this.icon,
    this.onTap,
    this.width,
    this.height = 24,
    this.radius = 12,
    this.fontSize = 12,
    this.theme = AppButtonTheme.blue,
    this.disabled = false,
    this.elevation = 0,
    this.shadowColor,
    this.waiting = false,
    required this.title,
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton>
    with TickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _tapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _tapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = widget.disabled || widget.waiting
        ? AppButtonTheme.grey.getBackgroundColor
        : widget.theme.getBackgroundColor;
    Color fontColor = widget.theme.getFontColor;
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTap: !widget.waiting ? widget.onTap : null,
      onTapDown: _tapDown,
      onTapUp: _tapUp,
      child: Transform.scale(
        scale: _scale,
        child: Material(
          borderRadius: BorderRadius.circular(widget.radius),
          clipBehavior: Clip.antiAlias,
          color: backgroundColor,
          shadowColor: widget.shadowColor,
          elevation: widget.elevation,
          child: Container(
            alignment: Alignment.center,
            width: widget.width,
            height: widget.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      width: 19,
                      height: 19,
                      assetPath(widget.icon!),
                      fit: BoxFit.contain,
                    ),
                  ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: widget.fontSize,
                  ),
                ),
                if (widget.waiting)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: CupertinoActivityIndicator(radius: 10),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//圆形button 群聊成员列表  圈子成员列表
class CircularButton extends StatelessWidget {
  final Function()? onTap;
  final String? title;
  final double? titleSize;
  final double size;
  final Widget? child;
  final Color? nameColor;

  // final AppButtonTheme theme;
  // final bool disabled;

  const CircularButton({
    super.key,
    this.onTap,
    this.size = 50,
    this.title,
    this.titleSize = 12,
    this.child,
    this.nameColor,
    // this.theme = AppButtonTheme.primary,
    // this.disabled = false,

    // required this.color,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: myColors.grey1,
              border: Border.all(
                color: myColors.lineGrey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(size),
            ),
            child: child,
          ),
        ),
        if (title != null)
          Container(
            width: size,
            margin: const EdgeInsets.only(top: 5),
            alignment: Alignment.center,
            child: Text(
              title!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontSize: titleSize,
                color: nameColor ?? myColors.textBlack,
              ),
            ),
          ),
      ],
    );
  }
}

//底部按钮
class BottomButton extends StatelessWidget {
  final Function()? onTap;
  final String title;
  final double bgHeight;
  final double bgRadius;
  final double buttonHeight;
  final double buttonRadius;
  final bool disabled;
  final double fontSize;
  final AppButtonTheme theme;
  final bool waiting;

  const BottomButton({
    super.key,
    required this.title,
    this.onTap,
    this.bgHeight = 68,
    this.buttonHeight = 47,
    this.buttonRadius = 10,
    this.bgRadius = 15,
    this.fontSize = 19,
    this.disabled = false,
    this.theme = AppButtonTheme.blue,
    this.waiting = false,
    // required this.color,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      height: bgHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bgRadius),
          topRight: Radius.circular(bgRadius),
        ),
        color: myColors.bottom,
        boxShadow: [
          BoxShadow(
            color: myColors.bottomShadow,
            blurRadius: 5,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CircleButton(
          disabled: disabled,
          waiting: waiting,
          onTap: onTap,
          title: title,
          radius: buttonRadius,
          theme: AppButtonTheme.blue,
          fontSize: fontSize,
          height: buttonHeight,
        ),
      ),
    );
  }
}

//....
class AppButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final EdgeInsetsGeometry? margin;
  final double fontSize;
  final double height;
  final double? width;
  final bool disabled;
  final double? borderRadius;
  final AppButtonTheme theme;
  const AppButton({
    required this.text,
    this.onTap,
    this.margin,
    this.fontSize = 16,
    this.height = 50,
    this.width,
    this.disabled = false,
    this.borderRadius,
    this.theme = AppButtonTheme.primary,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = disabled
        ? AppButtonTheme.grey.getBackgroundColor
        : theme.getBackgroundColor;
    return Container(
      margin: margin,
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(backgroundColor),
            // shadowColor: MaterialStateProperty.all(Colors.transparent),
            shape: borderRadius != null
                ? MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(borderRadius!),
                    ),
                  )
                : null,
          ),
          onPressed: () {
            if (onTap != null) onTap!();
          },
          child: Container(
            // height: height,
            // width: width,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ),
      ),
    );
  }
}

//....//固定在底部的按钮盒子
class AppButtonBottomBox extends StatelessWidget {
  final Widget child;
  const AppButtonBottomBox({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    return Expanded(
      flex: 0,
      child: Container(
        color: bgColor,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ),
      ),
    );
  }
}
