part of 'task.dart';

class NotesTask extends Task {
  NotesTask._(int userId) : super._(userId);

  factory NotesTask() {
    final userId = toInt(Global.user?.id);
    return Task.getInstanse(userId, 'task', () => NotesTask._(userId));
  }

  ValueNotifier<bool> get syncing => _syncing;

  // 是否同步中
  final ValueNotifier<bool> _syncing = ValueNotifier(false);

  StreamController<Notes>? _noteQueue;
  StreamSubscription<Notes>? _noteQueueSubscription;

  List<Timer> _failTimers = [];

  @override
  Future<void> initialize() async {
    if (_noteQueue != null) {
      throw Exception('ChannelTask already initialized');
    }
    _noteQueue = StreamController<Notes>(
      onListen: _onStart,
      onCancel: _onCancel,
    );
    _noteQueueSubscription = _noteQueue!.stream.listen((note) async {
      await _networkSave(note);
    });
    syncNotes();
  }

  @override
  Future<void> dispose() async {
    _noteQueueSubscription?.cancel();
    _noteQueueSubscription = null;
    await _noteQueue?.close();
    _noteQueue = null;
    _syncing.dispose();
  }

  // 执行同步操作
  Future<void> syncNotes({Function(int)? over}) async {
    if (syncing.value) return;
    syncing.value = true;
    int counter = 0;
    try {
      counter = await NotesUtils.syncNotes();
    } finally {
      syncing.value = false;
      over?.call(counter);
    }
  }

  // 添加到同步队列
  void addChannel(Notes note) {
    if (_noteQueue == null) {
      throw Exception('ChannelTask not initialized');
    }
    _noteQueue?.add(note);
  }

  Future<void> _networkSave(Notes note) async {
    // 判断更新时间差异
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (now - note.updateTime > 300) {
      // 同步失败
      note.taskStatus = TaskStatus.fail;
      await NotesUtils.localSave(note);
      return;
    }
    // 有无文件上传
    bool uploadFailed = false;
    // 无法找到本地文件
    bool fileNotFound = false;
    for (var v in note.items) {
      var content = v.content ?? '';
      if ((v.type != GNoteType.VIDEO && v.type != GNoteType.IMAGE) ||
          content.isEmpty ||
          urlValid(content)) {
        continue;
      }
      List<String?> uploadResult = [];
      try {
        uploadResult = await UploadFile(
          providers: [
            FileProvider.fromFilepath(
              content,
              v.type == GNoteType.VIDEO
                  ? V1FileUploadType.NOTE_VIDEO
                  : V1FileUploadType.NOTE_IMAGE,
            ),
          ],
          load: false,
        ).aliOSSUpload(check: false);
      } catch (e) {
        logger.e(e);
        if (e.runtimeType == PathNotFoundException) {
          fileNotFound = true;
          continue;
        }
      }
      if (uploadResult.isEmpty || (uploadResult[0] ?? '').isEmpty) {
        uploadFailed = true;
        continue;
      }
      v.content = uploadResult[0];
    }
    // 有文件未找到
    if (fileNotFound) {
      note.taskStatus = TaskStatus.fail;
      return;
    }
    // 有文件上传失败
    if (uploadFailed) {
      note.taskStatus = TaskStatus.fail;
      await NotesUtils.save(note);
      return;
    }
    // 掉接口保存
    final api = UserNotesApi(apiClient());
    try {
      final result = await api.userNotesSaveNotes(note.toModel());
      final oldId = toInt(result?.oldId);
      final newId = toInt(result?.newId);
      note.upId = toInt(result?.upId);
      note.id = newId;
      note.taskStatus = TaskStatus.success;
      await NotesUtils.replace(oldId, note);
    } catch (e) {
      logger.e(e);
      // 等待重新同步
      // 重新添加到发送队列
      final t = Timer(const Duration(seconds: 10), () {
        _noteQueue?.add(note);
      });
      _failTimers.add(t);
      rethrow;
    }
  }

  // 查询出需要同步的队列
  Future<void> _scheduleProcessing() async {
    if (_noteQueue == null) {
      throw Exception('ChannelTask not initialized');
    }
    final list = await NotesUtils.listNeedSyncNotes();
    for (var channel in list) {
      _noteQueue?.add(channel);
    }
  }

  void _onStart() {
    _scheduleProcessing();
  }

  void _onCancel() {
    logger.d('ChannelTask canceled');
    for (var timer in _failTimers) {
      timer.cancel();
    }
    _failTimers = [];
  }
}
