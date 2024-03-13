import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/network_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:provider/provider.dart';

class AppNetworkReconnect extends StatefulWidget {
  const AppNetworkReconnect({super.key});

  @override
  State<AppNetworkReconnect> createState() => _AppNetworkReconnectState();
}

class _AppNetworkReconnectState extends State<AppNetworkReconnect> {
  StreamSubscription? subscription;
  final ValueNotifier<ConnectivityResult?> _state = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    () async {
      _state.value = await Connectivity().checkConnectivity();
    }();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      _state.value = result;
      logger.d(result);
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.white,
      appBar: AppBar(
        title: const Text('网络检测'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _state,
                builder: (context, value, _) {
                  return Text('当前网络状态：${value == null ? '-' : value.name}');
                },
              ),
              ValueListenableBuilder(
                valueListenable: AppNetworkNotifier.state,
                builder: (context, value, _) {
                  return Column(
                    children: [
                      Text(
                        value.toChar,
                        style: TextStyle(
                          color: value == AppNetworkState.link
                              ? myColors.green
                              : myColors.red,
                        ),
                      ),
                      if (value == AppNetworkState.no)
                        Text(
                          '请检查设备的网络连接，应用无法找到可用的网络！',
                          style: TextStyle(
                            color: myColors.red,
                          ),
                        ),
                      if (value == AppNetworkState.error)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: CircleButton(
                            onTap: () async {
                              var success = await Global.initDataInfo();
                              if (success) {
                                tipSuccess('已获取到可用的服务器');
                              }
                            },
                            title: '重新分配服务器',
                            height: 40,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
