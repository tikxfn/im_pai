import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/media_save.dart';

/// 获取截取图片的数据
Future<Uint8List?> globCaptureScreen(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0); // 增加像素密度来提高分辨率
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  } catch (e) {
    return null;
  }
}

Future<void> globSaveImageToGallery(GlobalKey key) async {
  Uint8List? imageBytes = await globCaptureScreen(key);
  if (imageBytes != null) {
    await MediaSave().saveMediaBytes(imageBytes, 'png');
    // final result = await ImageGallerySaver.saveImage(imageBytes);
    // if (result['isSuccess']) {
    //   tipSuccess('已保存到相册'.tr());
    // } else {
    //   tipError('保存失败'.tr());
    // }
  }
}
