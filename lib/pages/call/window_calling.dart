import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

createCallWindow() async {
  final window = await DesktopMultiWindow.createWindow(
    jsonEncode({
      'args1': 'Sub window',
      'args2': 100,
      'args3': true,
      'business': 'business_test',
    }),
  );
  window
    ..setFrame(const Offset(0, 0) & const Size(352, 640))
    ..center()
    ..setTitle('Another window')
    ..resizable(false)
    ..show();
}

class WindowCalling extends StatefulWidget {
  final WindowController windowController;
  final Map? args;
  const WindowCalling({super.key, required this.windowController, this.args});

  @override
  State<WindowCalling> createState() => _WindowCallingState();
}

class _WindowCallingState extends State<WindowCalling> {
  final textInputController = TextEditingController();

  final windowInputController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: context.watch<ThemeNotifier>().getTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () async {
                logger.d(Global.user);
                logger.d('111');
              },
              child: const Text('Close this window'),
            ),
          ],
        ),
      ),
    );
  }
}
