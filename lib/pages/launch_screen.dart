import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/debug_log.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/update_version_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';

class DefaultLaunchPage extends StatelessWidget {
  const DefaultLaunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
    return Container(
      decoration: BoxDecoration(
        // color: myColors.launchColor,
        image: DecorationImage(
          image: Image.asset(assetPath('images/launch_bg.png')).image,
          fit: BoxFit.cover,
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: OverflowBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Image.asset(
                  assetPath('images/launch_logo.png'),
                  width: 63,
                  height: 101,
                  fit: BoxFit.contain,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //     left: 100,
              //   ),
              //   child: Image.asset(
              //     assetPath('images/launch_rw2.png'),
              //     width: 180,
              //   ),
              // ),
              // Expanded(
              //   child: Column(
              //     children: [
              //       const Spacer(
              //         flex: 3, // 占据3份
              //       ),
              //       Padding(
              //         padding: const EdgeInsets.only(
              //           // top: 20,
              //           right: 120,
              //         ),
              //         child: Image.asset(
              //           assetPath('images/launch_rw1.png'),
              //           width: 180,
              //         ),
              //       ),
              //       const Spacer(
              //         flex: 1, // 占据1份
              //       ),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}

// 启动页
class LaunchScreen extends StatefulWidget {
  final Widget child;

  const LaunchScreen({super.key, required this.child});

  @override
  State<LaunchScreen> createState() => LaunchScreenState();
}

class LaunchScreenState extends State<LaunchScreen> {
  String initialRoute = '';
  StreamSubscription? subscription;
  bool networkFailed = false;
  bool apiError = false;
  bool _systemError = false;

  Timer? _initLogsTimer;
  double _logsTapCount = 0;
  bool _showInitLogs = false;

  // 打开日志按钮
  _openInitLogs() {
    _initLogsTimer?.cancel();
    _logsTapCount++;
    if (_logsTapCount >= 8) {
      tip('已显示日志按钮');
      setState(() {
        _showInitLogs = true;
      });
    }
    _initLogsTimer = Timer(const Duration(seconds: 1), () {
      _logsTapCount = 0;
    });
  }

  //获取版本号
  Future<bool> _getVersion() async {
    var version = Global.systemInfo.appVersion?.appVersion?.version ?? '';
    if (Platform.isIOS) {
      version = Global.systemInfo.appVersion?.appVersion?.iosVersion ?? '';
    }
    final forceUpdate =
        toBool(Global.systemInfo.appVersion?.appVersion?.isForceUpdate);
    if (version.isEmpty) return true;
    if (version2int(version) > version2int(Global.versionInfo.appVersion) &&
        mounted) {
      if (!kDebugMode) {
        await showDialog(
          barrierDismissible: !forceUpdate,
          context: context,
          builder: (context) {
            return UpdateVersionDialog(
              Global.systemInfo.appVersion!.appVersion!,
              forceUpdate,
            );
          },
        );
      }

      goNextUrl();
      return false;
    }
    return true;
  }

  //进入首页
  goNextUrl() async {
    await _requestNotice();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      initialRoute,
      (route) => false,
    );
  }

  // 网络链接失败
  _networkFail() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      networkFailed = true;
    } else if (mounted) {
      setState(() {
        apiError = true;
      });
    }
  }

  //启动
  _launch({bool load = false}) async {
    if (!is64BitSystem()) {
      tipError('当前APP版本暂不支持 32 位系统');
      setState(() {
        _systemError = true;
      });
      return;
    }
    if (load) loading();
    if (apiError && mounted) {
      setState(() {
        apiError = false;
      });
    }
    try {
      bool dataInit = false;
      List<Future> futures = [
        () async {
          dataInit = await Global.initDataInfo();
        }(),
        Future.delayed(const Duration(seconds: 1)),
      ];
      await Future.wait(futures);
      if (!dataInit) {
        _networkFail();
        return;
      }
      // setState(() {
      //   apiError = true;
      // });
      // return;
      initialRoute = Global.getInitialRoute();
      var go = await _getVersion();
      if (go && mounted) {
        goNextUrl();
      }
    } catch (e) {
      _networkFail();
      rethrow;
    } finally {
      if (load) loadClose();
    }
  }

  // 请求通知权限
  _requestNotice() async {
    var first = settingsBox.get('firstNotice') ?? '';
    if (!Platform.isAndroid || first.isNotEmpty) return;
    settingsBox.put('firstNotice', '1');
    var state = await Permission.notification.request();
    if (!mounted) return;
    if (!state.isGranted) {
      var cfm = await confirm(
        context,
        title: '未打开通知权限',
        content: '未打开通知权限，无法接收到好友的消息通知等，是否需要前往设置开启通知权限。',
        enter: '去开启',
      );
      if (cfm == true) {
        openAppSettings();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Global.tpns?.setBadge(0);
    Global.tpns?.cleanToolNotice();
    // if (Platform.isAndroid) Permission.notification.request();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (networkFailed && result != ConnectivityResult.none) {
        _launch();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launch();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Wakelock.enable();
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          // onTap: _openInitLogs,
          child: widget.child,
        ),
        if (_systemError)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: const Text(
                  '当前APP版本暂不支持 32 位系统',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        if (apiError)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showInitLogs)
                      CircleButton(
                        theme: AppButtonTheme.red,
                        title: '查看失败原因',
                        fontSize: 16,
                        height: 40,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppDebugLog(),
                            ),
                          );
                          // confirm(context);
                          // _launch(load: true);
                        },
                      ),
                    const SizedBox(height: 15),
                    CircleButton(
                      title: '加载失败，点击重试',
                      fontSize: 16,
                      height: 40,
                      onTap: () {
                        _launch(load: true);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
