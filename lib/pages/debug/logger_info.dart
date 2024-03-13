import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';

class LoggerInfo extends StatefulWidget {
  static const path = 'debug/logger_info';

  const LoggerInfo({super.key});

  @override
  State<LoggerInfo> createState() => _LoggerInfoState();
}

class _LoggerInfoState extends State<LoggerInfo> {
  String? _filepath;
  File? _logFile;

  _init() {
    _filepath = '${Global.appSupportDirectory}/log.txt';
    try {
      _logFile = File(_filepath!);
    } catch (e) {
      tipError(e.toString());
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                confirm(context, title: _filepath ?? '');
              },
              child: const Text('日志文件'),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_logFile == null) {
                  tipError('日志文件不存在');
                  return;
                }
                try {
                  await _logFile!.writeAsString('日志写入测试\n',
                      mode: FileMode.writeOnlyAppend);
                  tipSuccess('日志写入成功');
                } catch (e) {
                  tipError(e.toString());
                  return;
                }
              },
              child: const Text('日志写入'),
            ),
          ],
        ),
      ),
    );
  }
}
