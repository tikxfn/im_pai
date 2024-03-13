import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:openapi/api.dart';

import '../pages/chat/chat_talk.dart';
import '../pages/tabs.dart';

class ApiRequest {
  //发送消息
  static Future<void> apiSendMessage({
    required List<Message> list,
    List<String>? ids,
    List<String>? roomIds,
  }) async {
    if (ids != null) {
      for (var id in ids) {
        for (var msg in list) {
          msg.senderUser = getSenderUser();
          msg.pairId = generatePairId(toInt(id), toInt(Global.user!.id));
          msg.receiverRoomId = null;
          msg.receiverUserId = toInt(id);
          msg.sender = toInt(Global.user?.id);
          msg.createTime = int.parse(date2time(null));
          await MessageUtil.send(msg);
        }
      }
    }
    if (roomIds != null) {
      for (var id in roomIds) {
        for (var msg in list) {
          msg.senderUser = getSenderUser();
          msg.pairId = generatePairId(toInt(id), 0);
          msg.receiverRoomId = toInt(id);
          msg.receiverUserId = null;
          msg.sender = toInt(Global.user?.id);
          msg.createTime = int.parse(date2time(null));
          await MessageUtil.send(msg);
        }
      }
    }
  }

  //设置消息已读
  static Future<void> apiMessageRead(List<String> pairIds) async {
    try {
      await MessageUtil.resetUnreadCount(pairIds);
      await MessageUtil.reportRead(pairIds);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // 设置消息自毁时间
  static Future<void> setTopicDestroyDuration(
    String pairId,
    int duration,
  ) async {
    var api = ChannelApi(apiClient());
    try {
      var args = V1ChannelSetDestroyTimeArgs(
        pairId: pairId,
        duration: duration.toString(),
      );
      await api.channelSetDestroyTime(args);
      if (pairId.isEmpty) {
        Global.user?.chatDestroyDuration = duration.toString();
      } else {
        // todo:设置消息自毁时间
        // await DatabaseOperator.setTopicDestroyDuration(pairId, duration);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // 登录确认
  static Future<V1PassportLoginResp?> loginConfirm(
    BuildContext context,
    V1PassportLoginResp loginResp,
  ) async {
    var cfm = await confirm(
      context,
      title: '新设备登录',
      content: '请在已登录的设备上授权允许当前设备登录',
      enter: '已授权',
    );
    if (cfm == null || !cfm) return null;
    final api = PassportApi(apiClient());
    loading(text: '正在确认');
    try {
      var args = GUserLoginResp(authorization: loginResp.authorization);
      return await api.passportGetInfo(args);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return null;
  }

  static bool showAuth = false;

  // 授权新设备登录
  static Future<void> authorizationLogin(
    String? authorization,
  ) async {
    if (Global.context == null ||
        authorization == null ||
        authorization.isEmpty ||
        showAuth ||
        Global.token == null) {
      return;
    }
    showAuth = true;
    var cfm = await confirm(
      Global.context!,
      title: '授权登录',
      content: '有新的设备正在发起登录请求，是否授权新设备登录',
      enter: '允许登录',
    );
    showAuth = false;
    if (cfm == null || !cfm) return;
    final api = PassportApi(apiClient());
    loading();
    try {
      var args = GUserLoginResp(authorization: authorization);
      await api.passportConfirmLogin(args);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      showAuth = false;
      loadClose();
    }
  }

  static bool showHelp = false;

  // 辅助好友找回密码
  static Future<void> helpFriendSetPassword(
    String? loginToken,
    String? account,
  ) async {
    if (Global.context == null ||
        loginToken == null ||
        loginToken.isEmpty ||
        account == null ||
        account.isEmpty ||
        showHelp ||
        Global.token == null) {
      return;
    }
    showHelp = true;
    var cfm = await confirm(
      Global.context!,
      title: '辅助登录',
      content: '请确认该好友身份，是否帮助"$account"找回密码',
      enter: '确认好友',
    );
    showHelp = false;
    if (cfm == null || !cfm) return;
    final api = PassportApi(apiClient());
    loading();
    logger.i('$account-------$loginToken');
    try {
      var args =
          V1PassportAssistFriendLoginArgs(account: account, token: loginToken);
      await api.passportAssistFriendLogin(args);
      logger.i('sucess');
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      showHelp = false;
      loadClose();
    }
  }

  //清空聊天记录
  static Future<void> removeHistory(String pairId, {bool undo = false}) async {
    loading();
    // var api = MessageApi(apiClient());
    try {
      await MessageUtil.clearChannelMessages(pairId, both: undo);
      tipSuccess('操作成功');
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //同意、拒绝清空我的聊天记录
  static Future<void> updateCleanMessage(
      String pairId, GCleanStatus status) async {
    loading();
    var api = MessageApi(apiClient());
    try {
      var args = V1MessageVerifyClearArgs(
        pairId: pairId,
        status: status,
      );
      await api.messageVerifyClear(args);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  // 清空我的聊天记录授权框
  static Future<void> agreeCleanMyMessage(String pairId) async {
    if (Global.context == null) return;
    var cfm = await confirm(
      Global.context!,
      title: '授权清空消息记录',
      content: '对方正在请求清空当前对话的消息记录！',
      enter: '清空我的消息记录',
      cancel: '拒绝',
    );
    if (cfm == null) return;
    await updateCleanMessage(
      pairId,
      cfm ? GCleanStatus.AGREE : GCleanStatus.REJECT,
    );
    if (cfm == true) await removeHistory(pairId);
  }

  //前往查看好友清空我的对话框
  static Future<void> seeCleanTopic(String pairId) async {
    var channel = await MessageUtil.getChannelByPairId(pairId);
    if (channel == null) return;
    var nickName = channel.senderUser?.nickname ?? '';
    var mark = channel.senderUser?.mark ?? '';
    if (Global.context == null) return;
    var cfm = await confirm(
      Global.context!,
      title: '授权提醒',
      content:
          '您的好友 "${mark.isEmpty ? nickName : mark}" 正在申请清除你们的对话消息记录，请前往查看详情！',
      enter: '立即查看',
    );
    if (cfm != true) return;
    var args = chat2talkParams(channel2chatItem(channel));
    Navigator.pushNamedAndRemoveUntil(
      Global.context!,
      ChatTalk.path,
      ModalRoute.withName(Tabs.path),
      arguments: args,
      // arguments: ChatTalkParams(
      //   receiver: channel.relateId ?? '',
      //   name: channel.nickname ?? '',
      //   mark: channel.mark ?? '',
      // ),
    );
  }

  // 禁言用户
  static Future<bool> apiUserSilence(
    List<String> userIds,
    String roomId, {
    bool load = false,
  }) async {
    final api = RoomApi(apiClient());
    if (load) loading();
    try {
      int now = DateTime.now().millisecondsSinceEpoch;
      String time = (2 * now).toString();
      var args = V1SetMemberProhibitionArgs(
        roomId: roomId,
        ids: userIds,
        prohibitionTime: time,
      );
      logger.d(args);
      await api.roomSetMemberProhibition(args);
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    } finally {
      if (load) loadClose();
    }
  }
}
