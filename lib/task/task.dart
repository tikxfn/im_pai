import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/db/notifier/message_notifier.dart';
import 'package:unionchat/global.dart';
import 'package:openapi/api.dart';
part 'message_task.dart';
part 'notes_task.dart';

typedef Creator = Task Function();

abstract class Task {
  static final Map<String, Task> _store = {};

  final int userId;

  Task._(this.userId) {
    assert(userId != 0);
  }

  static getInstanse(int userId, String code, Creator creator) {
    final key = '${userId}_$code';
    if (!_store.containsKey(key)) {
      _store[key] = creator();
    }
    return _store[key]!;
  }

  Future<void> initialize();

  Future<void> dispose();

  static Future<void> close() async {
    for (var task in _store.values) {
      await task.dispose();
    }
    _store.clear();
  }

  static init() async {
    final userId = toInt(Global.user?.id);
    if (userId == 0) {
      throw Exception('userId is empty');
    }
    await MessageTask().initialize();
    await NotesTask().initialize();
  }
}
