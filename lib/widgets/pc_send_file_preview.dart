import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

import 'network_image.dart';

class PcSendFilePreview extends StatefulWidget {
  final Function()? onEnter;
  final Function()? onCancel;
  final String path;

  const PcSendFilePreview({
    required this.path,
    this.onEnter,
    this.onCancel,
    super.key,
  });

  @override
  State<PcSendFilePreview> createState() => _PcSendFilePreviewState();
}

class _PcSendFilePreviewState extends State<PcSendFilePreview> {
  void _keyboardListener(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent &&
        event.isKeyPressed(LogicalKeyboardKey.enter)) {
      Navigator.pop(context);
      if (widget.onEnter != null) widget.onEnter!();
    }
  }

  @override
  void initState() {
    RawKeyboard.instance.addListener(_keyboardListener);
    super.initState();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_keyboardListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    var path = widget.path;
    var ext = path.split('.').last;
    var pattern = Platform.isWindows ? '\\' : '/';
    var fileName = path.split(pattern).last;
    var fileType = getFileType(path);
    switch (fileType) {
      case AppFileType.image:
        break;
      case AppFileType.video:
        break;
      case AppFileType.other:
        break;
    }
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: myColors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '发送文件',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onCancel != null) widget.onCancel!();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (fileType == AppFileType.image)
              AppNetworkImage(
                path,
                width: double.infinity,
              ),
            if (fileType == AppFileType.other || fileType == AppFileType.video)
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        assetPath('images/sp_wenjian.png'),
                        width: 50,
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 15),
                        child: Text(
                          ext.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onCancel != null) widget.onCancel!();
                  },
                  child: Text(
                    '取消'.tr(),
                    style: TextStyle(
                      color: myColors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (widget.onEnter != null) widget.onEnter!();
                  },
                  child: Text('发送'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
