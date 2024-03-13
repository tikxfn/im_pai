import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:unionchat/db/operator/channel_operator.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/channel.dart';

class ChannelListNotifier with ChangeNotifier {
  static ChannelListNotifier? _instance;

  ChannelCondition condition = ChannelCondition();

  List<ValueNotifier<Channel>> get channels => _channels;
  ValueNotifier<int> get unreadCount => _unreadCount;

  // 数据正在请求防止误点
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  bool _disposed = false;

  ChannelListNotifier._();

  factory ChannelListNotifier() {
    return _instance ??= ChannelListNotifier._();
  }

  // 数据
  final List<ValueNotifier<Channel>> _channels = [];
  final Map<String, ValueNotifier<Channel>> _store = {};
  final ValueNotifier<int> _unreadCount = ValueNotifier<int>(0);
  Timer? _debounceTimer;

  // 搜索
  searchByCondition(ChannelCondition condition) {
    this.condition = condition;
    refreshUnreadCount();
    _search(cover: true);
  }

  sort() {
    _channels.sort((a, b) {
      final aTopTime = a.value.topTime;
      final bTopTime = b.value.topTime;
      if (aTopTime > bTopTime) return -1;
      if (aTopTime < bTopTime) return 1;
      final aLastChatId = a.value.lastMessageId;
      final bLastChatId = b.value.lastMessageId;
      if (aLastChatId > bLastChatId) return -1;
      if (aLastChatId < bLastChatId) return 1;
      return 0;
    });
    notifyListeners();
  }

  // 移除一个channel
  remove(String pairId) {
    _store.remove(pairId);
    _channels.removeWhere((element) => element.value.pairId == pairId);
    notifyListeners();
  }

  // 向页面插入一个channel
  Future<void> insert(Channel channel) async {
    // 判断是否已经在页面上
    assert(channel.pairId != null, 'pairId must be not null');
    final v = _store[channel.pairId!];
    if (v != null) {
      // 如果已经在页面
      v.value = channel;
    } else {
      _channels.add(ValueNotifier(channel));
      _store[channel.pairId!] = _channels.last;
    }
    // 重新排序
    sort();
  }

  // 刷新未读数量
  Future<void> refreshUnreadCount() async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      _unreadCount.value = await MessageUtil.countUnread(
        groupname: condition.group,
      );
    });
  }

  Future<void> _search({bool cover = false}) async {
    if (_loading.value) return;
    try {
      final result = await MessageUtil.listChannel(
        condition,
      );
      _store.clear();
      _channels.clear();
      for (var item in result) {
        assert(item.pairId != null, 'pairId must be not null');
        final v = ValueNotifier(item);
        _channels.add(v);
        _store[v.value.pairId!] = v;
      }
    } finally {
      notifyListeners();
      _loading.value = false;
    }
  }

  clear() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _unreadCount.value = 0;
    _store.clear();
    _channels.clear();
    notifyListeners();
  }

  @override
  dispose() {
    _disposed = true;
    if (_disposed) return;
    super.dispose();
    _store.clear();
    _channels.clear();
    _instance = null;
  }
}
