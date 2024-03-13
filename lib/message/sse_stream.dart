import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/message/unread_handler.dart';

class SSEStream {
  static ValueNotifier<bool> get syncing => _syncing;
  static final ValueNotifier<bool> _syncing = ValueNotifier(true);
  static final SSEStream _sseStream = SSEStream._internal();
  // 信令相关
  static final StreamController<GNegotiation> signalerController =
      StreamController<GNegotiation>.broadcast();

  SSEStream._internal();

  bool _isListening = false;
  bool _shouldReconnect = false;

  StreamSubscription<String>? _sseSubscription;

  factory SSEStream() => _sseStream;

  listen() {
    assert(!_isListening, 'SSEStream is listening');
    _isListening = true;
    _shouldReconnect = true;
    _listen();
  }

  close() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _isListening = false;
  }

  _listen() async {
    for (;;) {
      // logger.d('-----');
      try {
        await _listenToSSE();
        break;
      } catch (e) {
        logger.e(e);
        await Future.delayed(const Duration(seconds: 5));
        logger.d('delayed _listen');
      }
    }
  }

  Future<void> _listenToSSE() async {
    _syncing.value = true;
    final url = apiUrl();
    var client = HttpClient();
    final id = await MessageUtil.getMaxUpId();
    // logger.d('max_id: $id');
    final args = V1StreamArgs(
      nonce: randomString(),
      maxChannelUpId: id.channelUpId.toString(),
      maxMessageUpId: id.messageUpId.toString(),
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
    // logger.d('request---------: $body');
    var response = await request.close();
    _sseSubscription?.cancel();
    _sseSubscription =
        response.transform(utf8.decoder).transform(const LineSplitter()).listen(
      (line) {
        logger.d('Received sse message: $line');
        final value = jsonDecode(line);
        final resp = V1StreamResp.fromJson(value['result']);
        if (resp == null) return;
        _processData(resp);
      },
      onError: (error) {
        _syncing.value = true;
        logger.e('Error occurred: $error');
        _reconnect();
      },
      onDone: () {
        _syncing.value = true;
        // 流完成了
        logger.i('Stream closed');
        // 如果需要，可以在这里尝试重新连接
        _reconnect();
      },
      cancelOnError: false,
    );
  }

  void _reconnect() {
    if (_shouldReconnect) {
      logger.d('Reconnecting in 3 seconds...');
      Future.delayed(const Duration(seconds: 3), () {
        _listenToSSE(); // 重连
      });
    }
  }

  _processData(V1StreamResp data) {
    switch (data.type) {
      case V1StreamType.PING:
        break;
      case V1StreamType.AFTER_CHANNEL: // 首次连接同步channel 或者 channel发生变化的时候同步
        // 同步topic
        assert(data.channel != null);
        _afterChannel(data.channel!);
        break;
      case V1StreamType.CHANNEL: // 首次连接同步channel 或者 channel发生变化的时候同步
        // 同步topic
        assert(data.channel != null);
        _realtimeChannel(data.channel!);
        break;
      case V1StreamType.MESSAGE: // 收到信息消息
        // 收到消息
        assert(data.message != null);
        MessageUtil.receive(data.message!);
        break;
      case V1StreamType.CLEAR_MESSAGE:
        // 收到消息
        assert(data.clearMessage != null);
        _clearMessage(data.clearMessage!);
        break;
      case V1StreamType.CHANNEL_GROUPS:
        // 分组被更改
        MessageUtil.setLocalGroup(data.channelGroups?.names ?? []);
        break;
      case V1StreamType.CHANNEL_READ:
        // 收到消息
        assert(data.channelRead != null);
        MessageUtil.setLocalRead(data.channelRead!);
        break;
      case V1StreamType.UNREAD_NUMBER:
        // 收到消息
        // assert(data.unreadNumber != null);
        unreadHandler(data.unreadNumber!);
        break;
      case V1StreamType.ADMIN_CIRCLE_APPLY_UNREAD:
        // 当我为圈子管理员时收别人待入圈审核消息
        assert(data.adminCircleApplyUnread != null);
        circleUnreadHandler(data.adminCircleApplyUnread!);
        break;
      case V1StreamType.ADMIN_ROOM_APPLY_UNREAD:
        //  当我为群管理员时收别人待入圈审核消息
        assert(data.adminRoomApplyUnread != null);
        groupUnreadHandler(data.adminRoomApplyUnread!);
        break;
      case V1StreamType.LISTEN_MESSAGE:
        // 语音消息被收听
        MessageUtil.setMessageListened(toInt(data.listenMessageId));
        break;
      case V1StreamType.NIL:
        break;
      case V1StreamType.NEGOTIATION:
        // 接收信息令消息
        assert(data.negotiation != null);
        signalerController.add(data.negotiation!);
        break;
      case V1StreamType.INIT_END:
        // 同步历史记录
        _syncHistory();
        break;
    }
  }

  _syncHistory() async {
    // 等待channel同步完成
    await Future.delayed(const Duration(seconds: 3));
    MessageUtil.syncHistory(over: () => _syncing.value = false);
  }

  // 断线重连channel
  _afterChannel(GChannelModel channel) {
    final deleteTime = toInt(channel.deleteTime);
    if (deleteTime > 0) {
      MessageUtil.deleteLocalChannel(
        channel.pairId!,
        upId: toInt(channel.upId),
      );
      return;
    }
    MessageUtil.receiveChannel(channel, reconnect: true);
  }

  // 实时channel数据
  _realtimeChannel(GChannelModel channel) {
    final deleteTime = toInt(channel.deleteTime);
    if (deleteTime > 0) {
      MessageUtil.deleteLocalChannel(
        channel.pairId!,
        upId: toInt(channel.upId),
      );
      return;
    }
    MessageUtil.receiveChannel(channel);
  }

  // 消息被删除或者撤回
  _clearMessage(GClearMessageModel data) {
    final upId = toInt(data.upId);
    final pairId = data.pairId ?? '';
    assert(upId > 0);
    assert(pairId.isNotEmpty);
    logger.d(data);
    if ((data.delChannel ?? false)) {
      logger.d(0);
      MessageUtil.deleteLocalChannel(pairId, upId: upId);
    } else if (data.ids.isEmpty) {
      logger.d(1);
      MessageUtil.deleteLocalMessageLessThanUpId(upId, pairId);
    } else {
      // logger.d(2);
      MessageUtil.deleteLocalMessageByIds(
        upId,
        pairId,
        data.ids.map((e) => toInt(e)).toList(),
      );
    }
  }
}
