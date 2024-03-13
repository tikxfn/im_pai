import 'dart:io';

import 'package:flutter/services.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FileShare {
  //ios分享文件
  // Future<String> _iosShareFile(Uint8List body, String fileName) async {
  //   if (!await devicePermission([Permission.storage])) {
  //     loadClose();
  //     return '';
  //   }
  //   var dir = await getTemporaryDirectory();
  //   var path = '${dir.path}/$fileName';
  //   File file = File(path);
  //   file.writeAsBytesSync(body);
  //   return path;
  // }

  //保存临时文件
  Future<String> saveTempFile(Uint8List bytes, String fileName) async {
    var path = '${Global.temporaryDirectory}/$fileName';
    File file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  //分享文件
  shareFile(String url) async {
    if (Platform.isWindows) {
      tipError('该平台不支持分享文件');
      return;
    }
    loading();
    try {
      var fileName = url.split('/').last;
      var path = url;
      if (urlValid(url)) {
        var file = await CacheFile.load(url);
        path = await saveTempFile(file.readAsBytesSync(), fileName);
      }
      Share.shareXFiles([XFile(path)]);
      loadClose();
    } catch (e) {
      loadClose();
      tipError('分享失败');
      rethrow;
    }
  }
}
