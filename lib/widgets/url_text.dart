import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? urlColor;
  final bool select;
  final TextOverflow? overflow;
  final int? maxLines;

  const UrlText(
    this.text, {
    super.key,
    this.style,
    this.urlColor,
    this.select = false,
    this.overflow,
    this.maxLines,
  });

  List<String> splitTextAndUrls(String input) {
    List<String> segments = [];
    RegExp urlPattern =
        RegExp(r'https?://[^\s\u4e00-\u9fa5]+'); // 匹配不包含中文字符的URL
    int lastIndex = 0;

    for (Match match in urlPattern.allMatches(input)) {
      segments.add(input.substring(lastIndex, match.start)); // 添加非 URL 文本
      segments.add(match.group(0) ?? ''); // 添加 URL
      lastIndex = match.end;
    }

    // 添加剩余的非 URL 文本
    if (lastIndex < input.length) {
      segments.add(input.substring(lastIndex));
    }

    return segments;
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    final RegExp urlRegex = RegExp(r'https?://[^\s/$.?#].\S*');
    var list = splitTextAndUrls(text);
    var child = TextSpan(
      style: style,
      children: list.map((word) {
        if (urlRegex.hasMatch(word)) {
          return TextSpan(
            text: word,
            style: TextStyle(
              color: urlColor ?? myColors.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(word));
              },
          );
        }
        return TextSpan(text: '$word ');
      }).toList(),
    );
    if (select) {
      return SelectableText.rich(
        child,
        maxLines: maxLines,
      );
    }
    return Text.rich(
      child,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
