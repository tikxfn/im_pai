import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/db/model/message.dart';

// 消息的状态管理
class MessageNotifier with ChangeNotifier {
  static final Map<int, MessageNotifier> _instances = {};
  Message get message => _message;
  ValueNotifier<double?> get uploadProgress => _uploadProgress;
  bool _disposed = false;
  Message _message;

  final ValueNotifier<double?> _uploadProgress = ValueNotifier(null);
  // 正在播放
  final ValueNotifier<bool> playing = ValueNotifier(false);
  // 资源加载中
  final ValueNotifier<bool> loading = ValueNotifier(false);

  MessageNotifier(this._message);

  _update(Message message) {
    _message = message;
    notifyListeners();
  }

  // 更新数据
  static void update(Message message) {
    final mn = _instances[message.id];
    if (mn == null) return;
    mn._update(message);
  }

  // 当消息发送成功之后
  static void replace(int oldId, Message newMsg) {
    final old = _instances[oldId];
    if (old == null) return;
    _instances.remove(oldId);
    old._message = newMsg;
    _instances[newMsg.id] = old;
    old.notifyListeners();
  }

  // 更新上传进度
  static void progress(int id, double progress) {
    final mn = _instances[id];
    if (mn == null) return;
    mn._uploadProgress.value = progress;
  }

  // 播放此条消息
  static void playingForId(int id) {
    final message = _instances[id];
    if (message == null) return;
    assert(
      message.message.type == GMessageType.AUDIO ||
          message.message.type == GMessageType.VIDEO,
      'message type is not audio or video',
    );
    _instances.forEach((key, value) {
      if (key != id) {
        value.playing.value = false;
      }
    });
    message.playing.value = true;
  }

  static void stopForId(int id) {
    final message = _instances[id];
    if (message == null) return;
    message.playing.value = false;
  }

  // 停止所有播放
  static void stopAllPlaying() {
    _instances.forEach((key, value) {
      value.playing.value = false;
    });
  }

  static void setLoading(int id, bool v) {
    final message = _instances[id];
    if (message == null) return;
    message.loading.value = v;
  }

  static MessageNotifier fromMessage(Message msg) {
    if (!_instances.containsKey(msg.id)) {
      final mn = MessageNotifier(msg);
      _instances[msg.id] = mn;
    } else {
      _instances[msg.id]!._update(msg);
    }
    return _instances[msg.id]!;
  }

  static List<MessageNotifier> fromMessages(List<Message> messages) {
    final List<MessageNotifier> list = [];
    for (var msg in messages) {
      if (!_instances.containsKey(msg.id)) {
        final mn = MessageNotifier(msg);
        _instances[msg.id] = mn;
      } else {
        _instances[msg.id]!._update(msg);
      }
      list.add(_instances[msg.id]!);
    }
    return list;
  }

  // 移除instances中的数据
  static MessageNotifier? removeById(int id) {
    final v = _instances.remove(id);
    if (v == null) return null;
    return v;
  }

  static removeByIds(List<int> ids) {
    for (var id in ids) {
      _instances.remove(id);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    removeById(message.id);
    super.dispose();
  }
}
