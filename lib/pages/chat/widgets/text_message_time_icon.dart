import 'package:flutter/material.dart';
import 'package:unionchat/widgets/url_text.dart';

class TextMessageTimeIcon extends StatelessWidget {
  // 文字
  final String text;

  // 容器宽度
  final double width;

  // 文字样式
  final TextStyle? style;

  // 图标
  final Widget? icon;

  // 图标宽度（如有图标必传）
  final double iconWidth;

  // 图标距离左侧
  final double iconMarginLeft;

  // 时间
  final String? time;

  // 时间样式
  final TextStyle? timeStyle;

  // 时间距离左侧
  final double timeMarginLeft;

  const TextMessageTimeIcon(
    this.text, {
    required this.width,
    this.style,
    this.icon,
    this.iconWidth = 0,
    this.iconMarginLeft = 5,
    this.time,
    this.timeStyle,
    this.timeMarginLeft = 5,
    super.key,
  });

  // 获取文字宽度
  _getTextWidth(String str, TextStyle? style) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: str,
        style: style,
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    double iw = 0;
    double iml = 0;
    double tml = time != null ? timeMarginLeft : 0;
    Widget? endChild;
    Widget? iconWidget;
    Widget? timeWidget;
    if (icon != null) {
      iw = iconWidth;
      iml = iconMarginLeft;
      iconWidget = Padding(
        padding: EdgeInsets.only(left: iconMarginLeft),
        child: icon!,
      );
    }
    if (time != null) {
      timeWidget = Padding(
        padding: EdgeInsets.only(left: timeMarginLeft),
        child: Text(time!, style: timeStyle),
      );
    }
    if (icon != null && time != null) {
      endChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [timeWidget!, iconWidget!],
      );
    } else if (icon != null) {
      endChild = iconWidget;
    } else if (time != null) {
      endChild = timeWidget;
    }
    if (endChild == null) return UrlText(text, style: style);
    var content = UrlText(text, style: style);
    var timeWidth = time != null ? _getTextWidth(time!, timeStyle) + tml : 0;
    var endWidth = timeWidth + iw + iml;
    var contentWidth = _getTextWidth(text, style);
    var hasWidth = width - contentWidth % width - 30;
    bool float = hasWidth >= endWidth;
    bool overflow = contentWidth + endWidth > width;

    if (text.contains('\n')) {
      float = false;
      overflow = true;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: width,
          ),
          child: Stack(
            children: [
              if (!overflow)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    content,
                    endChild,
                  ],
                ),
              if (overflow)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    content,
                    if (!float) endChild,
                  ],
                ),
              if (overflow && float)
                Positioned(
                  bottom: 0,
                  right: 0,
                  // alignment: Alignment.bottomRight,
                  child: endChild,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
