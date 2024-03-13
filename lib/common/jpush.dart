// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:unionchat/common/func.dart';
// import 'package:unionchat/common/interceptor.dart';
// import 'package:unionchat/pages/account/login.dart';
// import 'package:jpush_flutter/jpush_flutter.dart';
//
// import '../adapter/adapter.dart';
// import '../pages/chat/chat_talk.dart';
// import 'global.dart';
//
// //极光推送
// class JGPush {
//   static String appKey = ''; //极光推送申请appKey
//   static String channel = 'theChannel'; //极光推送channel，暂时填写默认值即可
//
//   JPush jPush = JPush();
//
//   JGPush() {
//     if (appKey.isEmpty) return;
//     jPush.addEventHandler(
//       // 接收通知回调方法。
//       onReceiveNotification: (Map<String, dynamic> message) async {
//         // logger.d('flutter onReceiveNotification: $message');
//       },
//       // 点击通知回调方法。
//       onOpenNotification: (Map<String, dynamic> message) async {
//         logger.d('推送消息: $message');
//         onPushClick(message);
//       },
//       // 接收自定义消息回调方法。
//       onReceiveMessage: (Map<String, dynamic> message) async {
//         // logger.d('flutter onReceiveMessage: $message');
//       },
//       onReceiveNotificationAuthorization: (Map<String, dynamic> message) async {
//         // logger.d('flutter onReceiveNotificationAuthorization: $message');
//       },
//       onConnected: (Map<String, dynamic> message) async {
//         logger.d('推送连接: $message');
//       },
//     );
//     jPush.setup(
//       appKey: appKey,
//       channel: channel,
//       production: false,
//       debug: true, // 设置是否打印 debug 日志
//     );
//   }
//
//   // 设置应用角标
//   setBadge(int num) async {
//     jPush.setBadge(num);
//   }
//
//   // 设置应用角标
//   clearAllNotifications() async {
//     jPush.clearAllNotifications();
//   }
//
//   //点击消息推送
//   onPushClick(Map<String, dynamic> msg) async {
//     jPush.setBadge(0);
//     jPush.clearAllNotifications();
//     dynamic custom = msg['alert'];
//     if (custom == null) {
//       return;
//     }
//     final data = jsonDecode(custom);
//     final ctx = Global.navigatorKey.currentState?.overlay?.context;
//     if (ctx == null) {
//       logger.d('APP关闭状态下推送消息');
//       // APP关闭状态下推送
//       // Global.setMessage(type, id);
//       return;
//     }
//     // app打开状态下直接进入消息详情
//     if (Global.user != null && Global.token.isNotEmpty) {
//       String pairId = data['pairId'] ?? '';
//       if (pairId.isEmpty) return;
//       var mineId = Global.user?.id ?? '';
//       var ids = extractIntegersFromPairId(data['pairId']);
//       var aid = ids[0];
//       var bid = ids[1];
//       var receiver = '';
//       var receiverRoom = '';
//       var room = aid <= 0 || bid <= 0;
//       if (room) {
//         receiverRoom = (aid > 0 ? aid : bid).toString();
//       } else {
//         receiver = (aid.toString() != mineId ? aid : bid).toString();
//       }
//       Navigator.pushNamed(
//         ctx,
//         ChatTalk.path,
//         arguments: {
//           'receiver': receiver,
//           'roomId': receiverRoom,
//         },
//       );
//     } else {
//       Adapter.navigatorTo(Login.path, removeUntil: true);
//     }
//   }
//
//   //设置用户账号
//   setAccount(String uid) {
//     final account = '$uid+${apiEnv.pushTag}';
//     jPush.setAlias(account);
//   }
//
//   //清除用户账号
//   cleanAccounts() {
//     jPush.deleteAlias();
//   }
// }
