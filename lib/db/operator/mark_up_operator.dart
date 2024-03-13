import 'package:unionchat/db/model/mark_up.dart';
import 'package:isar/isar.dart';

class MarkUpOperator {
  static const _meessageKey = 'message';
  static const _channelKey = 'channel';
  static const _notesKey = 'notes';

  // 更新消息的最大upid
  static Future<void> setMessageMaxUpId(Isar isar, int upId) async {
    MarkUp? v = await isar.markUps.getByKey(_meessageKey);
    if (v == null) {
      v = MarkUp();
      v.key = _meessageKey;
    }
    if (upId > (v.upId ?? 0)) {
      v.upId = upId;
      await isar.markUps.put(v);
    }
  }

  // 获取消息最大的upid
  static Future<int> getMessageMaxUpId(Isar isar) async {
    MarkUp? v = await isar.markUps.getByKey(_meessageKey);
    if (v == null) return 0;
    return v.upId ?? 0;
  }

  static Future<void> setChannelMaxUpId(Isar isar, int? upId) async {
    MarkUp? v = await isar.markUps.getByKey(_channelKey);
    if (v == null) {
      v = MarkUp();
      v.key = _channelKey;
    }
    if (upId != null && upId > (v.upId ?? 0)) {
      v.upId = upId;
      await isar.markUps.put(v);
    }
  }

  static Future<int> getChannelMaxUpId(Isar isar) async {
    MarkUp? v = await isar.markUps.getByKey(_channelKey);
    if (v == null) return 0;
    return v.upId ?? 0;
  }

  static Future<void> setNotesMaxUpId(Isar isar, int upId) async {
    MarkUp? v = await isar.markUps.getByKey(_notesKey);
    if (v == null) {
      v = MarkUp();
      v.key = _notesKey;
    }
    if (upId > (v.upId ?? 0)) {
      v.upId = upId;
      await isar.markUps.put(v);
    }
  }

  static Future<int> getNotesMaxUpId(Isar isar) async {
    MarkUp? v = await isar.markUps.getByKey(_notesKey);
    if (v == null) return 0;
    return v.upId ?? 0;
  }
}
