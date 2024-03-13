import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/url_text.dart';
import 'package:provider/provider.dart';

class QrcodeResult extends StatelessWidget {
  final String result;
  const QrcodeResult(this.result, {super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.white,
      appBar: AppBar(
        title: const Text('二维码识别'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: UrlText(result),
      ),
    );
  }
}
