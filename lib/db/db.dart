import 'dart:async';
import 'dart:io';

import 'package:unionchat/db/model/channel.dart';
import 'package:unionchat/db/model/channel_group.dart';
import 'package:unionchat/db/model/mark_up.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/model/room_member.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DB {
  static final Map<int, Completer<Isar>?> _completer = {};

  static Future<Isar> getIsar(int userId) async {
    if (_completer[userId] != null) {
      return _completer[userId]!.future;
    }
    final c = Completer<Isar>();
    _completer[userId] = c;
    final path = await _getDatabaseDir(userId);
    final isar = Isar.openSync(
      [
        ChannelSchema,
        MessageSchema,
        RoomMemberSchema,
        MarkUpSchema,
        ChannelGroupSchema,
        UserInfoSchema,
        NotesSchema,
      ],
      directory: path,
    );
    c.complete(isar);
    return c.future;
  }

  static Future<String> _getDatabaseDir(int userId) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/data/$userId';
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return path;
  }

  static Future<void> close() async {
    for (final c in _completer.values) {
      final isar = await c?.future;
      await isar?.close();
    }
    _completer.clear();
  }

  // 关闭所有数据库并删除文件
  static Future<void> clearDatabase() async {
    await close();
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/data/';
    final directory = Directory(path);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}
