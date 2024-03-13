import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class FileSave {
  //安卓保存文件
  Future _androidSaveFile(Uint8List bytes, String fileName) async {
    if (!await androidStorage()) {
      // if (!await devicePermission([Permission.storage])) {
      loadClose();
      return;
    }
    // var directories = await getExternalStorageDirectories(type: StorageDirectory.downloads);
    // if(directories == null || directories.isEmpty) {
    //   loadClose();
    //   return;
    // }
    // logger.d((directories));
    // var directory = directories[0].path;
    var directory =
        '/storage/emulated/0/Download/${Global.versionInfo.appName}';
    Directory generalDownloadDir = Directory(directory);
    if (!await generalDownloadDir.exists()) {
      await generalDownloadDir.create();
    }
    var path = '${generalDownloadDir.path}/$fileName';
    // var path = '${dir!.path}/$fileName';
    File file = await File(path).create();
    file.writeAsBytesSync(bytes);
    tipSuccess('保存成功');
    // OpenFile
  }

  //ios保存文件
  Future _iosSaveFile(Uint8List bytes, String fileName) async {
    if (!await devicePermission([Permission.storage])) {
      loadClose();
      return;
    }
    var path = '${Global.documentDirectory}/$fileName';
    File file = File(path);
    file.writeAsBytesSync(bytes);
    await Share.shareXFiles([XFile(path)]);
  }

  //pc保存文件
  Future _pcSaveFile(Uint8List bytes, String fileName) async {
    String? dir = await FilePicker.platform.saveFile(
      fileName: fileName,
    );
    if (dir == null) {
      loadClose();
      return;
    }
    File file = File(dir);
    file.writeAsBytesSync(bytes);
  }

  //保存文件
  saveFile(String url, {String fileName = ''}) async {
    loading(text: '保存中');
    try {
      fileName = fileName.isEmpty ? url.split('/').last : fileName;
      late Uint8List bytes;
      if (urlValid(url)) {
        var file = await CacheFile.load(url);
        bytes = file.readAsBytesSync();
      } else {
        bytes = await File(url).readAsBytes();
      }
      if (Platform.isAndroid) {
        await _androidSaveFile(bytes, fileName);
      } else if (Platform.isIOS) {
        await _iosSaveFile(bytes, fileName);
      } else if (Platform.isWindows) {
        await _pcSaveFile(bytes, fileName);
      } else if (Platform.isMacOS) {
        await _pcSaveFile(bytes, fileName);
      }
      loadClose();
    } catch (e) {
      logger.e(e);
      loadClose();
      tipError('保存失败');
      rethrow;
    }
  }

  //缓存截图文件
  Future<String> pcTempSaveImage(Uint8List bytes) async {
    try {
      var ext = bytesImageGetFormat(bytes);
      if (ext.isEmpty) return '';
      final String appDirPath = Global.documentDirectory;
      // 生成唯一的文件名
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
      // 创建文件
      final File imageFile = File('$appDirPath/$fileName');
      await imageFile.writeAsBytes(bytes);
      return imageFile.path;
    } catch (e) {
      logger.e(e);
      return '';
    }
  }
}
