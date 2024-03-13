import 'package:flutter/cupertino.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/db/operator/message_operator.dart';
import 'package:unionchat/global.dart';

// channel 详情页面的消息
class ChannelPageNotifier with ChangeNotifier {
  // 更新页面中的消息
  List<MessageNotifier> get messages => _messages;
  // 跟踪数据是否请求中
  ValueNotifier<bool> get loading => _loading;
  // 是否还能向上请求数据
  ValueNotifier<bool> get upMore => _upMore;
  // 是否还能向下请求数据
  ValueNotifier<bool> get downMore => _downMore;
  static final Map<String, ChannelPageNotifier> _instances = {};
  static const int _pageSize = 20;

  bool _disposed = false;

  final String pairId;

  int _min = 0;
  int _max = 0;

  // 向上还有数据
  final ValueNotifier<bool> _upMore = ValueNotifier<bool>(true);
  // 下下还有数据
  final ValueNotifier<bool> _downMore = ValueNotifier<bool>(false);
  // 数据正在请求防止误点
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  // 数据
  List<MessageNotifier> _messages = [];

  ChannelPageNotifier._(this.pairId);

  factory ChannelPageNotifier.getInstance(String pairId) {
    if (!_instances.containsKey(pairId)) {
      final list = _instances.entries.map((e) => e.value).toList();
      for (var element in list) {
        element.dispose();
      }
      final n = ChannelPageNotifier._(pairId);
      _instances[pairId] = n;
    }
    return _instances[pairId]!;
  }

  static ChannelPageNotifier? getByPairId(String pairId) {
    return _instances[pairId];
  }

  static String getPairId() {
    var id = '';
    _instances.forEach((key, value) {
      if (id.isEmpty) id = key;
    });
    return id;
  }

  // 加入一个新消息到当前page的最后一个
  static bool insertMessage(Message message) {
    final page = _instances[message.pairId];
    // 不在此页面
    if (page == null) return false;
    final data = MessageNotifier.fromMessage(message);
    page._max = message.id;
    page._messages.add(data);
    page.notifyListeners();
    return true;
  }

  Future<void> initPage({int? id}) async {
    if (id == null) {
      await _queryLatest();
    } else {
      await _queryAround(id);
    }
  }

  Future<void> clearMessage() async {
    _clear();
    notifyListeners();
  }

  // 初始化页面数据（进入页面的时候调用）
  Future<void> _queryLatest() async {
    if (_loading.value) return;
    _loading.value = true;
    _clear();
    // logger.d('--------- pairId initPage -- $pairId -------${Global.user?.id} ');
    try {
      final messages = await MessageUtil.listByPairId(
        pairId,
        limit: _pageSize,
        directions: Directions.up,
      );
      if (messages.length < _pageSize) {
        // 向上没有数据了
        _upMore.value = false;
      }
      if (messages.isNotEmpty) {
        _min = messages.first.id;
        _max = messages.last.id;
      }
      _messages.addAll(MessageNotifier.fromMessages(messages));
    } finally {
      notifyListeners();
      _loading.value = false;
    }
  }

  // 查询指定消息周围的数据
  Future<void> _queryAround(int id) async {
    if (_loading.value) return;
    _loading.value = true;
    try {
      final upMessages = await MessageUtil.listByPairId(
        pairId,
        limit: _pageSize,
        id: id + 1,
        directions: Directions.up,
      );
      if (upMessages.length < _pageSize) {
        // 向上没有数据了
        _upMore.value = false;
      }

      final downMessages = await MessageUtil.listByPairId(
        pairId,
        limit: _pageSize,
        id: id,
        directions: Directions.down,
      );
      _downMore.value = downMessages.length >= _pageSize;
      if (_downMore.value) {
        // 获取最后一条
        final lastId = await MessageUtil.getLastMessageId(pairId);
        if (downMessages.last.id >= lastId) {
          _downMore.value = false;
        }
      }
      final idToMessages = <int, Message>{};
      for (final msg in upMessages) {
        idToMessages[msg.id] = msg;
      }
      for (final msg in downMessages) {
        idToMessages[msg.id] = msg;
      }
      final messages = idToMessages.values.toList();
      _min = messages.first.id;
      _max = messages.last.id;
      _messages = MessageNotifier.fromMessages(messages);
    } finally {
      logger.d('_queryAround   ${_messages.length}');
      notifyListeners();
      _loading.value = false;
    }
  }

  // 向上爬楼获取消息
  nextUp() async {
    if (_loading.value) return;
    _loading.value = true;
    try {
      final messages = await MessageUtil.listByPairId(
        pairId,
        limit: _pageSize,
        id: _min,
        directions: Directions.up,
      );
      if (messages.length < _pageSize) {
        // 向上没有数据了
        _upMore.value = false;
      }
      if (messages.isNotEmpty) {
        _min = messages.first.id;
      }
      final data = MessageNotifier.fromMessages(messages);
      _messages.insertAll(0, data);
    } finally {
      notifyListeners();
      _loading.value = false;
    }
  }

  // 向下查询数据(定位到某个消息的时候向下查询)
  nextDown() async {
    if (_loading.value) return;
    _loading.value = true;
    logger.d('--------- pairId nextDown -- $pairId -------${Global.user?.id} ');
    try {
      final messages = await MessageUtil.listByPairId(
        pairId,
        limit: _pageSize,
        id: _max,
        directions: Directions.down,
      );
      if (_messages.length < _pageSize) {
        // 向上没有数据了
        _downMore.value = false;
      }
      if (_downMore.value) {
        // 获取最后一条
        final lastId = await MessageUtil.getLastMessageId(pairId);
        if (messages.last.id >= lastId) {
          _downMore.value = false;
        }
      }
      if (messages.isNotEmpty) {
        _max = messages.last.id;
      }
      final data = MessageNotifier.fromMessages(messages);
      _messages.addAll(data);
    } finally {
      notifyListeners();
      _loading.value = false;
    }
  }

  // 丛页面中删除一个消息
  static void removeMessage(int id) {
    final msg = MessageNotifier.removeById(id);
    if (msg == null) return;
    final page = ChannelPageNotifier._instances[msg.message.pairId];
    if (page == null) return;
    page._messages.remove(msg);
    page.notifyListeners();
  }

  // 移除小于id的所有消息
  void removeMessageLessThan(int id) {
    bool notify = false;
    for (var i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg.message.id < id) {
        notify = true;
        messages.removeAt(i);
        i--;
      }
    }
    if (notify) notifyListeners();
  }

  @override
  dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
    _instances.remove(pairId);
    _clear();
  }

  _clear() {
    for (final msg in _messages) {
      msg.dispose();
    }
    _messages.clear();
    _min = 0;
    _max = 0;
    _upMore.value = true;
    _downMore.value = false;
  }
}
