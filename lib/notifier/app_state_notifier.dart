import 'package:flutter/material.dart';

class AppStateNotifier with ChangeNotifier {
  static AppStateNotifier? _instance;

  factory AppStateNotifier() {
    return _instance ??= AppStateNotifier._internal();
  }

  AppStateNotifier._internal();

  //是否需要弹出锁定码
  bool _enablePinDialog = true;

  bool get enablePinDialog => _enablePinDialog;

  set enablePinDialog(bool newData) {
    _enablePinDialog = newData;
    notifyListeners();
  }

  //是否进入后台
  bool _appHide = false;

  bool get appHide => _appHide;

  set appHide(bool newData) {
    _appHide = newData;
    notifyListeners();
  }

  //app前后台状态
  AppLifecycleState? _state;

  AppLifecycleState? get state => _state;

  set state(AppLifecycleState? newData) {
    _state = newData;
    switch (state) {
      //进入前台
      case AppLifecycleState.resumed:
        break;
      //切换到后台
      case AppLifecycleState.inactive:
        break;
      //进入后台
      case AppLifecycleState.paused:
        break;
      //即将退出
      case AppLifecycleState.detached:
        break;
      default:
        break;
    }
    notifyListeners();
  }
}
