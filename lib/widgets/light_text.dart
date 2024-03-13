import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';

class LightText extends StatelessWidget {
  final String source;
  final String keyword;
  final TextStyle? style;

  const LightText(
    this.source,
    this.keyword, {
    this.style,
    super.key,
  });

  List<TextSpan> highlightOccurrences(String source, String keyword) {
    List<TextSpan> spans = [];

    if (keyword.isEmpty) {
      spans.add(TextSpan(text: source));
      return spans;
    }

    final pattern = RegExp(keyword, caseSensitive: false);
    final matches = pattern.allMatches(source);

    int start = 0;
    for (Match match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: source.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ThemeNotifier().blueTitle,
          ),
        ),
      );
      start = match.end;
    }

    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start, source.length)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: style,
        children: highlightOccurrences(source, keyword),
      ),
    );
  }
}
