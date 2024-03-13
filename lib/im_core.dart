library im_core;

import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/notifier/custom_emoji_notifier.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/notifier/number_condition_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/call/window_calling.dart';
import 'package:unionchat/pages/launch_screen.dart';
import 'package:provider/provider.dart';

import 'global.dart';
import 'common/tpns.dart';

isRunningInPackage() {
  Global.isRunningInPackage = true;
}

setTpnsConfig({
  String domainName = '',
  String iosAccessId = '',
  String iosAccessKey = '',
  String androidAccessId = '',
  String androidAccessKey = '',
}) {
  Tpns.domainName = domainName;
  Tpns.iosAccessId = iosAccessId;
  Tpns.iosAccessKey = iosAccessKey;
  Tpns.androidAccessId = androidAccessId;
  Tpns.androidAccessKey = androidAccessKey;
}

// setJGPnsConfig({
//   String appKey = '',
//   String channel = '',
// }) {
//   JGPush.appKey = appKey;
//   if(channel.isNotEmpty) JGPush.channel = channel;
// }

setRoomShowTotal(bool show) {
  FunctionConfig.roomShowTotal = show;
}

// setRegisterIcCode(bool show) {
//   FunctionConfig.registerIcCode = show;
// }

setIm(bool im) {
  Global.im = im;
}

// 设置接口地址
setApiUrl({
  required String apiUrl,
}) {
  Global.apiUrl = apiUrl;
}

void start(
  List<String> args, {
  Widget? launchScreen,
}) {
  // 设置自定义的错误处理函数
  FlutterError.onError = (FlutterErrorDetails details) {
    // 在这里添加你的错误处理逻辑
    logger.e('捕获到Flutter框架错误: ${details.exception}');

    // 调用默认的错误处理器
    FlutterError.presentError(details);
  };

  launchScreen ??= const DefaultLaunchPage();
  if (args.length == 3 && args[0] == 'multi_window') {
    final windowId = int.parse(args[1]);
    final argument = args[2].isEmpty ? const {} : jsonDecode(args[2]);
    runApp(WindowCalling(
      windowController: WindowController.fromWindowId(windowId),
      args: argument,
    ));
  } else {
    Global.initENV().then((_) {
      runApp(
        EasyLocalization(
          supportedLocales: const [
            Locale('zh', ''),
            Locale('en', ''),
          ],
          path: assetPath('translations'),
          fallbackLocale: const Locale('zh', ''),
          child: MyApp(launchScreen!),
        ),
      );
      if (Platform.isAndroid) {
        SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
        );
        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      }
    });
  }
}

setStoreKey({
  required String storeKey,
}) {
  Global.storeSecret = storeKey;
}

// 接口地址远程配置文件
setApisJsonUrl({
  required List<String> urls,
}) {
  Global.apisJsonUrl = urls;
}

// 开启加密通讯, 传入服务器公钥
setEncrypt({
  required bool isEncrypt,
  required String secret,
  required String iv,
}) {
  Global.isEncrypt = isEncrypt;
  Global.secret = secret;
  Global.iv = iv;
}

class MyApp extends StatelessWidget {
  final Widget launchScreen;

  const MyApp(this.launchScreen, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider<ChatTalkNotifier>(
        //   create: (context) => ChatTalkNotifier(),
        // ),
        ChangeNotifierProvider<FriendListNotifier>(
          create: (context) => FriendListNotifier(),
        ),
        ChangeNotifierProvider<NumberConditionNotifier>(
          create: (context) => NumberConditionNotifier(),
        ),
        ChangeNotifierProvider<CustomEmojiNotifier>(
          create: (context) => CustomEmojiNotifier(),
        ),
        ChangeNotifierProvider<ThemeNotifier>(
          create: (context) => ThemeNotifier()..loadTheme(),
        ),
      ],
      child: Adapter(
        home: LaunchScreen(child: launchScreen),
      ),
    );
  }
}
