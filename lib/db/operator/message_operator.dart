import 'package:unionchat/db/enum.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';

class MessageOperator {
  static const List<GMessageType> silenceType = [
    GMessageType.ROOM_NOTICE_JOIN,
    GMessageType.ROOM_NOTICE_EXIT,
  ];

  MessageOperator._();

  // 保存消息
  static Future<void> save(Isar isar, Message message) async {
    await isar.messages.put(message);
  }

  static Future<void> deleteByPairId(Isar isar, String pairId, int upId) async {
    await isar.messages
        .where()
        .pairIdEqualToAnyMsgId(pairId)
        .filter()
        .idLessThan(upId)
        .deleteAll();
  }

  static Future<void> deleteByPairIds(Isar isar, List<String> pairIds) async {
    await isar.messages
        .where()
        .anyOf(pairIds, (q, element) => q.pairIdEqualToAnyMsgId(element))
        .deleteAll();
  }

  // 查询出未发送成功的消息
  static Future<List<Message>> listUnSendMessages(Isar isar) async {
    final messages = await isar.messages
        .where()
        .taskStatusIntEqualTo(TaskStatus.sending.toInt())
        .findAll();
    return messages;
  }

  // 查询出未读消息
  static Future<List<Message>> listUnReadMessages(
    Isar isar,
    String pairId,
    int upId,
  ) async {
    final messages = await isar.messages
        .where()
        .pairIdEqualToAnyMsgId(pairId)
        .filter()
        .statusIntEqualTo(
          GMessageStatus.values.indexOf(GMessageStatus.UNREAD),
        )
        .idLessThan(upId)
        .findAll();
    return messages;
  }

  // 更新消息状态到发送成功
  static Future<Message?> updateSuccess(
    Isar isar,
    int oldId,
    int newId,
    int messageDestroyTime,
  ) async {
    final message = await isar.messages.get(oldId);
    if (message == null) return message;
    message.taskStatus = TaskStatus.success;
    message.upId = newId;
    message.id = newId;
    message.msgId = newId;
    message.messageDestroyTime = messageDestroyTime;
    await isar.messages.put(message);
    await isar.messages.delete(oldId);
    return message;
  }

  static Future<Message?> updateFail(Isar isar, int id, String reason) async {
    final message = await isar.messages.get(id);
    if (message == null) return message;
    message.taskStatus = TaskStatus.fail;
    message.reason = reason;
    await isar.messages.put(message);
    return message;
  }

  // 根据pairId查询出最后一条消息
  static Future<Message?> getById(Isar isar, int id) async {
    final message = await isar.messages.get(id);
    return message;
  }

  // 根据pairId查询出最后一条消息
  static Future<List<Message>> listByIds(
      Isar isar, String pairId, List<int> ids) async {
    final messages = await isar.messages
        .where()
        .anyOf(ids, (q, element) => q.idEqualTo(element))
        .filter()
        .pairIdEqualTo(pairId)
        .findAll();
    return messages;
  }

  static Future<List<Message>> listTopMessages(Isar isar, String pairId) async {
    final messages = await isar.messages
        .where()
        .pairIdEqualToAnyMsgId(pairId)
        .filter()
        .topTimeGreaterThan(0)
        .not()
        .statusIntEqualTo(GMessageStatus.values.indexOf(GMessageStatus.REVOKE))
        .and()
        .messageDestroyTimeEqualTo(0)
        .or()
        .messageDestroyTimeGreaterThan(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
        )
        .sortByTopTime()
        .findAll();
    return messages;
  }

  static Future<void> deleteByIds(Isar isar, List<int> ids) async {
    await isar.messages
        .where()
        .anyOf(ids, (q, element) => q.idEqualTo(element))
        .deleteAll();
  }

  // 获取最后一条消息
  static Future<Message?> getLastMessage(Isar isar, String pairId) async {
    final List<int> types = [];
    for (var i = 0; i < GMessageType.values.length; i++) {
      if (silenceType.contains(GMessageType.values[i])) {
        continue;
      }
      types.add(i);
    }

    final message = isar.messages
        .where(sort: Sort.desc)
        .pairIdEqualToAnyMsgId(pairId)
        .filter()
        .allOf(
            silenceType
                .map(
                  (e) => GMessageType.values.indexOf(e),
                )
                .toList(),
            (q, v) => q.not().typeIntEqualTo(v))
        .not()
        .statusIntEqualTo(GMessageStatus.values.indexOf(GMessageStatus.REVOKE))
        .and()
        .messageDestroyTimeGreaterThan(
          DateTime.now().microsecondsSinceEpoch ~/ 1000000,
        )
        .or()
        .messageDestroyTimeEqualTo(0)
        .findFirst();
    return message;
  }

  // 搜索本地消息
  static Future<List<Message>> searchByPairId(
    Isar isar,
    String pairId,
    String keywords,
    GMessageType? type,
  ) async {
    QueryBuilder<Message, Message, QFilterCondition> qb =
        isar.messages.where().pairIdEqualToAnyMsgId(pairId).filter();
    if (type != null) {
      qb = qb.typeIntEqualTo(GMessageType.values.indexOf(type));
    }
    return await qb
        .contentWordsContains(keywords)
        .sortByMsgIdDesc()
        .limit(2000)
        .findAll();
  }

  // 搜索本地消息
  static Future<Map<String, List<Message>>> search(
    Isar isar,
    String keywords,
  ) async {
    final result = await isar.messages
        .filter()
        .contentWordsContains(keywords)
        .sortByMsgIdDesc()
        .limit(2000)
        .findAll();

    final data = <String, List<Message>>{};
    for (var message in result) {
      final key = message.pairId!;
      if (data.containsKey(key)) {
        data[key]!.add(message);
      } else {
        data[key] = [message];
      }
    }
    return data;
  }

  static Future<List<Message>> listByPairId(
    Isar isar,
    String pairId, {
    int limit = 20,
    int id = 0,
    Directions directions = Directions.up,
  }) async {
    final sort = directions == Directions.up ? Sort.desc : Sort.asc;
    QueryBuilder qb =
        isar.messages.where(sort: sort).pairIdEqualToAnyMsgId(pairId);
    qb = (qb as QueryBuilder<Message, Message, QAfterWhereClause>);
    if (id > 0) {
      if (directions == Directions.up) {
        qb = qb.filter().idLessThan(id);
      } else {
        qb = qb.filter().idGreaterThan(id);
      }
    } else {
      qb = qb.filter();
    }

    final list = await (qb as QueryBuilder<Message, Message, QFilterCondition>)
        .not()
        .statusIntEqualTo(GMessageStatus.values.indexOf(GMessageStatus.REVOKE))
        .and()
        .messageDestroyTimeEqualTo(0)
        .or()
        .messageDestroyTimeGreaterThan(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
        )
        // .sortByMsgIdDesc()
        .limit(limit)
        .findAll();

    return directions == Directions.up ? list.reversed.toList() : list;
  }
}

enum Directions {
  up,
  down,
}
