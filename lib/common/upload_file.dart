import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:unionchat/common/aes.dart';
import 'package:unionchat/common/file_share.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/multipart_request.dart';
import 'package:unionchat/global.dart';
import 'package:openapi/api.dart';
import 'package:scan/scan.dart';

import 'func.dart';

abstract class FileProvider {
  Uint8List get contentBytes;

  V1FileUploadType get type;

  String get extname;

  factory FileProvider.fromFilepath(String filepath, V1FileUploadType type) {
    return _FileProviderFile(filepath, type);
  }

  factory FileProvider.fromFile(File file, V1FileUploadType type) {
    return _FileProviderBytes(
      file.readAsBytesSync(),
      type,
      file.path.split('.').last.toLowerCase(),
    );
  }

  factory FileProvider.fromBytes(
      Uint8List bytes, V1FileUploadType type, String extname) {
    return _FileProviderBytes(bytes, type, extname);
  }
}

class _FileProviderBytes implements FileProvider {
  final Uint8List bytes;
  @override
  final V1FileUploadType type;
  @override
  final String extname;

  _FileProviderBytes(this.bytes, this.type, this.extname);

  @override
  Uint8List get contentBytes => bytes;
}

class _FileProviderFile implements FileProvider {
  final String filepath;

  @override
  final V1FileUploadType type;
  @override
  final String extname;

  _FileProviderFile(this.filepath, this.type)
      : extname = filepath.split('.').last.toLowerCase();

  @override
  Uint8List get contentBytes => File(filepath).readAsBytesSync();
}

//上传文件
class UploadFile {
  final List<FileProvider> providers;
  final bool load;

  UploadFile({
    required this.providers,
    this.load = true,
  });

  // 检测敏感二维码
  Future<bool> checkQrcode() async {
    // List<String> whiteUrls = [];
    for (var v in providers) {
      var fileName = '${uuid.v4()}.${v.extname}';
      if (getFileType(fileName) != AppFileType.image) continue;
      var path = await FileShare().saveTempFile(v.contentBytes, fileName);
      var result = await Scan.parse(path);
      if (!checkIllegal(result)) return false;
    }
    return true;
  }

  // 检测是否非法图片：json类型（需要包含字段target=feiou）、url类型（非黑名单内）
  bool checkIllegal(String? result) {
    List<String> whiteUrls = Global.whiteUrls;
    if (result == null || result.isEmpty) return true;
    var json = str2map(result);
    if (json == null) {
      // 非url无法发送
      // if(!urlValid(result)) return false;
      // 未开启url黑名单验证
      if (!Global.enabledWhiteUrl) return true;
      // 是否包含在黑名单内
      var inWhite = true;
      for (var url in whiteUrls) {
        // 检测到结果包含黑名单内容，跳出循环
        if (result.contains(url)) {
          inWhite = false;
          break;
        }
      }
      return inWhite;
    } else if (json['target'] == null || json['target'] != 'feiou') {
      return false;
    }
    return true;
  }

  Future<List<String?>> aliOSSUpload(
      {Function(double)? onProgress, bool check = true}) async {
    if (check && !await checkQrcode()) {
      tipError('图片包含敏感信息');
      return [];
    }
    final List<Future> futures = [];
    final List<String?> urls = [];
    final progressList = <double>[];
    for (var _ in providers) {
      urls.add(null);
      progressList.add(0);
    }
    for (var element in providers) {
      var i = providers.indexOf(element);
      futures.add((int index) async {
        urls[index] = await _storeUpload(
          element,
          onProgress: (v) {
            progressList[index] = v;
            var progress = toDouble(
              ((progressList.reduce((a, b) => a + b) / progressList.length) *
                      100)
                  .toStringAsFixed(2),
            );
            // logger.d(progress);
            onProgress?.call(progress);
          },
        );
        // urls.add(await _aliOSSUpload(element));
      }(i));
    }
    if (load) loading(text: '上传中');
    try {
      await Future.wait(futures);
      logger.d('上传执行完成');
    } catch (e) {
      // logger.e(e);
      if (load) tipError('上传失败');
      rethrow;
    } finally {
      if (load) loadClose();
    }
    // logger.d(urls);
    return urls;
  }

  Future<String> _storeUpload(
    FileProvider provider, {
    Function(double)? onProgress,
  }) async {
    final hash = md5.convert(provider.contentBytes).toString();
    // var width = 0;
    // var height = 0;
    // switch (provider.extname) {
    //   case 'png':
    //   case 'jpg':
    //   case 'jpeg':
    //   case 'gif':
    //   case 'bmp':
    //     var decodedImage = img.decodeImage(provider.contentBytes);
    //     width = decodedImage!.width;
    //     height = decodedImage.height;
    // }

    // logger.d(hash);
    final result = await FileApi(apiClient()).fileGetUploadUrl(
      V1GetUploadUrlArgs(
        type: provider.type,
        extname: provider.extname,
        hash: hash,
        // width: width.toString(),
        // height: height.toString(),
      ),
    );
    logger.d(result);
    if (result!.isExist ?? false) {
      onProgress?.call(1);
      return result.viewUrl!;
    }
    final uploadUrl = result.uploadUrl ?? '';
    final req = MyMultipartRequest(
      result.method!,
      Uri.parse(uploadUrl),
    );
    // logger.d('objectkey ${result.objectKey!}');
    final body = _encrypt(result.objectKey!, provider.contentBytes);
    req.fields.addAll(result.params);
    req.files.add(http.MultipartFile.fromBytes(
      'file',
      body,
      filename: 'file.${provider.extname}',
    ));
    final response = await req.send();
    if (response.statusCode != 200 && response.statusCode != 204) {
      logger.e(response.statusCode);
      throw ApiException(
        response.statusCode,
        '上传失败 statusCode: ${response.statusCode}',
      );
    }
    onProgress?.call(1);
    // logger.d('--- viewUrl ${result.viewUrl!}');
    return result.viewUrl!;
  }

  double progress = 0;

  // 加密body
  List<int> _encrypt(String key, List<int> body) {
    final hmacSha256 = Hmac(sha256, utf8.encode(Global.storeSecret));
    final sign = hmacSha256.convert(key.codeUnits).bytes;
    final result = xor(
      body,
      sign,
    );
    var rnd = Random();
    var length = rnd.nextInt(15) + 10;
    final List<int> preBytes = [];
    for (var i = 0; i < length; i++) {
      // 随机生成0-255之间的数填充Uint8List
      preBytes.add(rnd.nextInt(256));
    }
    return <int>[preBytes.length] + preBytes + result;
  }

  static List<int> decrypt(String filepath, List<int> encryptedBody) {
    if (filepath.startsWith('/')) {
      filepath = filepath.substring(1);
    }
    // 生成和加密时相同的密钥
    final hmacSha256 = Hmac(sha256, utf8.encode(Global.storeSecret));
    final key = hmacSha256.convert(filepath.codeUnits).bytes;
    // 随机生成的字节长度
    var randomByteLength = encryptedBody[0];

    // 拆分随机生成的字节和主要的加密数据
    // var randomBytes = encryptedBody.sublist(1, randomByteLength + 1);
    var mainBody = encryptedBody.sublist(randomByteLength + 1);

    // 使用密钥对加密数据进行解密
    var decryptedBody = xor(mainBody, key);

    return decryptedBody;
  }
}
