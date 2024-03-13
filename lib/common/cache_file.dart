import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/global.dart';

class CacheFile {
  static final Map<String, Completer<File>> _cache = {};
  static final Map<String, Completer<Uint8List>> _requestCache = {};

  static Future<File> load(
    String url, {
    Future<Uint8List> Function()? provider,
  }) async {
    if (_cache.containsKey(url)) {
      // logger.d('loadImage load from cache');
      return _cache[url]!.future;
    }

    _cache[url] = Completer();

    try {
      String fileName = await getLocalFileName(url);
      File file = File(fileName);
      // logger.d(file.path);
      if (await file.exists()) {
        _cache[url]!.complete(file);
        // logger.d('loadImage load from local');
      } else {
        // logger.d('loadImage load from url');
        Uint8List bytes;

        if (provider != null) {
          bytes = await provider();
        } else {
          bytes = await requestUrl(url);
        }
        await file.writeAsBytes(bytes);
        _cache[url]!.complete(file);
      }
    } catch (e) {
      _cache[url]!.completeError(e);
    } finally {
      _cache[url]!.future.whenComplete(() => _cache.remove(url));
    }

    return _cache[url]!.future;
  }

  // 通过url获取本地文件名字
  static Future<String> getLocalFileName(String url) async {
    var u = Uri.parse(url);
    String extension = u.path.split('.').last;
    Uri uri = Uri.parse(url);
    String fileName =
        '${md5.convert(utf8.encode(uri.replace(query: "").toString()))}.$extension';
    final dir = await getTempDir();
    return '$dir/$fileName';
  }

  // 获取临时存放路径
  static Future<String> getTempDir() async {
    final dir = '${Global.appSupportDirectory}/load';
    final directory = Directory(dir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return dir;
  }

  // 清除临时存放路径
  static Future<void> clearTempDir() async {
    final dir = '${Global.appSupportDirectory}/load';
    final directory = Directory(dir);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  static Future<Uint8List> requestUrl(String url) async {
    var ossUrl = Global.systemInfo.settingUrl?.settingUrl?.ossUrl ?? '';
    final exp = RegExp(r'https://.*\.oss-.*\.aliyuncs.com');
    if (exp.hasMatch(url)) {
      url = url.replaceAll(exp, ossUrl);
    }
    // logger.d('--- ${Global.fileServerUrl}');
    // 替换请求地址
    final source = Uri.parse(url);
    final path = source.path;
    if (_requestCache.containsKey(url)) {
      // logger.d('loadImage load from cache');
      return _requestCache[url]!.future;
    }
    _requestCache[url] = Completer();
    try {
      final u = Uri.parse(url);
      var response = await http.get(u);

      var bytes = response.bodyBytes;
      bytes = Uint8List.fromList(
        UploadFile.decrypt(path.replaceFirst('process/', ''), bytes),
      );

      _requestCache[url]!.complete(bytes);
    } finally {
      _requestCache[url]!.future.whenComplete(() => _requestCache.remove(url));
    }
    return _requestCache[url]!.future;
  }
}
