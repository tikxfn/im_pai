import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

class AppImageCrop extends StatefulWidget {
  final Uint8List file;

  const AppImageCrop(
    this.file, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AppImageCropState();
}

class _AppImageCropState extends State<AppImageCrop> {
  late Uint8List originFile;
  late Uint8List file;
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();

  //保存
  save() async {
    await loading(text: '图片裁剪中'.tr());
    var res = await imageClipPc();
    loadClose();
    if (mounted) Navigator.pop(context, {'result': res, 'ext': 'png'});
  }

  //pc图片裁剪
  Future<Uint8List?> imageClipPc() async {
    try {
      var state = editorKey.currentState;
      if (state == null) {
        loadClose();
        return null;
      }
      var editAction = state.editAction!;
      Rect? cropRect = state.getCropRect();
      var data = state.rawImageData;

      img.Image? src = img.decodeImage(data);
      if (src == null) return null;
      // final lb = await loadBalancer;
      // img.Image src = await lb.run<img.Image, List<int>>(img.decodeImage, data);

      //相机拍照的图片带有旋转，处理之前需要去掉
      src = img.bakeOrientation(src);

      if (editAction.needCrop) {
        src = img.copyCrop(
          src,
          x: cropRect!.left.toInt(),
          y: cropRect.top.toInt(),
          width: cropRect.width.toInt(),
          height: cropRect.height.toInt(),
        );
      }

      if (editAction.needFlip) {
        img.FlipDirection mode = img.FlipDirection.both;
        if (editAction.flipY && editAction.flipX) {
          mode = img.FlipDirection.both;
        } else if (editAction.flipY) {
          mode = img.FlipDirection.horizontal;
        } else if (editAction.flipX) {
          mode = img.FlipDirection.vertical;
        }
        src = img.flip(src, direction: mode);
      }

      if (editAction.hasRotateAngle) {
        src = img.copyRotate(src, angle: editAction.rotateAngle.toInt());
      }
      // var fileData = img.encodeJpg(src);
      return img.encodeJpg(src);
    } catch (e) {
      return null;
    }
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
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: myColors.white,
        ),
        title: Text(
          '图片裁剪'.tr(),
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
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ExtendedImage.memory(
                    file,
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.editor,
                    extendedImageEditorKey: editorKey,
                    cacheRawData: true,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                      );
                    },
                  ),
                ],
              ),
            ),
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
                      icon: Icons.flip,
                      onTap: () {
                        editorKey.currentState!.flip();
                      },
                    ),
                    _editBtn(
                      icon: Icons.rotate_left,
                      onTap: () {
                        editorKey.currentState!.rotate(right: false);
                      },
                    ),
                    _editBtn(
                      icon: Icons.rotate_right,
                      onTap: () {
                        editorKey.currentState!.rotate();
                      },
                    ),
                    _editBtn(
                      icon: Icons.close,
                      iconColor: myColors.messagePacketColor,
                      onTap: () {
                        editorKey.currentState!.reset();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
