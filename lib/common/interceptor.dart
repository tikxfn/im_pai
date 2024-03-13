import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/aes.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/network_notifier.dart';
import 'package:unionchat/widgets/update_version_dialog.dart';
import 'package:openapi/api.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import '../global.dart';

void listenToSSE() async {
  final url = apiUrl();
  var client = HttpClient();
  final args = V1StreamArgs(
    nonce: randomString(),
  );
  var request = await client.postUrl(
    Uri.parse('$url/v1.Stream/Connect'),
  );
  final body = jsonEncode(args.toJson());
  request.headers.set('Accept', 'text/event-stream');
  String languageCode = Global.context?.locale.languageCode ?? 'zh-CN';
  switch (languageCode) {
    case 'zh':
      languageCode = 'zh-CN';
      break;
  }
  VersionInfo info = Global.versionInfo;
  final requestTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final appVersion = '${info.appVersion}(${info.appBuildNumber})';
  request.headers.set('accept-language', languageCode);
  request.headers.set('token', Global.token ?? ''); // 登录信息
  request.headers.set('dno', Global.dno); // 设备标识
  request.headers.set('c-platform', info.platform); // 平台
  request.headers.set('c-version', info.platformVersion); // 平台
  request.headers.set('c-request-time', '$requestTime');
  request.headers.set('app-version', appVersion); // 平台
  request.headers.set('merchant-id', Global.merchantId); // 商户id

  SignTool signTool = SignTool.instance;
  final sign = await signTool.sign(
    utf8.encode(body),
    '',
    requestTime,
  );
  request.headers.set('sign', sign); // 签名
  request.write(body);
  var response = await request.close();

  response.transform(utf8.decoder).listen((data) {
    final value = jsonDecode(data);
    final resp = V1StreamResp.fromJson(value['result']);
    // 处理接收到的数据
    logger.d(data);
    logger.d(resp);
  });
}

enum ApiEnv {
  local,
  dev,
  online,
}

ApiClient apiClient({
  bool tip = false,
  String url = '',
  Duration? timeout,
}) {
  final baseUrl = url.isNotEmpty ? url : apiUrl();
  var c = ApiClient(basePath: baseUrl);
  c.client = MyClient(isEncrypt: Global.isEncrypt, timeout: timeout);
  return c;
}

class MyClient extends http.BaseClient {
  final bool isEncrypt;
  final Duration? timeout;

  MyClient({
    this.isEncrypt = true,
    this.timeout,
  });

  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final req = request as http.Request;
    String randStr = '';
    String encryptString = '';
    // 修改 body 的值
    List<int> body = req.bodyBytes;
    if (isEncrypt) {
      randStr = randomString();
      encryptString = aesEncrypt(randStr, Global.secret, Global.iv);
      body = xor(
        request.bodyBytes,
        utf8.encode(randStr),
      );
      request.bodyBytes = body;
    }
    String languageCode = Global.context?.locale.languageCode ?? 'zh-CN';
    switch (languageCode) {
      case 'zh':
        languageCode = 'zh-CN';
        break;
    }
    VersionInfo info = Global.versionInfo;
    final requestTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final appVersion = '${info.appVersion}(${info.appBuildNumber})';
    request.headers['accept-language'] = languageCode;
    request.headers['token'] = Global.token ?? ''; // 登录信息
    request.headers['dno'] = Global.dno; // 设备标识
    request.headers['c-platform'] = info.platform; // 平台
    request.headers['c-version'] = info.platformVersion; // 平台
    request.headers['c-request-time'] = '$requestTime';
    request.headers['app-version'] = appVersion; // 平台
    request.headers['key'] = encryptString; // 随机字符串
    request.headers['merchant-id'] = Global.merchantId; // 商户id
    // logger.d(request.headers);
    // logger.d(request.url);

    SignTool signTool = SignTool.instance;
    final sign = await signTool.sign(
      body,
      encryptString,
      requestTime,
    );
    request.headers['sign'] = sign; // 签名
    late StreamedResponse response;
    if (timeout != null) {
      response = await _inner.send(request).timeout(timeout!);
    } else {
      response = await _inner.send(request);
    }
    AppNetworkNotifier.linkSuccess();
    // logger.d(response.headers['grpc-metadata-fuv']);
    // logger.d(updateDialog);
    if ((response.headers['grpc-metadata-fuv'] ?? '').isNotEmpty &&
        Global.context != null &&
        !request.url
            .toString()
            .toLowerCase()
            .contains('v1.SystemSetting/Info'.toLowerCase()) &&
        !updateDialog &&
        !kDebugMode) {
      updateDialog = true;
      await Global.getSystemInfo();
      if (Global.systemInfo.appVersion?.appVersion != null) {
        await showDialog(
          barrierDismissible: false,
          context: Global.context!,
          builder: (context) {
            return UpdateVersionDialog(
              Global.systemInfo.appVersion!.appVersion!,
              true,
            );
          },
        );
      }
    }
    Global.changeApiUrl(response.headers['grpc-metadata-dhx'] ?? '');
    List<int> responseBody = await response.stream.toBytes();
    if (isEncrypt) {
      responseBody = xor(
        responseBody,
        utf8.encode(randStr),
      );
    }
    final responseStr = utf8.decode(responseBody);
    if (responseStr == '{}' || responseStr == '[]') {
      responseBody = [];
    }
    final newStream = http.ByteStream.fromBytes(responseBody);
    final newResponse = http.StreamedResponse(
      newStream,
      response.statusCode,
      headers: response.headers,
      persistentConnection: response.persistentConnection,
      isRedirect: response.isRedirect,
      reasonPhrase: response.reasonPhrase,
      contentLength: responseBody.length,
      request: response.request,
    );
    return newResponse;
  }
}

class SignTool {
  static SignTool? _instance;
  final Credentials credentials;

  static SignTool get instance {
    _instance ??= SignTool.generate();
    return _instance!;
  }

  SignTool._(this.credentials);

  factory SignTool.generate() {
    final privateKey = settingsBox.get('privateKey');
    if (privateKey != null) {
      return SignTool._(EthPrivateKey.fromHex(privateKey));
    }
    Credentials credentials = EthPrivateKey.createRandom(Random.secure());
    EthPrivateKey key = credentials as EthPrivateKey;
    String privateKeyHex = bytesToHex(key.privateKey);
    settingsBox.put('privateKey', privateKeyHex);
    return SignTool._(credentials);
  }

  // 生成签名
  Future<String> sign(
    List<int> body,
    String encryptString,
    int requestTime,
  ) async {
    final s = '$encryptString$requestTime';
    List<int> signData = body.toList();
    signData.addAll(utf8.encode(s));
    final sign = credentials.signToUint8List(
      Uint8List.fromList(signData),
    );
    return '${credentials.address.hex}${bytesToHex(sign)}';
  }
}

// 生成随机数
String randomString() {
  const length = 32 - 10;
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random(DateTime.now().millisecondsSinceEpoch);
  final buf = StringBuffer();
  for (var x = 0; x < length; x++) {
    buf.write(chars[rnd.nextInt(chars.length)]);
  }
  // 10位替换成时间戳
  final uni = '${DateTime.now().millisecondsSinceEpoch ~/ 1000}';
  buf.write(uni);
  return buf.toString();
}

ApiEnv get apiEnv {
  const apiEnv = String.fromEnvironment('API_ENV', defaultValue: 'unknown');
  switch (apiEnv.toUpperCase()) {
    case 'LOCAL':
      return ApiEnv.local;
    case 'DEV':
      return ApiEnv.dev;
    case 'ONLINE':
      return ApiEnv.online;
    default:
      return ApiEnv.dev;
  }
}

extension ApiEnvPushTag on ApiEnv {
  String get pushTag {
    return toString().split('.').last;
  }
}

String apiUrl() {
  if (apiEnv == ApiEnv.dev) {
    // return 'http://imapi.lvdunhb.com';
  } else if (apiEnv == ApiEnv.local) {
    return 'http://127.0.0.1:5021';
  }
  // return 'http://127.0.0.1:5021';
  return Global.apiUrl;
}

void onError(
  ApiException e, {
  Function(ApiError)? handler,
  bool errTip = true,
  bool addErrorCount = true,
}) {
  logger.e(e);
  final apiErr = parseError(e);
  // 统计错误，连续5次连接不上，进入服务器连接失败
  if ((e.code == 400 || e.code == 502 || e.code == 504) && addErrorCount) {
    AppNetworkNotifier.addErrorCount();
  }
  if (apiErr.message.isNotEmpty &&
      errTip &&
      e.code != 400 &&
      (e.code <= 500 || e.code >= 600) &&
      containsChinese(apiErr.message)) {
    tip(apiErr.message);
    // tip('${apiErr.message} ${e.code}');
  }
  // if (e.code == 400) tip('网络信号差');
  var code = apiErr.code;
  if ((code == 1007 || code == 4305 || code == 4306) &&
      Global.context != null) {
    Global.loginOut();
  }
  if (handler != null) {
    handler(apiErr);
    return;
  }
}

ApiError parseError(ApiException e) {
  if (e.code != 500) {
    return ApiError(code: e.code, message: e.message ?? '');
  }
  Map<String, dynamic> jsonMap = jsonDecode(e.message ?? '');
  return ApiError.formJson(jsonMap);
}

class ApiError {
  final int code;
  final String message;

  ApiError({required this.code, required this.message});

  factory ApiError.formJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'],
      message: json['message'],
    );
  }

  @override
  String toString() {
    return 'code: $code, message: $message';
  }
}
