import 'dart:io';

import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:permission_handler/permission_handler.dart';

class FileOpen {
  //保存临时文件
  static Future<String> saveTempFile(Uint8List bytes, String fileName) async {
    var path = '${Global.temporaryDirectory}/$fileName';
    File file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  //分享文件
  static open(String url) async {
    var fileName = url.split('/').last;
    var ext = fileName.split('.').last.toLowerCase();
    if (Platform.isAndroid && ext == 'apk') {
      if (!await devicePermission([Permission.requestInstallPackages])) return;
    }
    loading();
    try {
      var path = url;
      if (urlValid(url)) {
        var file = await CacheFile.load(url);
        path = await saveTempFile(file.readAsBytesSync(), fileName);
      }
      var result = await OpenFile.open(path);
      var errMsg = result.message;
      switch (result.type) {
        case ResultType.permissionDenied:
          errMsg = '没有可以打开该文件的权限';
          break;
        case ResultType.done:
          errMsg = '';
          break;
        case ResultType.error:
          errMsg = '无法打开该文件（ResultType.error）';
          logger.e(result.message);
          break;
        case ResultType.fileNotFound:
          errMsg = '文件未找到';
          break;
        case ResultType.noAppToOpen:
          errMsg = '没有可以打开该文件的应用程序';
          break;
      }
      if (errMsg.isNotEmpty) {
        tipError(errMsg);
      }
    } catch (e) {
      tipError('无法打开该文件');
      rethrow;
    } finally {
      loadClose();
    }
  }
}
