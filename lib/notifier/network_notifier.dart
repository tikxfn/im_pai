import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';

import '../common/interceptor.dart';

enum AppNetworkState {
  // 没有网络连接
  no,
  // 网络正常
  link,
  // 服务器连接失败
  error,
}

extension AppNetworkStateExt on AppNetworkState {
  String get toChar {
    switch (this) {
      case AppNetworkState.no:
        return '无网络连接';
      case AppNetworkState.link:
        return '网络正常';
      case AppNetworkState.error:
        return '服务器连接失败';
    }
  }
}

class AppNetworkNotifier {
  // 当前连接状态
  static ValueNotifier<AppNetworkState> state =
      ValueNotifier(AppNetworkState.link);

  // 设备网络连接监听器
  static StreamSubscription? _subscription;

  // 设备网络连接监听
  static listenNetwork() {
    _subscription = Connectivity().onConnectivityChanged.listen(
          (ConnectivityResult result) {
        if (state.value == AppNetworkState.error) return;
        if (result == ConnectivityResult.none) {
          state.value = AppNetworkState.no;
        } else {
          state.value = AppNetworkState.link;
        }
      },
    );
  }

  // 关闭网络监听
  static listenDispose() {
    _subscription?.cancel();
  }

  // 连接错误次数
  static int _errorCount = 0;

  // 增加错误次数
  static Future<void> addErrorCount() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      state.value = AppNetworkState.no;
      return;
    }
    _errorCount++;
    if (_errorCount < 5 || _testing) return;
    _testApiUrl();
  }

  // 重置错误次数
  static linkSuccess() {
    _errorCount = 0;
    state.value = AppNetworkState.link;
  }

  // 接口重试次数
  static int _reconnectCount = 0;

  // 是否正在重试
  static bool _testing = false;

  // 测试api地址是否可用
  static Future<void> _testApiUrl() async {
    if (_testing) return;
    _testing = true;
    try {
      final api = SettingApi(apiClient());
      await api.settingPing({});
      linkSuccess();
      _testing = false;
      _reconnectCount = 0;
    } on ApiException catch (e) {
      onError(e, addErrorCount: false);
      _reconnectCount++;
      // 重试超过三次
      if (_reconnectCount >= 3) {
        _reconnectCount = 0;
        final connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.none) {
          state.value = AppNetworkState.no;
        } else {
          state.value = AppNetworkState.error;
          // Global.initDataInfo(loadText: '切换线路中');
        }
        _errorCount = 0;
        _testing = false;
      } else {
        _testing = false;
        _testApiUrl();
      }
    }
  }
}
