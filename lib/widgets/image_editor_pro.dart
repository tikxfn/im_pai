import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/image_crop.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:provider/provider.dart';

import '../notifier/theme_notifier.dart';
import 'image_painter.dart';

class ImageEditorPro extends StatefulWidget {
  final Uint8List file;

  const ImageEditorPro(this.file, {super.key});

  @override
  State<ImageEditorPro> createState() => _ImageEditorProState();
}

class _ImageEditorProState extends State<ImageEditorPro> {
  late Uint8List originFile;
  late Uint8List file;

  // 保存
  save() async {
    if (mounted) Navigator.pop(context, {'result': file, 'ext': 'png'});
  }

  //编辑按钮组件
  Widget _editBtn({
    required IconData icon,
    bool active = false,
    Function()? onTap,
    Color? iconColor,
  }) {
    var myColors = ThemeNotifier();
    iconColor = iconColor ?? myColors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: active ? myColors.readBg : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    file = widget.file;
    originFile = widget.file;
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
            '图片编辑',
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
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Image.memory(file),
            ),
            Container(
              color: myColors.black,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _editBtn(
                        icon: Icons.cut,
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) => AppImageCrop(file),
                            ),
                          ).then((res) {
                            if (res == null) return;
                            setState(() {
                              file = res['result'];
                            });
                          });
                        },
                      ),
                      _editBtn(
                        icon: Icons.edit,
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) => AppImagePainter(file),
                            ),
                          ).then((res) {
                            if (res == null) return;
                            setState(() {
                              file = res['result'];
                            });
                          });
                        },
                      ),
                      _editBtn(
                        iconColor: myColors.messagePacketColor,
                        icon: Icons.close,
                        onTap: () {
                          setState(() {
                            file = originFile;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
