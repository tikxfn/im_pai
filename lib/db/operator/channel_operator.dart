import 'package:unionchat/db/model/channel.dart';
import 'package:isar/isar.dart';

enum ChannelPageStatus {
  all,
  unread,
}

// 消息聊天页面的查询条件
class ChannelCondition {
  // 聊天分组
  final String? group;
  // 关键词
  final String? keywords;
  // 查询状态
  final ChannelPageStatus status;
  // 是否是群聊 null: 全部; true: 群聊; false：单聊
  bool? isRoom;

  ChannelCondition({
    this.group,
    this.status = ChannelPageStatus.all,
    this.keywords,
    this.isRoom,
  });
}

class ChannelOperator {
  ChannelOperator._();

  static Future<Channel?> getByPairId(Isar isar, String pairId) async {
    return await isar.channels.getByPairId(pairId);
  }

  static Future<List<Channel>> getByPairIds(
    Isar isar,
    List<String> pairIds,
  ) async {
    return await isar.channels
        .where()
        .anyOf(pairIds, (q, element) => q.pairIdEqualTo(element))
        .findAll();
  }

  static Future<List<Channel>> listByPairIds(
      Isar isar, List<String> pairIds) async {
    if (pairIds.isEmpty) {
      return [];
    }
    return await isar.channels
        .where()
        .anyOf(pairIds, (q, element) => q.pairIdEqualTo(element))
        .findAll();
  }

  static Future<void> save(Isar isar, Channel data) async {
    await isar.channels.putByPairId(data);
  }

  static Future<void> deleteByPairIds(Isar isar, List<String> pairIds) async {
    await isar.channels
        .where()
        .anyOf(pairIds, (q, element) => q.pairIdEqualTo(element))
        .deleteAll();
  }

  static Future<List<Channel>> listAll(Isar isar) async {
    return await isar.channels
        .where(sort: Sort.desc)
        .sortByTopTimeDesc()
        .thenByLastMessageIdDesc()
        .findAll();
  }

  static Future<List<String?>> listAllPairIds(Isar isar) async {
    return await isar.channels.where().pairIdProperty().findAll();
  }

  static Future updateMark(Isar isar, String pairId, String mark) async {
    final channel = await getByPairId(isar, pairId);
    if (channel != null) {
      channel.mark = mark;
      await save(isar, channel);
    }
  }

  // 查询channel列表
  static Future<List<Channel>> search(
    Isar isar,
    ChannelCondition condition,
  ) async {
    QueryBuilder dp =
        isar.channels.where(sort: Sort.desc).topTimeGreaterThanAnyLastMessageId(
              -1,
            );

    if (condition.group != null) {
      dp = (dp as QueryBuilder<Channel, Channel, QAfterWhereClause>)
          .filter()
          .groupsElementContains(condition.group!);
    }
    if (condition.status == ChannelPageStatus.unread) {
      if (dp is QueryBuilder<Channel, Channel, QAfterWhereClause>) {
        dp = dp.filter();
      }
      dp = (dp as QueryBuilder<Channel, Channel, QFilterCondition>)
          .unreadCountGreaterThan(0);
    }
    if (condition.isRoom != null) {
      if (dp is QueryBuilder<Channel, Channel, QAfterWhereClause>) {
        dp = dp.filter();
      }
      if (condition.isRoom!) {
        dp = (dp as QueryBuilder<Channel, Channel, QFilterCondition>)
            .relateRoomIdGreaterThan(0);
      } else {
        dp = (dp as QueryBuilder<Channel, Channel, QFilterCondition>)
            .relateUserIdGreaterThan(0);
      }
    }
    if (condition.keywords != null) {
      if (dp is QueryBuilder<Channel, Channel, QAfterWhereClause>) {
        dp = dp.filter();
      }
      dp = (dp as QueryBuilder<Channel, Channel, QFilterCondition>)
          .nameContains(condition.keywords!)
          .or()
          .markContains(condition.keywords!);
    }
    final result =
        await (dp as QueryBuilder<Channel, Channel, QQueryOperations>)
            .findAll();
    return result;
  }

  // 查询未读消息数量
  static Future<int> countUnread(Isar isar, {String? groupname}) async {
    QueryBuilder qb = isar.channels.where().doNotDisturbEqualTo(false);
    if (groupname != null) {
      qb = (qb as QueryBuilder<Channel, Channel, QAfterWhereClause>)
          .filter()
          .groupsElementContains(groupname);
    }

    return await (qb as QueryBuilder<Channel, Channel, QQueryProperty>)
        .unreadCountProperty()
        .sum();
  }

  static Future<List<Channel>> listNeedSyncChannels(Isar isar) async {
    return await isar.channels
        .where()
        .isLoadingHistoryEqualTo(true)
        .sortByTopTimeDesc()
        .thenByLastMessageIdDesc()
        .findAll();
  }
}
