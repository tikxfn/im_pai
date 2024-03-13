import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:unionchat/common/cache_file.dart';
import 'package:unionchat/global.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'func.dart';

class MediaSave {
  //pc保存文件
  Future<String> _pcSaveFile(
    Uint8List res,
    String fileName,
    String ext,
  ) async {
    fileName = '${fileName.split('.').first}-${fileName.split('-').last}.$ext';
    String? dir = await FilePicker.platform.saveFile(
      fileName: fileName,
    );
    if (dir == null) {
      loadClose();
      return '';
    }
    File file = File(dir);
    file.writeAsBytesSync(res);
    return file.path;
  }

  //手机保存图片
  Future<String> _phoneSave(Uint8List res, String fileName) async {
    final result = await ImageGallerySaver.saveImage(
      res,
      name: fileName,
    );
    if (result['isSuccess']) {
      tipSuccess('保存成功');
      return result['filePath'] ?? '';
    }
    return '';
  }

  //手机保存Gif图片
  Future<void> _phoneSaveGif(
    Uint8List bytes,
    String fileName,
    String ext,
  ) async {
    var appDocDir = await getTemporaryDirectory();
    String path = '${appDocDir.path}/$fileName.$ext';
    var file = await File(path).create();
    file.writeAsBytesSync(bytes);
    final result = await ImageGallerySaver.saveFile(
      path,
      isReturnPathOfIOS: true,
      name: fileName,
    );
    if (result['isSuccess']) {
      tipSuccess('保存成功');
      return result['filePath'] ?? '';
    }
  }

  //手机保存视频
  Future<String> _phoneSaveVideo(
    Uint8List res,
    String fileName,
    String ext,
  ) async {
    loading();
    var appDocDir = await getTemporaryDirectory();
    String path = '${appDocDir.path}/$fileName.$ext';
    var file = await File(path).create();
    file.writeAsBytesSync(res);
    final result = await ImageGallerySaver.saveFile(
      path,
      name: fileName,
    );
    if (result['isSuccess']) {
      tipSuccess('保存成功');
      return path;
    }
    return '';
  }

  //保存媒体文件
  Future<void> saveMedia(
    String url, {
    bool video = false,
  }) async {
    var permission = [Permission.photos];
    // if (Platform.isAndroid) permission = [Permission.storage];
    if (Platform.isMacOS || Platform.isAndroid) permission = [];
    if (!await devicePermission(permission)) {
      tipError('未获取到相册权限');
      return;
    }
    if (Platform.isAndroid && !await androidStorage()) {
      tipError('未获取到相册权限');
      return;
    }
    loading(text: '下载中');
    try {
      var uri = Uri.parse(url);
      var fileName = uri.path.split('/').last;
      var ext = fileName.split('.').last;
      fileName =
          '${fileName.split('.').first}-${DateTime.now().millisecondsSinceEpoch}.$ext';
      late Uint8List bytes;
      if (urlValid(url)) {
        var file = await CacheFile.load(url);
        bytes = file.readAsBytesSync();
      } else {
        bytes = await File(url).readAsBytes();
      }
      if (Platform.isIOS || Platform.isAndroid) {
        if (ext.toLowerCase() == 'gif') {
          await _phoneSaveGif(bytes, fileName, ext);
        } else if (video) {
          await _phoneSaveVideo(bytes, fileName, ext);
        } else if (!video) {
          await _phoneSave(bytes, fileName);
        }
      } else if (Platform.isMacOS || Platform.isWindows) {
        await _pcSaveFile(bytes, fileName, ext);
      } else {
        tipError('不支持该平台');
      }
    } catch (e) {
      logger.d(e);
      tipError('下载失败');
    } finally {
      loadClose();
    }
  }

  //保存媒体文件
  Future<String> saveMediaBytes(
    Uint8List bytes,
    String ext, {
    bool video = false,
  }) async {
    var permission = [Permission.photos];
    if (Platform.isMacOS || Platform.isAndroid) permission = [];
    if (!await devicePermission(permission)) {
      tipError('未获取到相册权限');
      return '';
    }
    if (Platform.isAndroid && !await androidStorage()) {
      tipError('未获取到相册权限');
      return '';
    }
    loading(text: '正在保存');
    try {
      var fileName = 'photo-${DateTime.now().millisecondsSinceEpoch}';
      if (Platform.isIOS || Platform.isAndroid) {
        if (video) {
          return await _phoneSaveVideo(bytes, fileName, ext);
        } else {
          return await _phoneSave(bytes, fileName);
        }
      } else if (Platform.isMacOS || Platform.isWindows) {
        return await _pcSaveFile(bytes, fileName, ext);
      } else {
        tipError('不支持该平台');
        return '';
      }
    } catch (e) {
      logger.d(e);
      tipError('保存失败');
      return '';
    } finally {
      loadClose();
    }
  }
}
