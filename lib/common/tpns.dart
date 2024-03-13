import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:tpns_flutter_plugin/tpns_flutter_plugin.dart';

import '../adapter/adapter.dart';
import '../global.dart';
import '../pages/chat/chat_talk.dart';
import '../pages/chat/widgets/chat_talk_model.dart';

//消息推送
class Tpns {
  static String iosAccessId = '';
  static String iosAccessKey = '';

  static String androidAccessId = '';
  static String androidAccessKey = '';
  static String domainName = '';

  XgFlutterPlugin tpush = XgFlutterPlugin();

  Tpns() {
    String accessId = ''; //腾讯云推送官网注册所得ACCESS_ID
    String accessKey = ''; //腾讯云推送官网注册所得ACCESS_KEY
    if (Platform.isIOS) {
      accessId = iosAccessId;
      accessKey = iosAccessKey;
    } else if (Platform.isAndroid) {
      accessId = androidAccessId;
      accessKey = androidAccessKey;
    } else {
      return;
    }
    if (accessId.isEmpty) return;
    if (Platform.isIOS && domainName.isNotEmpty) {
      tpush.configureClusterDomainName(domainName); //ios集群域名配置
    }
    if (Platform.isAndroid) {
      tpush.getXgAndroidApi().enableOtherPush();
    }
    tpush.setEnableDebug(false);
    tpush.startXg(accessId, accessKey, withInAppAlert: false);
    tpush.setTags([apiEnv.pushTag]);
    tpush.addEventHandler(
      // 点击推送
      xgPushClickAction: (event) async {
        logger.d(event);
        _onPushClick(event);
      },
      onRegisteredDeviceToken: (String msg) async {
        logger.e('消息推送注册失败: $msg');
      },
      onRegisteredDone: (String msg) async {
        // logger.d('消息推送注册完成: $msg');
      },
      unRegistered: (String msg) async {
        logger.d('消息推送注销完成: $msg');
      },
      onReceiveNotificationResponse: (Map<String, dynamic> msg) async {
        // logger.d('flutter onReceiveNotificationResponse $msg');
      },
      onReceiveMessage: (Map<String, dynamic> msg) async {
        // logger.d('flutter onReceiveMessage $msg');
      },
      xgPushDidSetBadge: (String msg) async {
        // logger.d('flutter xgPushDidSetBadge: $msg');
      },
      xgPushDidBindWithIdentifier: (String msg) async {
        // logger.d('flutter xgPushDidBindWithIdentifier: $msg');
      },
      xgPushDidUnbindWithIdentifier: (String msg) async {
        // logger.d('flutter xgPushDidUnbindWithIdentifier: $msg');
      },
      xgPushDidUpdatedBindedIdentifier: (String msg) async {
        // logger.d('flutter xgPushDidUpdatedBindedIdentifier: $msg');
      },
      xgPushDidClearAllIdentifiers: (String msg) async {
        // logger.d('flutter xgPushDidClearAllIdentifiers: $msg');
      },
    );
  }

  // 设置应用角标
  setBadge(int num) async {
    if (Platform.isAndroid) {
      if (num == 0) {
        tpush.getXgAndroidApi().resetBadgeNum();
      } else {
        tpush.getXgAndroidApi().setBadgeNum(badgeNum: num);
      }
    } else if (Platform.isIOS) {
      tpush.setAppBadge(num);
      tpush.setBadge(num);
    }
  }

  // 清空通知栏推送
  cleanToolNotice() {
    if (Platform.isAndroid) {
      tpush.getXgAndroidApi().cancelAllNotification();
    }
  }

  //点击消息推送
  _onPushClick(Map<String, dynamic> msg) async {
    cleanToolNotice();
    setBadge(0);
    dynamic custom;
    if (Platform.isIOS) {
      custom = msg['custom'];
    } else {
      custom = msg['customMessage'];
    }
    if (custom == null) {
      return;
    }
    final ctx = Global.navigatorKey.currentState?.overlay?.context;
    if (ctx == null) return;
    final data = jsonDecode(custom);
    String pairId = data['pairId'] ?? '';
    if (pairId.isEmpty) return;
    var mineId = Global.user?.id ?? '';
    var ids = extractIntegersFromPairId(data['pairId']);
    var aid = ids[0];
    var bid = ids[1];
    var receiver = '';
    var receiverRoom = '';
    var room = aid <= 0 || bid <= 0;
    if (room) {
      receiverRoom = (aid > 0 ? aid : bid).toString();
    } else {
      receiver = (aid.toString() != mineId ? aid : bid).toString();
    }
    if (!Global.appIn) {
      Global.noticeReceiver = receiver;
      Global.noticeRoomId = receiverRoom;
      return;
    }
    if (Global.user != null && Global.token != null) {
      Navigator.pushNamed(
        ctx,
        ChatTalk.path,
        arguments: ChatTalkParams(
          receiver: receiver,
          roomId: receiverRoom,
        ),
      );
    } else {
      Adapter.navigatorTo(Login.path, removeUntil: true);
    }
  }

  //设置用户账号
  setAccount(String uid) {
    final account = '$uid-${apiEnv.pushTag}';
    tpush.setAccount(account, AccountType.UNKNOWN);
  }

  //清除用户账号
  cleanAccounts() {
    tpush.cleanAccounts();
  }
}
