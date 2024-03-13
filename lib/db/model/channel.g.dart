// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChannelCollection on Isar {
  IsarCollection<Channel> get channels => this.collection();
}

const ChannelSchema = CollectionSchema(
  name: r'Channel',
  id: 3096422491918372507,
  properties: {
    r'applyCleanStatusInt': PropertySchema(
      id: 0,
      name: r'applyCleanStatusInt',
      type: IsarType.long,
    ),
    r'atMessageIds': PropertySchema(
      id: 1,
      name: r'atMessageIds',
      type: IsarType.longList,
    ),
    r'avatar': PropertySchema(
      id: 2,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'breakpoints': PropertySchema(
      id: 3,
      name: r'breakpoints',
      type: IsarType.longList,
    ),
    r'cleanMessageId': PropertySchema(
      id: 4,
      name: r'cleanMessageId',
      type: IsarType.long,
    ),
    r'deleteTime': PropertySchema(
      id: 5,
      name: r'deleteTime',
      type: IsarType.long,
    ),
    r'doNotDisturb': PropertySchema(
      id: 6,
      name: r'doNotDisturb',
      type: IsarType.bool,
    ),
    r'firstMessageId': PropertySchema(
      id: 7,
      name: r'firstMessageId',
      type: IsarType.long,
    ),
    r'groups': PropertySchema(
      id: 8,
      name: r'groups',
      type: IsarType.stringList,
    ),
    r'isLoadingHistory': PropertySchema(
      id: 9,
      name: r'isLoadingHistory',
      type: IsarType.bool,
    ),
    r'lastMessage': PropertySchema(
      id: 10,
      name: r'lastMessage',
      type: IsarType.object,
      target: r'MessageItem',
    ),
    r'lastMessageId': PropertySchema(
      id: 11,
      name: r'lastMessageId',
      type: IsarType.long,
    ),
    r'lastReadId': PropertySchema(
      id: 12,
      name: r'lastReadId',
      type: IsarType.long,
    ),
    r'mark': PropertySchema(
      id: 13,
      name: r'mark',
      type: IsarType.string,
    ),
    r'messageDestroyDuration': PropertySchema(
      id: 14,
      name: r'messageDestroyDuration',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 15,
      name: r'name',
      type: IsarType.string,
    ),
    r'otherChatDestroyDuration': PropertySchema(
      id: 16,
      name: r'otherChatDestroyDuration',
      type: IsarType.long,
    ),
    r'otherReadId': PropertySchema(
      id: 17,
      name: r'otherReadId',
      type: IsarType.long,
    ),
    r'pairId': PropertySchema(
      id: 18,
      name: r'pairId',
      type: IsarType.string,
    ),
    r'relateRoomId': PropertySchema(
      id: 19,
      name: r'relateRoomId',
      type: IsarType.long,
    ),
    r'relateUserId': PropertySchema(
      id: 20,
      name: r'relateUserId',
      type: IsarType.long,
    ),
    r'senderUser': PropertySchema(
      id: 21,
      name: r'senderUser',
      type: IsarType.object,
      target: r'ShowUser',
    ),
    r'topTime': PropertySchema(
      id: 22,
      name: r'topTime',
      type: IsarType.long,
    ),
    r'unreadCount': PropertySchema(
      id: 23,
      name: r'unreadCount',
      type: IsarType.long,
    ),
    r'upId': PropertySchema(
      id: 24,
      name: r'upId',
      type: IsarType.long,
    )
  },
  estimateSize: _channelEstimateSize,
  serialize: _channelSerialize,
  deserialize: _channelDeserialize,
  deserializeProp: _channelDeserializeProp,
  idName: r'id',
  indexes: {
    r'upId': IndexSchema(
      id: -1252797001115891002,
      name: r'upId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'upId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'pairId': IndexSchema(
      id: 2719656591867140602,
      name: r'pairId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'pairId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'lastMessageId': IndexSchema(
      id: -7112213784156232521,
      name: r'lastMessageId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastMessageId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'doNotDisturb': IndexSchema(
      id: 6304931483360546475,
      name: r'doNotDisturb',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'doNotDisturb',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'topTime_lastMessageId': IndexSchema(
      id: 3675805479985898540,
      name: r'topTime_lastMessageId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topTime',
          type: IndexType.value,
          caseSensitive: false,
        ),
        IndexPropertySchema(
          name: r'lastMessageId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'deleteTime': IndexSchema(
      id: -7922939068555230889,
      name: r'deleteTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'deleteTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastReadId': IndexSchema(
      id: 3495805184752081521,
      name: r'lastReadId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastReadId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'groups': IndexSchema(
      id: 5028272511492937153,
      name: r'groups',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'groups',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'unreadCount': IndexSchema(
      id: 1929747360533418796,
      name: r'unreadCount',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'unreadCount',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isLoadingHistory': IndexSchema(
      id: -7795832384142922580,
      name: r'isLoadingHistory',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isLoadingHistory',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {
    r'MessageItem': MessageItemSchema,
    r'MessageHistory': MessageHistorySchema,
    r'ShowUser': ShowUserSchema
  },
  getId: _channelGetId,
  getLinks: _channelGetLinks,
  attach: _channelAttach,
  version: '3.1.0+1',
);

int _channelEstimateSize(
  Channel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.atMessageIds.length * 8;
  {
    final value = object.avatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.breakpoints.length * 8;
  {
    final list = object.groups;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.lastMessage;
    if (value != null) {
      bytesCount += 3 +
          MessageItemSchema.estimateSize(
              value, allOffsets[MessageItem]!, allOffsets);
    }
  }
  {
    final value = object.mark;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.pairId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.senderUser;
    if (value != null) {
      bytesCount += 3 +
          ShowUserSchema.estimateSize(value, allOffsets[ShowUser]!, allOffsets);
    }
  }
  return bytesCount;
}

void _channelSerialize(
  Channel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.applyCleanStatusInt);
  writer.writeLongList(offsets[1], object.atMessageIds);
  writer.writeString(offsets[2], object.avatar);
  writer.writeLongList(offsets[3], object.breakpoints);
  writer.writeLong(offsets[4], object.cleanMessageId);
  writer.writeLong(offsets[5], object.deleteTime);
  writer.writeBool(offsets[6], object.doNotDisturb);
  writer.writeLong(offsets[7], object.firstMessageId);
  writer.writeStringList(offsets[8], object.groups);
  writer.writeBool(offsets[9], object.isLoadingHistory);
  writer.writeObject<MessageItem>(
    offsets[10],
    allOffsets,
    MessageItemSchema.serialize,
    object.lastMessage,
  );
  writer.writeLong(offsets[11], object.lastMessageId);
  writer.writeLong(offsets[12], object.lastReadId);
  writer.writeString(offsets[13], object.mark);
  writer.writeLong(offsets[14], object.messageDestroyDuration);
  writer.writeString(offsets[15], object.name);
  writer.writeLong(offsets[16], object.otherChatDestroyDuration);
  writer.writeLong(offsets[17], object.otherReadId);
  writer.writeString(offsets[18], object.pairId);
  writer.writeLong(offsets[19], object.relateRoomId);
  writer.writeLong(offsets[20], object.relateUserId);
  writer.writeObject<ShowUser>(
    offsets[21],
    allOffsets,
    ShowUserSchema.serialize,
    object.senderUser,
  );
  writer.writeLong(offsets[22], object.topTime);
  writer.writeLong(offsets[23], object.unreadCount);
  writer.writeLong(offsets[24], object.upId);
}

Channel _channelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Channel();
  object.applyCleanStatusInt = reader.readLong(offsets[0]);
  object.atMessageIds = reader.readLongList(offsets[1]) ?? [];
  object.avatar = reader.readStringOrNull(offsets[2]);
  object.breakpoints = reader.readLongList(offsets[3]) ?? [];
  object.cleanMessageId = reader.readLongOrNull(offsets[4]);
  object.deleteTime = reader.readLongOrNull(offsets[5]);
  object.doNotDisturb = reader.readBool(offsets[6]);
  object.firstMessageId = reader.readLong(offsets[7]);
  object.groups = reader.readStringList(offsets[8]);
  object.id = id;
  object.isLoadingHistory = reader.readBool(offsets[9]);
  object.lastMessage = reader.readObjectOrNull<MessageItem>(
    offsets[10],
    MessageItemSchema.deserialize,
    allOffsets,
  );
  object.lastMessageId = reader.readLong(offsets[11]);
  object.lastReadId = reader.readLong(offsets[12]);
  object.mark = reader.readStringOrNull(offsets[13]);
  object.messageDestroyDuration = reader.readLong(offsets[14]);
  object.name = reader.readStringOrNull(offsets[15]);
  object.otherChatDestroyDuration = reader.readLong(offsets[16]);
  object.otherReadId = reader.readLongOrNull(offsets[17]);
  object.pairId = reader.readStringOrNull(offsets[18]);
  object.relateRoomId = reader.readLongOrNull(offsets[19]);
  object.relateUserId = reader.readLongOrNull(offsets[20]);
  object.senderUser = reader.readObjectOrNull<ShowUser>(
    offsets[21],
    ShowUserSchema.deserialize,
    allOffsets,
  );
  object.topTime = reader.readLong(offsets[22]);
  object.unreadCount = reader.readLong(offsets[23]);
  object.upId = reader.readLongOrNull(offsets[24]);
  return object;
}

P _channelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongList(offset) ?? []) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongList(offset) ?? []) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringList(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readObjectOrNull<MessageItem>(
        offset,
        MessageItemSchema.deserialize,
        allOffsets,
      )) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readLongOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readLongOrNull(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readObjectOrNull<ShowUser>(
        offset,
        ShowUserSchema.deserialize,
        allOffsets,
      )) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readLong(offset)) as P;
    case 24:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _channelGetId(Channel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _channelGetLinks(Channel object) {
  return [];
}

void _channelAttach(IsarCollection<dynamic> col, Id id, Channel object) {
  object.id = id;
}

extension ChannelByIndex on IsarCollection<Channel> {
  Future<Channel?> getByUpId(int? upId) {
    return getByIndex(r'upId', [upId]);
  }

  Channel? getByUpIdSync(int? upId) {
    return getByIndexSync(r'upId', [upId]);
  }

  Future<bool> deleteByUpId(int? upId) {
    return deleteByIndex(r'upId', [upId]);
  }

  bool deleteByUpIdSync(int? upId) {
    return deleteByIndexSync(r'upId', [upId]);
  }

  Future<List<Channel?>> getAllByUpId(List<int?> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'upId', values);
  }

  List<Channel?> getAllByUpIdSync(List<int?> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'upId', values);
  }

  Future<int> deleteAllByUpId(List<int?> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'upId', values);
  }

  int deleteAllByUpIdSync(List<int?> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'upId', values);
  }

  Future<Id> putByUpId(Channel object) {
    return putByIndex(r'upId', object);
  }

  Id putByUpIdSync(Channel object, {bool saveLinks = true}) {
    return putByIndexSync(r'upId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUpId(List<Channel> objects) {
    return putAllByIndex(r'upId', objects);
  }

  List<Id> putAllByUpIdSync(List<Channel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'upId', objects, saveLinks: saveLinks);
  }

  Future<Channel?> getByPairId(String? pairId) {
    return getByIndex(r'pairId', [pairId]);
  }

  Channel? getByPairIdSync(String? pairId) {
    return getByIndexSync(r'pairId', [pairId]);
  }

  Future<bool> deleteByPairId(String? pairId) {
    return deleteByIndex(r'pairId', [pairId]);
  }

  bool deleteByPairIdSync(String? pairId) {
    return deleteByIndexSync(r'pairId', [pairId]);
  }

  Future<List<Channel?>> getAllByPairId(List<String?> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'pairId', values);
  }

  List<Channel?> getAllByPairIdSync(List<String?> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'pairId', values);
  }

  Future<int> deleteAllByPairId(List<String?> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'pairId', values);
  }

  int deleteAllByPairIdSync(List<String?> pairIdValues) {
    final values = pairIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'pairId', values);
  }

  Future<Id> putByPairId(Channel object) {
    return putByIndex(r'pairId', object);
  }

  Id putByPairIdSync(Channel object, {bool saveLinks = true}) {
    return putByIndexSync(r'pairId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPairId(List<Channel> objects) {
    return putAllByIndex(r'pairId', objects);
  }

  List<Id> putAllByPairIdSync(List<Channel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'pairId', objects, saveLinks: saveLinks);
  }
}

extension ChannelQueryWhereSort on QueryBuilder<Channel, Channel, QWhere> {
  QueryBuilder<Channel, Channel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'upId'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastMessageId'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyDoNotDisturb() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'doNotDisturb'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyTopTimeLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'topTime_lastMessageId'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'deleteTime'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyLastReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastReadId'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'unreadCount'),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhere> anyIsLoadingHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isLoadingHistory'),
      );
    });
  }
}

extension ChannelQueryWhere on QueryBuilder<Channel, Channel, QWhereClause> {
  QueryBuilder<Channel, Channel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'upId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'upId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdEqualTo(int? upId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'upId',
        value: [upId],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdNotEqualTo(int? upId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upId',
              lower: [],
              upper: [upId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upId',
              lower: [upId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upId',
              lower: [upId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'upId',
              lower: [],
              upper: [upId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdGreaterThan(
    int? upId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'upId',
        lower: [upId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdLessThan(
    int? upId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'upId',
        lower: [],
        upper: [upId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> upIdBetween(
    int? lowerUpId,
    int? upperUpId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'upId',
        lower: [lowerUpId],
        includeLower: includeLower,
        upper: [upperUpId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> pairIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> pairIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> pairIdEqualTo(
      String? pairId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId',
        value: [pairId],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> pairIdNotEqualTo(
      String? pairId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastMessageIdEqualTo(
      int lastMessageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastMessageId',
        value: [lastMessageId],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastMessageIdNotEqualTo(
      int lastMessageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageId',
              lower: [],
              upper: [lastMessageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageId',
              lower: [lastMessageId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageId',
              lower: [lastMessageId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastMessageId',
              lower: [],
              upper: [lastMessageId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastMessageIdGreaterThan(
    int lastMessageId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageId',
        lower: [lastMessageId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastMessageIdLessThan(
    int lastMessageId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageId',
        lower: [],
        upper: [lastMessageId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastMessageIdBetween(
    int lowerLastMessageId,
    int upperLastMessageId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastMessageId',
        lower: [lowerLastMessageId],
        includeLower: includeLower,
        upper: [upperLastMessageId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> doNotDisturbEqualTo(
      bool doNotDisturb) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'doNotDisturb',
        value: [doNotDisturb],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> doNotDisturbNotEqualTo(
      bool doNotDisturb) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'doNotDisturb',
              lower: [],
              upper: [doNotDisturb],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'doNotDisturb',
              lower: [doNotDisturb],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'doNotDisturb',
              lower: [doNotDisturb],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'doNotDisturb',
              lower: [],
              upper: [doNotDisturb],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeEqualToAnyLastMessageId(int topTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topTime_lastMessageId',
        value: [topTime],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeNotEqualToAnyLastMessageId(int topTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [],
              upper: [topTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [],
              upper: [topTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeGreaterThanAnyLastMessageId(
    int topTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [topTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeLessThanAnyLastMessageId(
    int topTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [],
        upper: [topTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeBetweenAnyLastMessageId(
    int lowerTopTime,
    int upperTopTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [lowerTopTime],
        includeLower: includeLower,
        upper: [upperTopTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> topTimeLastMessageIdEqualTo(
      int topTime, int lastMessageId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topTime_lastMessageId',
        value: [topTime, lastMessageId],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeEqualToLastMessageIdNotEqualTo(int topTime, int lastMessageId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime],
              upper: [topTime, lastMessageId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime, lastMessageId],
              includeLower: false,
              upper: [topTime],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime, lastMessageId],
              includeLower: false,
              upper: [topTime],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime_lastMessageId',
              lower: [topTime],
              upper: [topTime, lastMessageId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeEqualToLastMessageIdGreaterThan(
    int topTime,
    int lastMessageId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [topTime, lastMessageId],
        includeLower: include,
        upper: [topTime],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeEqualToLastMessageIdLessThan(
    int topTime,
    int lastMessageId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [topTime],
        upper: [topTime, lastMessageId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause>
      topTimeEqualToLastMessageIdBetween(
    int topTime,
    int lowerLastMessageId,
    int upperLastMessageId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime_lastMessageId',
        lower: [topTime, lowerLastMessageId],
        includeLower: includeLower,
        upper: [topTime, upperLastMessageId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deleteTime',
        value: [null],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deleteTime',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeEqualTo(
      int? deleteTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deleteTime',
        value: [deleteTime],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeNotEqualTo(
      int? deleteTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deleteTime',
              lower: [],
              upper: [deleteTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deleteTime',
              lower: [deleteTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deleteTime',
              lower: [deleteTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'deleteTime',
              lower: [],
              upper: [deleteTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeGreaterThan(
    int? deleteTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deleteTime',
        lower: [deleteTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeLessThan(
    int? deleteTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deleteTime',
        lower: [],
        upper: [deleteTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> deleteTimeBetween(
    int? lowerDeleteTime,
    int? upperDeleteTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'deleteTime',
        lower: [lowerDeleteTime],
        includeLower: includeLower,
        upper: [upperDeleteTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastReadIdEqualTo(
      int lastReadId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastReadId',
        value: [lastReadId],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastReadIdNotEqualTo(
      int lastReadId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadId',
              lower: [],
              upper: [lastReadId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadId',
              lower: [lastReadId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadId',
              lower: [lastReadId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastReadId',
              lower: [],
              upper: [lastReadId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastReadIdGreaterThan(
    int lastReadId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadId',
        lower: [lastReadId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastReadIdLessThan(
    int lastReadId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadId',
        lower: [],
        upper: [lastReadId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> lastReadIdBetween(
    int lowerLastReadId,
    int upperLastReadId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastReadId',
        lower: [lowerLastReadId],
        includeLower: includeLower,
        upper: [upperLastReadId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> groupsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groups',
        value: [null],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> groupsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'groups',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> groupsEqualTo(
      List<String>? groups) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'groups',
        value: [groups],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> groupsNotEqualTo(
      List<String>? groups) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groups',
              lower: [],
              upper: [groups],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groups',
              lower: [groups],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groups',
              lower: [groups],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'groups',
              lower: [],
              upper: [groups],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> unreadCountEqualTo(
      int unreadCount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'unreadCount',
        value: [unreadCount],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> unreadCountNotEqualTo(
      int unreadCount) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'unreadCount',
              lower: [],
              upper: [unreadCount],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'unreadCount',
              lower: [unreadCount],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'unreadCount',
              lower: [unreadCount],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'unreadCount',
              lower: [],
              upper: [unreadCount],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> unreadCountGreaterThan(
    int unreadCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'unreadCount',
        lower: [unreadCount],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> unreadCountLessThan(
    int unreadCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'unreadCount',
        lower: [],
        upper: [unreadCount],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> unreadCountBetween(
    int lowerUnreadCount,
    int upperUnreadCount, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'unreadCount',
        lower: [lowerUnreadCount],
        includeLower: includeLower,
        upper: [upperUnreadCount],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> isLoadingHistoryEqualTo(
      bool isLoadingHistory) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isLoadingHistory',
        value: [isLoadingHistory],
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterWhereClause> isLoadingHistoryNotEqualTo(
      bool isLoadingHistory) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLoadingHistory',
              lower: [],
              upper: [isLoadingHistory],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLoadingHistory',
              lower: [isLoadingHistory],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLoadingHistory',
              lower: [isLoadingHistory],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isLoadingHistory',
              lower: [],
              upper: [isLoadingHistory],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ChannelQueryFilter
    on QueryBuilder<Channel, Channel, QFilterCondition> {
  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      applyCleanStatusIntEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'applyCleanStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      applyCleanStatusIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'applyCleanStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      applyCleanStatusIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'applyCleanStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      applyCleanStatusIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'applyCleanStatusInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'atMessageIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'atMessageIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'atMessageIds',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'atMessageIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> atMessageIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      atMessageIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'atMessageIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avatar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'avatar',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'avatar',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakpoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakpoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakpoints',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakpoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> breakpointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      breakpointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'breakpoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> cleanMessageIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cleanMessageId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      cleanMessageIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cleanMessageId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> cleanMessageIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      cleanMessageIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cleanMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> cleanMessageIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cleanMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> cleanMessageIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cleanMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deleteTime',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deleteTime',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleteTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deleteTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deleteTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> deleteTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deleteTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> doNotDisturbEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'doNotDisturb',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> firstMessageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      firstMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> firstMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> firstMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groups',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groups',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      groupsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groups',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groups',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groups',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groups',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      groupsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groups',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> groupsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'groups',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> isLoadingHistoryEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isLoadingHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastMessage',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessageIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      lastMessageIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessageIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastMessageId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessageIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastMessageId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastReadIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastReadIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastReadIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastReadIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastReadId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mark',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mark',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> markIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      messageDestroyDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'messageDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      messageDestroyDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'messageDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      messageDestroyDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'messageDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      messageDestroyDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'messageDestroyDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      otherChatDestroyDurationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'otherChatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      otherChatDestroyDurationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'otherChatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      otherChatDestroyDurationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'otherChatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      otherChatDestroyDurationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'otherChatDestroyDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'otherReadId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'otherReadId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'otherReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'otherReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'otherReadId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> otherReadIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'otherReadId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pairId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pairId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pairId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pairId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pairId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> pairIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateRoomIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relateRoomId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      relateRoomIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relateRoomId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateRoomIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relateRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateRoomIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relateRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateRoomIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relateRoomId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateRoomIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relateRoomId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'relateUserId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition>
      relateUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'relateUserId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateUserIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relateUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateUserIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relateUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateUserIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relateUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> relateUserIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relateUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> senderUserIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderUser',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> senderUserIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderUser',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> topTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> topTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> topTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> topTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> unreadCountEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> unreadCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> unreadCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unreadCount',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> unreadCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unreadCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'upId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'upId',
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'upId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'upId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'upId',
        value: value,
      ));
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> upIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'upId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChannelQueryObject
    on QueryBuilder<Channel, Channel, QFilterCondition> {
  QueryBuilder<Channel, Channel, QAfterFilterCondition> lastMessage(
      FilterQuery<MessageItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'lastMessage');
    });
  }

  QueryBuilder<Channel, Channel, QAfterFilterCondition> senderUser(
      FilterQuery<ShowUser> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'senderUser');
    });
  }
}

extension ChannelQueryLinks
    on QueryBuilder<Channel, Channel, QFilterCondition> {}

extension ChannelQuerySortBy on QueryBuilder<Channel, Channel, QSortBy> {
  QueryBuilder<Channel, Channel, QAfterSortBy> sortByApplyCleanStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyCleanStatusInt', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByApplyCleanStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyCleanStatusInt', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByCleanMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByCleanMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByDeleteTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByDoNotDisturb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doNotDisturb', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByDoNotDisturbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doNotDisturb', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByFirstMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByIsLoadingHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoadingHistory', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByIsLoadingHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoadingHistory', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByLastReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByLastReadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByMessageDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      sortByMessageDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      sortByOtherChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChatDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      sortByOtherChatDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChatDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByOtherReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherReadId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByOtherReadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherReadId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByRelateRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateRoomId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByRelateRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateRoomId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByRelateUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateUserId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByRelateUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateUserId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByTopTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> sortByUpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.desc);
    });
  }
}

extension ChannelQuerySortThenBy
    on QueryBuilder<Channel, Channel, QSortThenBy> {
  QueryBuilder<Channel, Channel, QAfterSortBy> thenByApplyCleanStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyCleanStatusInt', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByApplyCleanStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applyCleanStatusInt', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByCleanMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByCleanMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByDeleteTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByDoNotDisturb() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doNotDisturb', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByDoNotDisturbDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'doNotDisturb', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByFirstMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByIsLoadingHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoadingHistory', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByIsLoadingHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLoadingHistory', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByLastMessageIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastMessageId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByLastReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByLastReadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastReadId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByMessageDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      thenByMessageDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'messageDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      thenByOtherChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChatDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy>
      thenByOtherChatDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherChatDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByOtherReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherReadId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByOtherReadIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'otherReadId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByRelateRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateRoomId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByRelateRoomIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateRoomId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByRelateUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateUserId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByRelateUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relateUserId', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByTopTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByUnreadCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unreadCount', Sort.desc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.asc);
    });
  }

  QueryBuilder<Channel, Channel, QAfterSortBy> thenByUpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.desc);
    });
  }
}

extension ChannelQueryWhereDistinct
    on QueryBuilder<Channel, Channel, QDistinct> {
  QueryBuilder<Channel, Channel, QDistinct> distinctByApplyCleanStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'applyCleanStatusInt');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByAtMessageIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'atMessageIds');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByBreakpoints() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakpoints');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByCleanMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cleanMessageId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleteTime');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByDoNotDisturb() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'doNotDisturb');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByFirstMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstMessageId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByGroups() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groups');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByIsLoadingHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLoadingHistory');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByLastMessageId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastMessageId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByLastReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastReadId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByMark(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByMessageDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'messageDestroyDuration');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Channel, Channel, QDistinct>
      distinctByOtherChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'otherChatDestroyDuration');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByOtherReadId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'otherReadId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByPairId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByRelateRoomId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relateRoomId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByRelateUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relateUserId');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topTime');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByUnreadCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unreadCount');
    });
  }

  QueryBuilder<Channel, Channel, QDistinct> distinctByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'upId');
    });
  }
}

extension ChannelQueryProperty
    on QueryBuilder<Channel, Channel, QQueryProperty> {
  QueryBuilder<Channel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> applyCleanStatusIntProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applyCleanStatusInt');
    });
  }

  QueryBuilder<Channel, List<int>, QQueryOperations> atMessageIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'atMessageIds');
    });
  }

  QueryBuilder<Channel, String?, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<Channel, List<int>, QQueryOperations> breakpointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakpoints');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> cleanMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cleanMessageId');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> deleteTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleteTime');
    });
  }

  QueryBuilder<Channel, bool, QQueryOperations> doNotDisturbProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'doNotDisturb');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> firstMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstMessageId');
    });
  }

  QueryBuilder<Channel, List<String>?, QQueryOperations> groupsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groups');
    });
  }

  QueryBuilder<Channel, bool, QQueryOperations> isLoadingHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLoadingHistory');
    });
  }

  QueryBuilder<Channel, MessageItem?, QQueryOperations> lastMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessage');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> lastMessageIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastMessageId');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> lastReadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastReadId');
    });
  }

  QueryBuilder<Channel, String?, QQueryOperations> markProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mark');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations>
      messageDestroyDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'messageDestroyDuration');
    });
  }

  QueryBuilder<Channel, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations>
      otherChatDestroyDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'otherChatDestroyDuration');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> otherReadIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'otherReadId');
    });
  }

  QueryBuilder<Channel, String?, QQueryOperations> pairIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairId');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> relateRoomIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relateRoomId');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> relateUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relateUserId');
    });
  }

  QueryBuilder<Channel, ShowUser?, QQueryOperations> senderUserProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderUser');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> topTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topTime');
    });
  }

  QueryBuilder<Channel, int, QQueryOperations> unreadCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unreadCount');
    });
  }

  QueryBuilder<Channel, int?, QQueryOperations> upIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'upId');
    });
  }
}
