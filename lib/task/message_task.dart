part of 'task.dart';

class MessageTask extends Task {
  MessageTask._(int userId) : super._(userId);

  factory MessageTask() {
    final userId = toInt(Global.user?.id);
    return Task.getInstanse(userId, 'message', () => MessageTask._(userId));
  }

  final List<Message> _messagesBuffer = [];
  StreamController<Message>? _messageQueue;
  StreamSubscription<Message>? _messageQueueSubscription;

  StreamController<Message>? _uploadQueue;
  StreamSubscription<Message>? _uploadSubscription;
  Timer? _timer;
  List<Timer> _failTimers = [];

  @override
  Future<void> initialize() async {
    if (_messageQueue != null) {
      throw Exception('MessageTask already initialized');
    }
    _messageQueue = StreamController<Message>(
      onListen: _onStart,
      onCancel: _onCancel,
    );
    _uploadQueue = StreamController<Message>();
    // 文件上传队列
    _uploadSubscription = _uploadQueue!.stream.listen((message) {
      _uploadMessageContent(message);
    });
    _messageQueueSubscription = _messageQueue!.stream.listen((message) {
      _messagesBuffer.add(message);
    });
    await _loadUnsentMessages();
  }

  @override
  Future<void> dispose() async {
    _messageQueueSubscription?.cancel();
    _messageQueueSubscription = null;
    _uploadSubscription?.cancel();
    _uploadSubscription = null;
    await _messageQueue?.close();
    _messageQueue = null;
    await _uploadQueue?.close();
    _uploadQueue = null;
  }

  void _onStart() {
    _scheduleProcessing();
  }

  Future<void> _loadUnsentMessages() async {
    final list = await MessageUtil.listUnSendMessages();
    for (var message in list) {
      _messageQueue?.add(message);
    }
  }

  void addMessage(Message message) {
    if (_messageQueue == null) {
      throw Exception('MessageTask not initialized');
    }
    _messageQueue?.add(message);
  }

  void _scheduleProcessing() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _processMessages();
    });
  }

  Future<void> _processMessages() async {
    if (_messagesBuffer.isEmpty) return;
    final messages = _messagesBuffer.toList();
    _messagesBuffer.clear();
    logger.d('MessageTask process ${messages.length} messages');
    try {
      await _sendMessage(messages);
    } on ApiException catch (e) {
      onError(
        e,
        handler: (data) async {
          for (var element in messages) {
            await MessageUtil.updateMessageTaskStatus(
              element.id,
              TaskStatus.fail,
              reason: data.message,
            );
            return;
          }
        },
      );
    } catch (e) {
      logger.e(e);
      // 重新添加到发送队列
      final t = Timer(const Duration(seconds: 5), () {
        for (var message in messages) {
          if (message.taskStatus == TaskStatus.sending) {
            _messageQueue?.add(message);
          }
        }
      });
      _failTimers.add(t);
    }
  }

  Future<void> _uploadMessageContent(Message message) async {
    // upload
    var url = await _messageUploadFile(message);
    if (url.isEmpty) {
      await MessageUtil.updateMessageTaskStatus(
        message.id,
        TaskStatus.fail,
        reason: '上传失败',
      );
      return;
    }
    await MessageUtil.update(message..content = url);
    // 上传完成修改数据库，重新加入发送消息队列
    _messageQueue?.add(message);
  }

  Future<void> _sendMessage(List<Message> messages) async {
    final api = MessageApi(apiClient(timeout: const Duration(seconds: 10)));
    final List<GMessageModel> list = [];
    final List<GMessageType> upTypes = [
      GMessageType.IMAGE,
      GMessageType.FILE,
      GMessageType.VIDEO,
      GMessageType.AUDIO,
    ];
    for (var element in messages) {
      // 判断发送是否超时
      // 判断更新时间差异
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (now - element.createTime > 180) {
        await MessageUtil.updateMessageTaskStatus(
          element.id,
          TaskStatus.fail,
          reason: '发送超时',
        );
        continue;
      }
      if (upTypes.contains(element.type) && !urlValid(element.content ?? '')) {
        _uploadQueue?.add(element);
        continue;
      }

      list.add(element.toModel());
    }
    final body = V1MessageSendArgs();
    body.list = list;
    logger.d('request list: ${list.length}');
    // logger.d(jsonEncode(list));
    final resp = await api.messageSend(body);
    try {
      final futures = <Future>[];
      for (V1MessageSendSuccess element in resp?.success ?? []) {
        // logger.d(element);
        futures.add((V1MessageSendSuccess element) async {
          final oldId = toInt(element.id);
          final newId = toInt(element.msgId);
          final messageDestroyTime = toInt(element.messageDestroyTime);
          if (oldId <= 0 || newId <= 0) {
            throw Exception('oldId or newId is empty');
          }
          final newMessage = await MessageUtil.updateMessageTaskStatus(
            oldId,
            TaskStatus.success,
            newMessageId: newId,
            messageDestroyTime: messageDestroyTime,
          );
          // 更新最后一条消息状态
          if (newMessage != null) {
            MessageUtil.syncChannelForMessageTaskStatus(
              newMessage.pairId!,
              newMessage,
            );
          }
        }(element));
      }
      for (V1MessageSendFail element in resp?.fail ?? []) {
        futures.add((V1MessageSendFail element) async {
          final oldId = toInt(element.id);
          final reason = element.errMsg ?? '';
          if (oldId <= 0) {
            throw Exception('oldId is empty');
          }
          final newMessage = await MessageUtil.updateMessageTaskStatus(
            oldId,
            TaskStatus.fail,
            reason: reason,
          );
          // 更新最后一条消息状态
          if (newMessage != null) {
            MessageUtil.syncChannelForMessageTaskStatus(
              newMessage.pairId!,
              newMessage,
            );
          }
        }(element));
      }
      await Future.wait(futures);
    } catch (e) {
      logger.e(e);
    }
  }

  // 上传文件
  Future<String> _messageUploadFile(Message message) async {
    var content = message.content ?? '';
    List<String> url = [];
    if (content.isEmpty) return '';
    List<String> path = [content];
    late V1FileUploadType type;
    if (message.type == GMessageType.VIDEO) {
      type = V1FileUploadType.CHAT_VIDEO;
    } else if (message.type == GMessageType.IMAGE) {
      path = content.split(',');
      type = V1FileUploadType.CHAT_IMAGE;
    } else if (message.type == GMessageType.AUDIO) {
      type = V1FileUploadType.CHAT_VOICE;
    } else if (message.type == GMessageType.FILE) {
      type = V1FileUploadType.CHAT_FILE;
    } else {
      return '';
    }
    if (path.isEmpty) return '';
    double progress = 0;
    var autoProgress = 70;
    Timer? timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (progress > autoProgress) {
        timer.cancel();
        return;
      }
      MessageNotifier.progress(message.id, progress);
      progress += 1;
    });
    List<FileProvider> providers = [];
    for (var v in path) {
      if (urlValid(v)) {
        url.add(v);
        continue;
      }
      providers.add(FileProvider.fromFilepath(v, type));
    }
    final urls = await UploadFile(
      providers: providers,
      load: false,
    ).aliOSSUpload(onProgress: (upProgress) {
      if (upProgress > autoProgress) {
        timer?.cancel();
        timer = null;
        MessageNotifier.progress(message.id, upProgress);
      }
    });
    timer?.cancel();
    for (var v in urls) {
      if (v != null) url.add(v);
    }
    return url.join(',');
  }

  void _onCancel() {
    logger.d('MessageTask canceled');
    _messagesBuffer.clear();
    _timer?.cancel();
    _timer = null;
    for (var timer in _failTimers) {
      timer.cancel();
    }
    _failTimers = [];
  }
}
