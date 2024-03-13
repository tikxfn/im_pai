import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:image_painter/image_painter.dart';
import 'package:provider/provider.dart';

class AppImagePainter extends StatefulWidget {
  final Uint8List file;

  const AppImagePainter(this.file, {super.key});

  @override
  State<AppImagePainter> createState() => _AppImagePainterState();
}

class _AppImagePainterState extends State<AppImagePainter> {
  final _imageKey = GlobalKey<ImagePainterState>();

  save() async {
    loading();
    var res = await _imageKey.currentState?.exportImage();
    loadClose();
    if (mounted) Navigator.pop(context, {'result': res});
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return ThemeImage(
      child: Scaffold(
        backgroundColor: myColors.black,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: myColors.white,
          ),
          title: Text(
            '图片涂鸦',
            style: TextStyle(color: myColors.white),
          ),
          actions: [
            TextButton(
              onPressed: save,
              child: Text(
                '确定',
                style: TextStyle(color: myColors.primary),
              ),
            ),
          ],
        ),
        body: ImagePainter.memory(
          widget.file,
          textDelegate: CnTextDelegate(),
          key: _imageKey,
          controlsAtTop: false,
          scalable: true,
          controlsBackgroundColor: myColors.black,
        ),
      ),
    );
  }
}

class CnTextDelegate extends TextDelegate {
  @override
  String get noneZoom => '无/缩放';
  @override
  String get line => '直线';
  @override
  String get rectangle => '矩形';
  @override
  String get drawing => '画笔';
  @override
  String get circle => '圆';
  @override
  String get arrow => '箭头';
  @override
  String get dashLine => '虚线';
  @override
  String get text => '文字';
}
