import 'dart:async';
import 'dart:math';

import 'package:isar/isar.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/app_prompt.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/db.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/channel.dart';
import 'package:unionchat/db/model/channel_group.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/room_member.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/db/notifier/channel_page_notifier.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/db/operator/channel_operator.dart';
import 'package:unionchat/db/operator/mark_up_operator.dart';
import 'package:unionchat/db/operator/message_operator.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/call/call_remind.dart';
import 'package:unionchat/pages/call/call_variable.dart';
import 'package:unionchat/task/task.dart';

class SearchResultItem {
  final String pairId;
  final Channel channel;
  final List<Message> messages;

  SearchResultItem(this.pairId, this.channel, this.messages);
}

class MessageUtil {
  // 到收到请求清空消息的时候调用
  static final StreamController<String> applyClearMessageController =
      StreamController<String>.broadcast();

  static int get userId {
    final id = toInt(Global.user?.id);
    if (id == 0) {
      throw Exception('userId is empty');
    }
    return id;
  }

  // 消息置顶
  static Future<void> top(String pairId, bool top) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, pairId);
      if (channel == null) return;
      channel.topTime = top ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;
      final api = ChannelApi(apiClient());
      await api.channelSetTopTime(V1ChannelSetTopTimeArgs(
        pairId: pairId,
        topTime: channel.topTime.toString(),
      ));
      await ChannelOperator.save(isar, channel);
      // 更新状态管理
      ChannelListNotifier().insert(channel);
      // 重新排序
      ChannelListNotifier().sort();
      // logger.d('----------a');
    });
  }

  // 设置是否静音
  static Future<void> silence(String pairId, bool silence) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, pairId);
      if (channel == null) return;
      // 更新接口
      final api = ChannelApi(apiClient());
      await api.channelSetDoNotDisturb(V1ChannelSetDoNotDisturbArgs(
        pairId: pairId,
        isOpen: silence,
      ));
      channel.doNotDisturb = silence;
      await ChannelOperator.save(isar, channel);
      // 更新状态管理
      ChannelListNotifier().insert(channel);
      logger.d('----------b');
    });
  }

  // 接收到新消息
  static Future<Message?> receive(
    GMessageModel data, {
    bool checkDno = true, // 是否验证dno
    bool updateLatest = true, // 是否更新最后一条消息
    bool insertToPage = true,
  }) async {
    final id = toInt(data.id);
    final pairId = data.pairId ?? '';
    assert(id > 0, 'message id must be not empty');
    assert(pairId.isNotEmpty, 'pairId must be not empty');
    final isar = await DB.getIsar(userId);
    bool inserted = false;
    Channel? channel;
    Message? message;
    bool notice = false;
    bool isNew = false;
    await isar.writeTxn(() async {
      // 更新消息最大的id
      await MarkUpOperator.setMessageMaxUpId(isar, toInt(data.upId));
      if (checkDno && data.senderDno == Global.dno) {
        return;
      }
      message = await MessageOperator.getById(isar, id);
      if (message == null) {
        isNew = true;
        message = Message();
      }
      message!.load(data);
      final page = ChannelPageNotifier.getByPairId(pairId);
      // 同步 channel, 修改channel的最后一条消息id
      channel = await _getChannel(pairId);
      _setLastMessage(channel!, message!);

      // 如果发送者是我自己
      if (message!.sender == userId) {
        message!.readed = true;
        channel!.lastReadId = message!.id;
      }
      // 消息已读
      if (channel!.lastReadId >= message!.id) {
        message!.readed = true;
      }
      // 对方是否已读
      if (channel!.otherReadId != null &&
          channel!.otherReadId! >= message!.id &&
          message!.status != GMessageStatus.REVOKE) {
        message!.status = GMessageStatus.READ;
      }
      if (page != null) {
        // 如果在当前页面
        message!.readed = true;
        channel!.lastReadId = message!.id;
        channel!.unreadCount = 0;
      }

      if (!message!.readed) {
        // 如果at我
        final atMe = (message!.at.contains(userId));
        if (atMe && !channel!.atMessageIds.contains(message!.id)) {
          channel!.atMessageIds = channel!.atMessageIds.toList()
            ..add(message!.id);
        }
        if (isNew) {
          // 新消息
          channel!.unreadCount++;
          if (!channel!.doNotDisturb || atMe) {
            notice = true;
          }
        }
      }
      // 更新群成员信息
      await _updateRoomMemberForMessage(isar, pairId, message!);
      await MessageOperator.save(isar, message!);
      if (updateLatest && channel != null) {
        await ChannelOperator.save(isar, channel!);
        await ChannelListNotifier().insert(channel!);
      }
      // 将数据插入页面
      if (insertToPage) {
        inserted = ChannelPageNotifier.insertMessage(message!);
      }
    });
    if (message == null) return null;
    // 更新未读数量
    ChannelListNotifier().refreshUnreadCount();
    // 插入成功，证明消息在当前页面(通知消息已读)
    if (inserted) {
      reportRead([pairId]);
    }
    await _checkCallMessage(
      message!,
      onBusy: _onBusy,
      onRing: (message) async {
        notice = false; // 电话响了就不铃声通知
        CallRemind().show(
          avatar: channel!.avatar ?? '',
          name: channel!.name ?? '',
          msg: message,
          video: message.type == GMessageType.VIDEO_CALL,
        );
      },
      onRingClose: (message) async {
        AppPrompt.stopAll();
        await CallRemind().close();
      },
      onExpired: _onExpired,
    );
    if (notice) {
      // 需要响铃通知
      messageNotice(message: true);
    }
    return message;
  }

  static Future<void> _onBusy(Message message) async {
    final isar = await DB.getIsar(userId);
    final api = MessageApi(apiClient());
    await api.messageSetBusy(V1MessageIdArgs(
      id: message.id.toString(),
      pairId: message.pairId,
    ));
    await isar.writeTxn(() async {
      message.callStatus = GCallStatus.BUSY;
      await MessageOperator.save(isar, message);
      MessageNotifier.update(message);
    });
  }

  static Future<void> _onExpired(Message message) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      message.callStatus = GCallStatus.EXPIRED;
      await MessageOperator.save(isar, message);
      MessageNotifier.update(message);
    });
  }

  // 检查通话消息；返回是否通话响铃
  static Future<void> _checkCallMessage(
    Message message, {
    required Future<void> Function(Message) onBusy, // 忙线的操作
    required Future<void> Function(Message) onRing, // 响铃
    required Future<void> Function(Message) onRingClose, // 关闭响铃
    required Future<void> Function(Message) onExpired, // 过期了
  }) async {
    switch (message.callStatus) {
      case GCallStatus.NIL: // NOTHING
        return;
      case GCallStatus.ACCEPT:
        return;
      case GCallStatus.REJECT:
      case GCallStatus.HANG_UP:
      case GCallStatus.EXPIRED:
      case GCallStatus.CANCEL:
      case GCallStatus.BUSY:
        // 关闭响铃
        if (CallRemind.msgId == message.id) {
          await onRingClose(message);
        }
        break;
      case GCallStatus.WAIT:
        if (CallRemind.msgId != null && CallRemind.msgId != message.id) {
          // 忙线
          await onBusy(message);
          return;
        }
        if (CallVariable.msgId.value != null &&
            CallVariable.msgId.value != message.id) {
          // 忙线
          await onBusy(message);
          return;
        }
        if (message.receiverUserId == userId) {
          // 判断是否视频消息请求
          final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
          if (now - message.createTime > 30) {
            await onExpired(message);
            return;
          }
          await onRing(message);
          return;
        }
        return;
      default:
        return;
    }
    return;
  }

  static Future<void> reportRead(List<String> pairIds) async {
    final api = ChannelApi(apiClient());
    await api.channelSetRead(V1ChannelSetReadArgs(pairIds: pairIds));
  }

  // 发送消息
  static Future<void> send(Message message) async {
    // 随机生成一个upid
    var random = Random();
    message.upId = random.nextInt(2 << 31);
    final pairId = message.pairId ?? '';
    if (pairId.isEmpty) {
      throw Exception('pairId is empty');
    }
    if (message.type == GMessageType.TEXT) {
      message.title = _genTitleByContent(message.content ?? '');
    }
    // if (banSpeakHas(message.content ?? '')) {
    //   throw Exception('消息包含敏感词汇');
    // }

    final isar = await DB.getIsar(userId);
    // 获取数据库的最后一条消息
    await isar.writeTxn(() async {
      final last = await MessageOperator.getLastMessage(isar, pairId);
      message.id = last?.id ?? 0;
      message.id++;
      message.sender = userId;
      message.taskStatus = TaskStatus.sending;
      message.msgId = message.id;
      message.createTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final channel = await _getChannel(pairId);
      // 设置消息的自毁时间
      int destroyDuration = 0;
      if (channel.messageDestroyDuration > 0) {
        destroyDuration = channel.messageDestroyDuration;
      }
      if (channel.otherChatDestroyDuration > 0 &&
          (destroyDuration == 0 ||
              channel.otherChatDestroyDuration < destroyDuration)) {
        destroyDuration = channel.otherChatDestroyDuration;
      }
      if (destroyDuration > 0) {
        message.messageDestroyTime = message.createTime + destroyDuration;
      }
      if (channel.messageDestroyDuration > 0) {
        message.messageDestroyTime =
            message.createTime + channel.messageDestroyDuration * 60 * 60 * 24;
      }
      _setLastMessage(channel, message);
      message.readed = true;
      channel.lastReadId = message.id;
      channel.unreadCount = 0;
      message.status = GMessageStatus.UNREAD;
      // 如果是发送通话消息
      if (message.type == GMessageType.AUDIO_CALL ||
          message.type == GMessageType.VIDEO_CALL) {
        message.callStatus = GCallStatus.WAIT;
        // 调用接口发送数据
        var api = MessageApi(apiClient());
        final params = V1MessageSendArgs(
          list: [message.toModel()],
        );
        final res = await api.messageSend(params);
        if (res?.success != null && res!.success.isNotEmpty) {
          message.taskStatus = TaskStatus.success;
          message.id = toInt(res.success[0].msgId);
          message.upId = toInt(res.success[0].msgId);
          message.messageDestroyTime = toInt(res.success[0].messageDestroyTime);
          await MessageOperator.save(isar, message);
          // 将数据插入页面
          ChannelPageNotifier.insertMessage(message);
          await ChannelOperator.save(isar, channel);
          await ChannelListNotifier().insert(channel);
        } else {
          throw Exception('send message fail for call');
        }
      } else {
        await MessageOperator.save(isar, message);
        // 将数据插入页面
        ChannelPageNotifier.insertMessage(message);
        // 将数据计入消息发送队列
        MessageTask().addMessage(message);
        await ChannelOperator.save(isar, channel);
        await ChannelListNotifier().insert(channel);
      }
    });
  }

  // 发送失败的消息重新发送
  static Future<void> resendMessage(int id) async {
    final isar = await DB.getIsar(userId);
    Message? newMessage;
    await isar.writeTxn(() async {
      final message = await MessageOperator.getById(isar, id);
      if (message == null) return;
      // 删除这个消息
      await MessageOperator.deleteByIds(isar, [id]);
      var random = Random();
      message.upId = random.nextInt(2 << 31);
      newMessage = message;
    });
    if (newMessage != null) {
      await send(newMessage!);
    }
  }

  // 设置消息已经被用户播放过了
  static Future<void> setPlayed(int id) async {
    final isar = await DB.getIsar(userId);
    final message = await MessageOperator.getById(isar, id);
    if (message == null) return;
    var api = MessageApi(apiClient());
    await api.messageSetListen(
      V1MessageIdArgs(id: '$id', pairId: message.pairId),
    );
  }

  // 编辑消息
  static Future<void> editMessage(int id, String content) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final message = await MessageOperator.getById(isar, id);
      assert(message != null, 'message is empty');
      assert(message?.type == GMessageType.TEXT, 'message type is not text');
      var api = MessageApi(apiClient());
      final params = V1MessageEditArgs(
        id: '$id',
        content: content,
        pairId: message!.pairId,
      );
      final res = await api.messageEdit(params);
      // 更新upid
      message.content = content;
      message.title = _genTitleByContent(content);
      message.upId = toInt(res?.upId);
      await MessageOperator.save(isar, message);
      // 更新状态管理
      MessageNotifier.update(message);
    });
  }

  // 单个消息设置置顶
  static Future<void> setMessageTop(int id, bool isTop) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final message = await MessageOperator.getById(isar, id);
      if (message == null) return;
      // 更新接口
      var api = MessageApi(apiClient());
      message.topTime =
          isTop ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;
      api.messageSetTopTime(V1MessageSetTopTimeArgs(
        id: id.toString(),
        pairId: message.pairId,
        topTime: message.topTime.toString(),
      ));
      await MessageOperator.save(isar, message);
    });
  }

  // 查询置顶的消息
  static Future<List<Message>> listTopMessages(String pairId) async {
    final isar = await DB.getIsar(userId);
    final messages = await MessageOperator.listTopMessages(isar, pairId);
    return messages;
  }

  // 删除channel
  static Future<void> deleteChannel(List<String> pairIds) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      if (pairIds.isEmpty) {
        pairIds = (await ChannelOperator.listAllPairIds(isar))
            .map((e) => e!)
            .toList();
      }
      // 删除channel
      await ChannelOperator.deleteByPairIds(isar, pairIds);
      // 删除message
      await MessageOperator.deleteByPairIds(isar, pairIds);
      // 更新接口
      var api = ChannelApi(apiClient());
      await api.channelDel(V1ChannelDelArgs(pairIds: pairIds));
      // 更新状态管理
      for (var pairId in pairIds) {
        ChannelListNotifier().remove(pairId);
      }
    });
  }

  // 清除消息
  static Future<void> clearMessage(
    String pairId,
    List<int> ids, {
    bool both = false, // 是否双向删除
  }) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      if (both) {
        await _revokeMessage(isar, pairId, ids);
      } else {
        await _deleteMessages(isar, pairId, ids);
      }
      await resetLastMessage(isar, pairId);
    });
  }

  // 清空channel中的消息
  static Future<void> clearChannelMessages(
    String pairId, {
    bool both = false, // 请求对方也删除消息
  }) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      // 删除message
      await MessageOperator.deleteByPairIds(isar, [pairId]);
      // 更新接口
      var api = MessageApi(apiClient());
      await api.messageClear(V1MessageClearArgs(
        pairId: pairId,
        clearRelate: both,
      ));
      // 更新状态管理
      ChannelPageNotifier.getByPairId(pairId)?.clearMessage();
      // 更新最后一条消息
      await resetLastMessage(isar, pairId);
    });
  }

  // 删除本地channel
  static Future<void> deleteLocalChannel(String pairId, {int? upId}) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await ChannelOperator.deleteByPairIds(isar, [pairId]);
      // 状态管理中删除
      ChannelListNotifier().remove(pairId);
      await MarkUpOperator.setChannelMaxUpId(isar, upId);
    });
  }

  // 删除本地数据库的消息
  static Future<void> deleteLocalMessageLessThanUpId(
    int upId,
    String pairId,
  ) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await MessageOperator.deleteByPairId(isar, pairId, upId);
      // 状态管理中删除
      ChannelPageNotifier.getByPairId(pairId)?.removeMessageLessThan(upId);
      await resetLastMessage(isar, pairId);
    });
  }

  // 删除本地数据库的消息
  static Future<void> deleteLocalMessageByIds(
    int upId,
    String pairId,
    List<int> ids,
  ) async {
    if (ids.isEmpty) return;
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      if (ids.isNotEmpty) {
        await MessageOperator.deleteByIds(isar, ids);
      }
      // 状态管理中删除
      for (var id in ids) {
        ChannelPageNotifier.removeMessage(id);
      }
      await resetLastMessage(isar, pairId);
    });
  }

  // 重置channel的最后一条消息
  static Future<Channel?> resetLastMessage(Isar isar, String pairId) async {
    final channel = await ChannelOperator.getByPairId(isar, pairId);
    if (channel == null) return null;
    // 查询最后一条消息
    final message = await MessageUtil.getLastMessage(isar, pairId);
    // 不去更新lastMessageId 让其排序不被改变
    if (message != null) {
      channel.lastMessage = MessageItem.fromMessage(message);
    } else {
      channel.lastMessage = null;
    }
    await ChannelOperator.save(isar, channel);
    ChannelListNotifier().insert(channel);
    return channel;
  }

  // 双向撤回消息
  static Future<void> _revokeMessage(
    Isar isar,
    String pairId,
    List<int> ids,
  ) async {
    final messages = await MessageOperator.listByIds(isar, pairId, ids);
    final params = V1MessageIdsArgs(pairId: pairId);
    params.ids = messages.map((e) => '${e.id}').toList();
    if (ids.isEmpty) return;
    var api = MessageApi(apiClient());
    // 调用接口删除
    await api.messageRevoke(params);
    await MessageOperator.deleteByIds(isar, ids);
    // 状态管理中删除
    for (var id in ids) {
      ChannelPageNotifier.removeMessage(id);
    }
  }

  // 删除自己（本地的）的消息
  static Future<void> _deleteMessages(
    Isar isar,
    String pairId,
    List<int> ids,
  ) async {
    final messages = await MessageOperator.listByIds(isar, pairId, ids);
    final params = V1MessageIdsArgs(pairId: pairId);
    params.ids = messages.map((e) => '${e.id}').toList();
    if (ids.isEmpty) return;
    var api = MessageApi(apiClient());
    // 调用接口删除
    await api.messageDel(params);
    await MessageOperator.deleteByIds(isar, ids);
    // 状态管理中删除
    for (var id in ids) {
      ChannelPageNotifier.removeMessage(id);
    }
  }

  // 更新消息
  static Future<void> update(Message message) async {
    assert(message.id > 0, 'message id must be not empty');
    assert((message.upId ?? 0) > 0, 'message upId must be not empty');
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await MessageOperator.save(isar, message);
      // 更新状态管理
      MessageNotifier.update(message);
    });
  }

  // 更新消息发送状态
  static Future<Message?> updateMessageTaskStatus(
    int messageId,
    TaskStatus status, {
    int? newMessageId,
    int? messageDestroyTime,
    String? reason,
  }) async {
    if (messageDestroyTime == null || messageDestroyTime <= 0) {
      messageDestroyTime = 0;
    }
    final isar = await DB.getIsar(userId);
    Message? msg;
    await isar.writeTxn(() async {
      switch (status) {
        case TaskStatus.success:
          assert(newMessageId != null);
          msg = await MessageOperator.updateSuccess(
            isar,
            messageId,
            newMessageId!,
            messageDestroyTime ?? 0,
          );
          break;
        case TaskStatus.fail:
          msg = await MessageOperator.updateFail(isar, messageId, reason ?? '');
          break;
        default:
          break;
      }
      if (msg != null) {
        // 更新状态管理中的状态
        MessageNotifier.replace(messageId, msg!);
      }
    });

    return msg;
  }

  // 查询出未发送成功的消息
  static Future<List<Message>> listUnSendMessages() async {
    final isar = await DB.getIsar(userId);
    final messages = await MessageOperator.listUnSendMessages(isar);
    return messages;
  }

  // 生成一个需要发送的消息
  static Message newMessage(String pairId, GMessageType type) {
    return Message.forSend(userId, pairId, type);
  }

  // 获取一个简短的标题
  static String _genTitleByContent(String content) {
    // 使用 Dart 正则表达式将多个空格和换行替换为一个空格
    var regex = RegExp(r'\s+');
    String title = content.replaceAll(regex, ' ');
    // 如果字符串长度超过200个字符，则截断
    if (title.runes.length > 200) {
      title = String.fromCharCodes(title.runes.take(200));
    }
    return title;
  }

  // 更群成员信息
  static Future _updateRoomMemberForMessage(
    Isar isar,
    String pairId,
    Message message,
  ) async {
    var senderUser = message.senderUser;
    if (senderUser == null) return;
    final ids = extractIntegersFromPairId(pairId);
    late int roomId;
    if (ids[0] == 0) {
      roomId = ids[1];
    } else if (ids[1] == 0) {
      roomId = ids[0];
    } else {
      return;
    }
    final uid = message.sender!;
    assert(roomId > 0);
    RoomMember? member = await isar.roomMembers
        .where()
        .pairIdUserIdEqualTo(pairId, uid)
        .findFirst();
    member ??= RoomMember();
    if (member.msgId > message.id) return;
    member.msgId = message.id;
    member.pairId = pairId;
    member.userId = uid;
    member.senderUser = senderUser;
    await isar.roomMembers.put(member);
  }

  // 查询Channel如果没有走网络同步
  static Future<Channel> _getChannel(String pairId) async {
    final isar = await DB.getIsar(userId);
    Channel? channel = await ChannelOperator.getByPairId(
      isar,
      pairId,
    );
    if (channel == null) {
      // from network
      var api = ChannelApi(apiClient());
      logger.d(pairId);
      final data = await api.channelDetail(GPairIdArgs(pairId: pairId));
      channel = Channel.fromModel(data!);
    }
    return channel;
  }

  // 设置channel最后一条消息
  static Future<void> _setLastMessage(
    Channel channel,
    Message message,
  ) async {
    channel.deleteTime = 0;
    if (message.id > channel.lastMessageId) {
      channel.lastMessageId = message.id;
      channel.lastMessage = MessageItem.fromMessage(message);
    }
    if (channel.topTime > 0) {
      channel.topTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
  }

  // 同步 channel 当消息发送完成状态发生变化的时候
  static Future<Channel> syncChannelForMessageTaskStatus(
    String pairId,
    Message message,
  ) async {
    final isar = await DB.getIsar(userId);
    Channel? channel;
    await isar.writeTxn(() async {
      // 查询本地数据库
      channel = await ChannelOperator.getByPairId(
        isar,
        pairId,
      );
      if (channel == null) {
        // from network
        var api = ChannelApi(apiClient());
        final data = await api.channelDetail(GPairIdArgs(pairId: pairId));
        channel = Channel.fromModel(data!);
      }
      if (channel!.lastMessageId <= message.id) {
        channel!.lastMessageId = message.id;
        channel!.lastMessage = MessageItem.fromMessage(message);
      }
      if (channel!.topTime > 0) {
        channel!.topTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      await ChannelOperator.save(isar, channel!);
    });
    // 更新状态管理
    ChannelListNotifier().insert(channel!);
    return channel!;
  }

  // 接收到需要同步的channel
  static Future<void> receiveChannel(
    GChannelModel m, {
    bool reconnect = false, // 是否是重新连接
  }) async {
    final pairId = m.pairId ?? '';
    if (pairId.isEmpty) return;
    if (m.userId == null) return;
    if (m.userId! != '$userId') return;
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      // 查询本地数据库
      Channel? channel = await ChannelOperator.getByPairId(
        isar,
        pairId,
      );
      channel ??= Channel();
      channel.load(m);
      if (reconnect) {
        channel = await _checkBreakpoint(isar, channel, toInt(m.lastMessageId));
      }
      // logger.d('$reconnect update channel: ${channel.breakpoints}');
      if (channel.applyCleanStatus == GApplyCleanStatus.APPLY) {
        // 通知清空消息
        // applyClearMessageController.add(pairId);
        ApiRequest.seeCleanTopic(pairId);
      }
      await ChannelOperator.save(isar, channel);
      await MarkUpOperator.setChannelMaxUpId(isar, channel.upId!);
      // 插入页面
      await ChannelListNotifier().insert(channel);
    });
    return;
  }

  // 更新断点区间
  static Future<void> updateBreakpoint(
    String pairId,
    int id,
  ) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, pairId);
      if (channel == null) return;
      if (id == 0) {
        channel.isLoadingHistory = false;
        channel.breakpoints = [];
      } else {
        channel.isLoadingHistory = false;
        List<List<int>> chunkedList = [];
        for (int i = 0; i < channel.breakpoints.length; i += 2) {
          List<int> chunk = channel.breakpoints.sublist(i, i + 2);
          chunkedList.add(chunk);
        }
        List<List<int>> newBreakpoints = [];
        for (var chunk in chunkedList.reversed) {
          final data = chunk.toList();
          if (id > data[1]) {
            newBreakpoints.add(data);
          } else if (id > data[0]) {
            data[1] = id;
            newBreakpoints.add(data);
          } else {
            continue;
          }
        }
        final breakpoints = newBreakpoints.reversed
            .expand(
              (element) => element,
            )
            .toList();
        channel.breakpoints = breakpoints;
      }
      await ChannelOperator.save(isar, channel);
    });
  }

  // 检查断点
  static Future<Channel> _checkBreakpoint(
    Isar isar,
    Channel channel,
    int lastMessageId,
  ) async {
    if (lastMessageId == 0) {
      return channel;
    }
    // 查询最后一条消息
    final message = await MessageUtil.getLastMessage(isar, channel.pairId!);
    final localMsgId = toInt(message?.id);
    if (localMsgId > lastMessageId) {
      channel.lastMessageId = localMsgId;
      channel.lastMessage = MessageItem.fromMessage(message!);
      return channel;
    } else if (localMsgId == lastMessageId) {
      return channel;
    }
    logger.d('_checkBreakpoint $localMsgId $lastMessageId');
    // 出现消息断层
    channel.isLoadingHistory = true;
    final breakpoints = channel.breakpoints.toList();
    breakpoints.addAll([localMsgId, lastMessageId]);
    breakpoints.sort();
    channel.breakpoints = breakpoints;
    return channel;
  }

  // 查询channel列表
  static Future<List<Channel>> listChannel(ChannelCondition condition) async {
    final isar = await DB.getIsar(userId);
    final channels = await ChannelOperator.search(
      isar,
      condition,
    );
    return channels;
  }

  static Future<List<Message>> searchChannelMessage(
    String pairId,
    String keywords, {
    GMessageType? type,
  }) async {
    final isar = await DB.getIsar(userId);
    return await MessageOperator.searchByPairId(isar, pairId, keywords, type);
  }

  // 根据关键词搜索
  static Future<List<SearchResultItem>> searchMessage(String keywords) async {
    final isar = await DB.getIsar(userId);
    final result = await MessageOperator.search(
      isar,
      keywords,
    );
    final channels =
        await ChannelOperator.listByPairIds(isar, result.keys.toList());
    final List<SearchResultItem> data = [];
    final tmp = <String>{};
    for (var channel in channels) {
      final pairId = channel.pairId ?? '';
      final messages = result[pairId] ?? [];
      data.add(SearchResultItem(pairId, channel, messages));
      tmp.add(channel.pairId!);
    }
    final cList = await ChannelOperator.search(
        isar, ChannelCondition(keywords: keywords));
    for (var channel in cList) {
      if (tmp.contains(channel.pairId)) continue;
      final pairId = channel.pairId ?? '';
      final messages = result[pairId] ?? [];
      data.add(SearchResultItem(pairId, channel, messages));
    }
    return data;
  }

  static Future<Message?> getLastMessage(Isar isar, String pairId) async {
    final isar = await DB.getIsar(userId);
    Message? message;
    message = await MessageOperator.getLastMessage(isar, pairId);
    return message;
  }

  // 获取最后一条消息id
  static Future<int> getLastMessageId(String pairId) async {
    final isar = await DB.getIsar(userId);
    final message = await MessageOperator.getLastMessage(isar, pairId);
    return message?.id ?? 0;
  }

  static Future<Channel?> getChannelByPairId(String pairId) async {
    final isar = await DB.getIsar(userId);
    final channel = await ChannelOperator.getByPairId(isar, pairId);
    return channel;
  }

  static Future<MaxUpId> getMaxUpId() async {
    final isar = await DB.getIsar(userId);
    final channlId = await MarkUpOperator.getChannelMaxUpId(isar);
    final msgId = await MarkUpOperator.getMessageMaxUpId(isar);
    final noteId = await MarkUpOperator.getNotesMaxUpId(isar);
    return MaxUpId(channlId, msgId, noteId);
  }

  static Future<List<Message>> listByPairId(
    String pairId, {
    int limit = 20,
    int id = 0,
    Directions directions = Directions.up,
  }) async {
    final isar = await DB.getIsar(userId);
    Channel? channel = await ChannelOperator.getByPairId(isar, pairId);
    if (channel == null) {
      // 从网络同步数据
      var api = ChannelApi(apiClient());
      final data = await api.channelDetail(GPairIdArgs(pairId: pairId));
      channel = Channel.fromModel(data!);
    }
    bool networkSync = false;
    if (directions == Directions.up) {
      List<List<int>> chunkedList = [];
      for (int i = 0; i < channel.breakpoints.length; i += 2) {
        List<int> chunk = channel.breakpoints.sublist(i, i + 2);
        chunkedList.add(chunk);
      }
      if (id > 0) {
        for (var chunk in chunkedList.reversed) {
          final data = chunk.toList();
          if (id >= data[0] && id <= data[1]) {
            networkSync = true;
            break;
          }
        }
      }
      // logger.d(
      //     '--------- ${channel.breakpoints} networkSync $networkSync ${channel.breakpoints} $id');
    }
    List<Message> list = [];
    if (!networkSync) {
      list = await MessageOperator.listByPairId(
        isar,
        pairId,
        id: id,
        limit: limit,
        directions: directions,
      );
    } else {
      // 网络查询数据
      final api = MessageApi(apiClient());
      final args = V1MessageListArgs();
      args.pairId = pairId;
      args.maxId = id.toString();
      args.pager = GPagination(limit: '$limit');
      final result = await api.messageList(args);
      if (userId != toInt(Global.user?.id)) [];
      final networkResult = result?.list ?? [];

      for (var i = networkResult.length - 1; i >= 0; i--) {
        final msg = networkResult[i];
        final message = await MessageUtil.receive(
          msg,
          checkDno: false,
          updateLatest: i == 0,
          insertToPage: false,
        );
        if (message != null) {
          list.add(message);
        }
      }
      if (list.isNotEmpty) {
        await updateBreakpoint(channel.pairId!, toInt(networkResult.last.id));
      } else {
        await updateBreakpoint(channel.pairId!, 0);
      }
    }
    if (list.isEmpty) return list;
    final uids = list.map((e) => e.sender).toSet().toList();
    // 如果是群聊
    if ((channel.relateRoomId ?? 0) > 0) {
      // logger.d('---------群聊');
      final members = await isar.roomMembers
          .where()
          .anyOf(uids, (q, element) => q.pairIdUserIdEqualTo(pairId, element))
          .findAll();
      final uidToMember = <int, RoomMember>{};
      for (var member in members) {
        uidToMember[member.userId!] = member;
      }
      for (var message in list) {
        final member = uidToMember[message.sender!];
        if (member != null) {
          message.senderUser = member.senderUser;
        }
      }
    }
    return list;
  }

  static Future editGroup(
    List<String> pairIds,
    String oldName,
    String newName,
  ) async {
    final api = ChannelApi(apiClient());
    final result = await api.channelEditGroup(
      V1ChannelEditGroupArgs(
        pairIds: pairIds,
        oldGroupName: oldName,
        newGroupName: newName,
      ),
    );
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final list = await ChannelOperator.listByPairIds(isar, pairIds);
      for (var channel in list) {
        if (oldName.isNotEmpty) {
          channel.groups = channel.groups?.toList()?..remove(oldName);
        }
        if (newName.isNotEmpty) {
          final v = channel.groups ?? [];
          channel.groups = v.toList()..add(newName);
        }
        await ChannelOperator.save(isar, channel);
      }
      await ChannelGroupOperator.save(isar, result?.names ?? []);
    });
  }

  // 重新同步服务端的分组信息
  static Future<void> syncGroup() async {
    final isar = await DB.getIsar(userId);
    await ChannelGroupOperator.get(isar);
    final api = ChannelApi(apiClient());
    isar.writeTxn(() async {
      final result = await api.channelGroupList({});
      await ChannelGroupOperator.save(isar, result?.names ?? []);
    });
  }

  static Future<void> setLocalGroup(List<String> groups) async {
    final isar = await DB.getIsar(userId);
    isar.writeTxn(() async {
      await ChannelGroupOperator.save(isar, groups);
    });
  }

  // 查询所有channel基础数据
  static Future<List<Channel>> listAllChannel() async {
    final isar = await DB.getIsar(userId);
    final channels = await ChannelOperator.listAll(isar);
    return channels;
  }

  // 更新channel基础数据
  static Future<void> updateChannel(GChannelModel data) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, data.pairId!);
      if (channel == null) return;
      channel.load(data);
      await ChannelOperator.save(isar, channel);
      // 更新状态管理
      ChannelListNotifier().insert(channel);
    });
  }

  // 更新channel的备注
  static Future<void> updateChannelInfo(
    String pairId, {
    String? mark,
    String? name,
    String? avatar,
  }) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, pairId);
      if (channel == null) return;
      if (name != null) {
        channel.name = name;
      }
      if (mark != null) {
        channel.mark = mark;
      }
      if (avatar != null) {
        channel.avatar = avatar;
      }
      await ChannelOperator.save(isar, channel);
      // 更新状态管理
      ChannelListNotifier().insert(channel);
    });
  }

  // 本地设置已读
  static Future<void> setLocalRead(V1ChannelRead params) async {
    final isar = await DB.getIsar(userId);
    final pairId = params.pairId ?? '';
    final uid = toInt(params.userId);
    final upId = toInt(params.upId);
    assert(pairId.isNotEmpty, 'pairId must be not empty');
    assert(uid > 0, 'userId must be not empty');
    assert(upId > 0, 'upId must be not empty');
    await isar.writeTxn(() async {
      final channel = await ChannelOperator.getByPairId(isar, pairId);
      if (channel == null) return;
      if (userId == uid) {
        channel.lastReadId =
            channel.lastReadId < upId ? upId : channel.lastReadId;
      } else {
        channel.otherReadId =
            (channel.otherReadId ?? 0) < upId ? upId : channel.otherReadId;
        await _setOtherReadStatus(isar, pairId, upId);
      }
      channel.upId = upId;
      await ChannelOperator.save(isar, channel);
      await MarkUpOperator.setChannelMaxUpId(isar, channel.upId!);
      // 更新状态管理
      ChannelListNotifier().insert(channel);
    });
    return;
  }

  static Future<void> editMessageContent(int id, String content) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final message = await MessageOperator.getById(isar, id);
      if (message == null) return;
      message.content = content;
      message.title = _genTitleByContent(content);
      await MessageOperator.save(isar, message);
      // 更新状态管理
      MessageNotifier.update(message);
    });
  }

  static Future<void> setMessageListened(int id) async {
    final isar = await DB.getIsar(userId);
    isar.writeTxn(() async {
      final message = await MessageOperator.getById(isar, id);
      if (message == null) return;
      message.isListened = true;
      await MessageOperator.save(isar, message);
      // 更新状态管理
      MessageNotifier.update(message);
    });
  }

  // 重置消息已读数量
  static Future<void> resetUnreadCount(List<String> pairIds) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final channels = await ChannelOperator.getByPairIds(isar, pairIds);
      for (var channel in channels) {
        channel.unreadCount = 0;
        channel.atMessageIds = [];
        await ChannelOperator.save(isar, channel);
        // 更新状态管理
        ChannelListNotifier().insert(channel);
      }
    });
    ChannelListNotifier().refreshUnreadCount();
  }

  // 修改对方已读状态
  static Future<void> _setOtherReadStatus(
    Isar isar,
    String pairId,
    int upId,
  ) async {
    final list = await MessageOperator.listUnReadMessages(isar, pairId, upId);
    for (var message in list) {
      message.status = GMessageStatus.READ;
      await MessageOperator.save(isar, message);
      // 更新状态管理
      MessageNotifier.update(message);
    }
  }

  // 查询消息未读数
  static Future<int> countUnread({String? groupname}) async {
    final isar = await DB.getIsar(userId);
    return await ChannelOperator.countUnread(
      isar,
      groupname: groupname,
    );
  }

  // 查询出需要同步的channel
  static Future<List<Channel>> listNeedSyncChannels() async {
    final isar = await DB.getIsar(userId);
    final channels = await ChannelOperator.listNeedSyncChannels(isar);
    return channels;
  }

  // 同步历史记录
  static Future syncHistory({Function? over}) async {
    final list = await MessageUtil.listNeedSyncChannels();
    final api = MessageApi(apiClient());
    final args = V1MessageAfterListArgs();
    final pairIdToChannel = <String, Channel>{};
    final List<String> pairIds = [];
    for (var element in list) {
      pairIdToChannel[element.pairId!] = element;
      pairIds.add(element.pairId!);
    }
    args.pairIds = pairIds;
    if (args.pairIds.isEmpty || userId != toInt(Global.user?.id)) {
      over?.call();
      return;
    }
    try {
      final result = await api.messageAfterList(args);
      if (userId != toInt(Global.user?.id)) {
        over?.call();
        return;
      }
      final pairIdToMessages = <String, List<GMessageModel>>{};
      final messageList = result?.list ?? [];
      for (var i = messageList.length - 1; i >= 0; i--) {
        final msg = messageList[i];
        pairIdToMessages[msg.pairId!] ??= [];
        pairIdToMessages[msg.pairId!]!.add(msg);
      }

      for (var pairId in pairIdToMessages.keys) {
        final channel = pairIdToChannel[pairId]!;
        final list = pairIdToMessages[pairId] ?? [];
        for (var i = 0; i < list.length; i++) {
          final msg = list[i];
          await MessageUtil.receive(
            msg,
            checkDno: false,
            updateLatest: i == list.length - 1,
          );
        }
        // 更新区间
        final min = messageList.isEmpty ? 0 : toInt(messageList.last.id);
        await MessageUtil.updateBreakpoint(channel.pairId!, min);
      }
      over?.call();
    } catch (e) {
      logger.e(e);
      // 三秒后重新同步
      Future.delayed(const Duration(seconds: 3), () {
        syncHistory(over: over);
      });
      rethrow;
    }
  }

  // 发送信令消息
  static Future<void> signaler(GNegotiation negotiation) async {
    final isar = await DB.getIsar(userId);
    final msgId = toInt(negotiation.sessionId);
    assert(msgId > 0, 'msgId must be not empty');
    final message = await MessageOperator.getById(isar, msgId);
    assert(message != null, 'message must be not empty $msgId');
    negotiation.pairId = message?.pairId;
    logger.d('send signaler $negotiation');
    final api = MessageApi(apiClient());
    await api.messageSignaler(negotiation);
    if (negotiation.type == GSignalertType.BYE) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (message!.callStatus == GCallStatus.ACCEPT) {
        message.callStatus = GCallStatus.HANG_UP;
        if ((message.callStartTime ?? 0) > 0) {
          message.duration = now - message.callStartTime!;
        }
      } else if (message.callStatus == GCallStatus.WAIT) {
        message.callStatus =
            message.sender == userId ? GCallStatus.CANCEL : GCallStatus.REJECT;
      }
    } else if (negotiation.type == GSignalertType.OFFER ||
        negotiation.type == GSignalertType.ANSWER) {
      // 同意通话
      message!.callStatus = GCallStatus.ACCEPT;
      message.callStartTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
    await isar.writeTxn(() async {
      await MessageOperator.save(isar, message!);
    });
    // 更新状态管理
    MessageNotifier.update(message!);
  }
}

class MaxUpId {
  final int channelUpId;
  final int messageUpId;
  final int noteMaxCreateTime;

  MaxUpId(this.channelUpId, this.messageUpId, this.noteMaxCreateTime);

  @override
  toString() =>
      'MaxUpId{channelUpId: $channelUpId, messageUpId: $messageUpId, noteMaxCreateTime: $noteMaxCreateTime}';
}
