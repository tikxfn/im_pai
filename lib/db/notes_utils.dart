import 'dart:async';
import 'dart:math';

import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/operator/mark_up_operator.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/db.dart';
import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/task/task.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';

class NotesUpdateArgs {
  final int id;
  final Notes notes;

  NotesUpdateArgs(this.id, this.notes);
}

class NotesUtils {
  static final StreamController<NotesUpdateArgs> updateBroadcast =
      StreamController<NotesUpdateArgs>.broadcast();

  static int get userId {
    final id = toInt(Global.user?.id);
    if (id == 0) {
      throw Exception('userId is empty');
    }
    return id;
  }

  // 添加修改笔记
  static Future<void> save(Notes note) async {
    note.taskStatus = TaskStatus.sending;
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      final latest = await isar.notes.where(sort: Sort.desc).findFirst();
      if (note.id == 0) {
        note.id = latest?.id ?? 0;
        note.id++;
        // 随机生成一个upid
        var random = Random();
        note.upId = random.nextInt(2 << 31);
      }
      if (note.createTime == 0) {
        note.createTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      note.updateTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      note.taskStatus = TaskStatus.sending;
      await isar.notes.put(note);
      NotesTask().addChannel(note);
    });
  }

  // 替换笔记
  static Future<void> replace(int oldId, Notes note) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await isar.notes.deleteAll([oldId]);
      await isar.notes.put(note);
    });
    updateBroadcast.add(NotesUpdateArgs(oldId, note));
  }

  static Future<void> localSave(Notes note) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await isar.notes.put(note);
    });
    updateBroadcast.add(NotesUpdateArgs(note.id, note));
  }

  // 查询所有标签
  static Future<List<String>> listTags() async {
    final isar = await DB.getIsar(userId);
    final tags = await isar.notes.where().tagsProperty().findAll();
    final Set<String> result = {};
    for (var element in tags) {
      result.addAll(element);
    }
    return result.toList();
  }

  // 查询笔记
  static Future<List<Notes>> listNotes(
    int limit, {
    int offset = 0,
    String? keywords,
    List<String>? tags,
    Function? syncCompleted,
  }) async {
    final isar = await DB.getIsar(userId);
    QueryBuilder dp = isar.notes
        .where(sort: Sort.desc)
        .idGreaterThan(0)
        .filter()
        .deleteTimeGreaterThan(-1);
    if (keywords != null && keywords.isNotEmpty) {
      dp = (dp as QueryBuilder<Notes, Notes, QFilterCondition>)
          .contentWordsContains(keywords);
    }
    if (tags != null && tags.isNotEmpty) {
      dp = (dp as QueryBuilder<Notes, Notes, QFilterCondition>)
          .anyOf(tags, (q, element) => q.tagsElementContains(element));
    }
    return await (dp as QueryBuilder<Notes, Notes, QSortBy>)
        .sortByTopTimeDesc()
        .thenByUpdateTimeDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  // 增量同步笔记
  static Future<int> syncNotes() async {
    final isar = await DB.getIsar(userId);
    int counter = 0;
    isar.writeTxn(() async {
      int upId = await MarkUpOperator.getNotesMaxUpId(isar);
      while (true) {
        final api = UserNotesApi(apiClient());
        final result = await api.userNotesAfterNotes(V1AfterNotesArgs(
          limit: '50',
          upId: '$upId',
        ));
        if (result?.list == null || result!.list.isEmpty) {
          break;
        }
        for (GNotesModel element in result.list) {
          counter++;
          final id = toInt(element.upId);
          upId = id > upId ? id : upId;
          final notes = Notes.fromModel(element);
          await MarkUpOperator.setNotesMaxUpId(isar, upId);
          if (toInt(element.deleteTime) > 0) {
            await isar.notes.deleteAll([notes.id]);
          } else {
            await isar.notes.put(notes);
            updateBroadcast.add(NotesUpdateArgs(notes.id, notes));
          }
        }
      }
    });
    return counter;
  }

  // 删除笔记
  static Future<void> delete(List<int> ids) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      // 删除网络
      final api = UserNotesApi(apiClient());
      await api.userNotesDelNotesMultiple(
        V1DelNotesMultipleArgs(ids: ids.map((e) => e.toString()).toList()),
      );
      await isar.notes.deleteAll(ids);
    });
  }

  static Future<void> localDelete(List<int> ids, {int? upId}) async {
    final isar = await DB.getIsar(userId);
    await isar.writeTxn(() async {
      await isar.notes.deleteAll(ids);
      if (upId != null && upId > 0) {
        await MarkUpOperator.setNotesMaxUpId(isar, upId);
      }
    });
  }

  // 查询出需要同步的笔记
  static Future<List<Notes>> listNeedSyncNotes() async {
    final isar = await DB.getIsar(userId);
    return await isar.notes
        .where()
        .taskStatusIntEqualTo(TaskStatus.sending.toInt())
        .findAll();
  }

  static Future<Notes?> getById(int id) async {
    final isar = await DB.getIsar(userId);
    return await isar.notes.get(id);
  }
}
