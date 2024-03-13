// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_member.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoomMemberCollection on Isar {
  IsarCollection<RoomMember> get roomMembers => this.collection();
}

const RoomMemberSchema = CollectionSchema(
  name: r'RoomMember',
  id: 8378385004166137828,
  properties: {
    r'msgId': PropertySchema(
      id: 0,
      name: r'msgId',
      type: IsarType.long,
    ),
    r'pairId': PropertySchema(
      id: 1,
      name: r'pairId',
      type: IsarType.string,
    ),
    r'senderUser': PropertySchema(
      id: 2,
      name: r'senderUser',
      type: IsarType.object,
      target: r'ShowUser',
    ),
    r'userId': PropertySchema(
      id: 3,
      name: r'userId',
      type: IsarType.long,
    )
  },
  estimateSize: _roomMemberEstimateSize,
  serialize: _roomMemberSerialize,
  deserialize: _roomMemberDeserialize,
  deserializeProp: _roomMemberDeserializeProp,
  idName: r'id',
  indexes: {
    r'pairId_userId': IndexSchema(
      id: -1567829756842754035,
      name: r'pairId_userId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'pairId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'userId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'msgId': IndexSchema(
      id: 8574845111581175867,
      name: r'msgId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'msgId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'ShowUser': ShowUserSchema},
  getId: _roomMemberGetId,
  getLinks: _roomMemberGetLinks,
  attach: _roomMemberAttach,
  version: '3.1.0+1',
);

int _roomMemberEstimateSize(
  RoomMember object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
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

void _roomMemberSerialize(
  RoomMember object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.msgId);
  writer.writeString(offsets[1], object.pairId);
  writer.writeObject<ShowUser>(
    offsets[2],
    allOffsets,
    ShowUserSchema.serialize,
    object.senderUser,
  );
  writer.writeLong(offsets[3], object.userId);
}

RoomMember _roomMemberDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = RoomMember();
  object.id = id;
  object.msgId = reader.readLong(offsets[0]);
  object.pairId = reader.readStringOrNull(offsets[1]);
  object.senderUser = reader.readObjectOrNull<ShowUser>(
    offsets[2],
    ShowUserSchema.deserialize,
    allOffsets,
  );
  object.userId = reader.readLongOrNull(offsets[3]);
  return object;
}

P _roomMemberDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<ShowUser>(
        offset,
        ShowUserSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _roomMemberGetId(RoomMember object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _roomMemberGetLinks(RoomMember object) {
  return [];
}

void _roomMemberAttach(IsarCollection<dynamic> col, Id id, RoomMember object) {
  object.id = id;
}

extension RoomMemberByIndex on IsarCollection<RoomMember> {
  Future<RoomMember?> getByPairIdUserId(String? pairId, int? userId) {
    return getByIndex(r'pairId_userId', [pairId, userId]);
  }

  RoomMember? getByPairIdUserIdSync(String? pairId, int? userId) {
    return getByIndexSync(r'pairId_userId', [pairId, userId]);
  }

  Future<bool> deleteByPairIdUserId(String? pairId, int? userId) {
    return deleteByIndex(r'pairId_userId', [pairId, userId]);
  }

  bool deleteByPairIdUserIdSync(String? pairId, int? userId) {
    return deleteByIndexSync(r'pairId_userId', [pairId, userId]);
  }

  Future<List<RoomMember?>> getAllByPairIdUserId(
      List<String?> pairIdValues, List<int?> userIdValues) {
    final len = pairIdValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pairIdValues[i], userIdValues[i]]);
    }

    return getAllByIndex(r'pairId_userId', values);
  }

  List<RoomMember?> getAllByPairIdUserIdSync(
      List<String?> pairIdValues, List<int?> userIdValues) {
    final len = pairIdValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pairIdValues[i], userIdValues[i]]);
    }

    return getAllByIndexSync(r'pairId_userId', values);
  }

  Future<int> deleteAllByPairIdUserId(
      List<String?> pairIdValues, List<int?> userIdValues) {
    final len = pairIdValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pairIdValues[i], userIdValues[i]]);
    }

    return deleteAllByIndex(r'pairId_userId', values);
  }

  int deleteAllByPairIdUserIdSync(
      List<String?> pairIdValues, List<int?> userIdValues) {
    final len = pairIdValues.length;
    assert(userIdValues.length == len,
        'All index values must have the same length');
    final values = <List<dynamic>>[];
    for (var i = 0; i < len; i++) {
      values.add([pairIdValues[i], userIdValues[i]]);
    }

    return deleteAllByIndexSync(r'pairId_userId', values);
  }

  Future<Id> putByPairIdUserId(RoomMember object) {
    return putByIndex(r'pairId_userId', object);
  }

  Id putByPairIdUserIdSync(RoomMember object, {bool saveLinks = true}) {
    return putByIndexSync(r'pairId_userId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPairIdUserId(List<RoomMember> objects) {
    return putAllByIndex(r'pairId_userId', objects);
  }

  List<Id> putAllByPairIdUserIdSync(List<RoomMember> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'pairId_userId', objects, saveLinks: saveLinks);
  }
}

extension RoomMemberQueryWhereSort
    on QueryBuilder<RoomMember, RoomMember, QWhere> {
  QueryBuilder<RoomMember, RoomMember, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhere> anyMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'msgId'),
      );
    });
  }
}

extension RoomMemberQueryWhere
    on QueryBuilder<RoomMember, RoomMember, QWhereClause> {
  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> idBetween(
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

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdIsNullAnyUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId_userId',
        value: [null],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdIsNotNullAnyUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId_userId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToAnyUserId(String? pairId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId_userId',
        value: [pairId],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdNotEqualToAnyUserId(String? pairId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [],
              upper: [pairId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdIsNull(String? pairId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId_userId',
        value: [pairId, null],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdIsNotNull(String? pairId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId_userId',
        lower: [pairId, null],
        includeLower: false,
        upper: [
          pairId,
        ],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> pairIdUserIdEqualTo(
      String? pairId, int? userId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'pairId_userId',
        value: [pairId, userId],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdNotEqualTo(String? pairId, int? userId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId],
              upper: [pairId, userId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId, userId],
              includeLower: false,
              upper: [pairId],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId, userId],
              includeLower: false,
              upper: [pairId],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'pairId_userId',
              lower: [pairId],
              upper: [pairId, userId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdGreaterThan(
    String? pairId,
    int? userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId_userId',
        lower: [pairId, userId],
        includeLower: include,
        upper: [pairId],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdLessThan(
    String? pairId,
    int? userId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId_userId',
        lower: [pairId],
        upper: [pairId, userId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause>
      pairIdEqualToUserIdBetween(
    String? pairId,
    int? lowerUserId,
    int? upperUserId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'pairId_userId',
        lower: [pairId, lowerUserId],
        includeLower: includeLower,
        upper: [pairId, upperUserId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> msgIdEqualTo(
      int msgId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'msgId',
        value: [msgId],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> msgIdNotEqualTo(
      int msgId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'msgId',
              lower: [],
              upper: [msgId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'msgId',
              lower: [msgId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'msgId',
              lower: [msgId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'msgId',
              lower: [],
              upper: [msgId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> msgIdGreaterThan(
    int msgId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'msgId',
        lower: [msgId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> msgIdLessThan(
    int msgId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'msgId',
        lower: [],
        upper: [msgId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterWhereClause> msgIdBetween(
    int lowerMsgId,
    int upperMsgId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'msgId',
        lower: [lowerMsgId],
        includeLower: includeLower,
        upper: [upperMsgId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoomMemberQueryFilter
    on QueryBuilder<RoomMember, RoomMember, QFilterCondition> {
  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> idBetween(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> msgIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'msgId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> msgIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'msgId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> msgIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'msgId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> msgIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'msgId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pairId',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition>
      pairIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pairId',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdEqualTo(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdGreaterThan(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdLessThan(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdBetween(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdStartsWith(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdEndsWith(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdContains(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdMatches(
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

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> pairIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition>
      pairIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pairId',
        value: '',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition>
      senderUserIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'senderUser',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition>
      senderUserIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'senderUser',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> userIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition>
      userIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userId',
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> userIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> userIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> userIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userId',
        value: value,
      ));
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> userIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoomMemberQueryObject
    on QueryBuilder<RoomMember, RoomMember, QFilterCondition> {
  QueryBuilder<RoomMember, RoomMember, QAfterFilterCondition> senderUser(
      FilterQuery<ShowUser> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'senderUser');
    });
  }
}

extension RoomMemberQueryLinks
    on QueryBuilder<RoomMember, RoomMember, QFilterCondition> {}

extension RoomMemberQuerySortBy
    on QueryBuilder<RoomMember, RoomMember, QSortBy> {
  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByMsgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.desc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RoomMemberQuerySortThenBy
    on QueryBuilder<RoomMember, RoomMember, QSortThenBy> {
  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByMsgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'msgId', Sort.desc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByPairId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByPairIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pairId', Sort.desc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QAfterSortBy> thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension RoomMemberQueryWhereDistinct
    on QueryBuilder<RoomMember, RoomMember, QDistinct> {
  QueryBuilder<RoomMember, RoomMember, QDistinct> distinctByMsgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'msgId');
    });
  }

  QueryBuilder<RoomMember, RoomMember, QDistinct> distinctByPairId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pairId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RoomMember, RoomMember, QDistinct> distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension RoomMemberQueryProperty
    on QueryBuilder<RoomMember, RoomMember, QQueryProperty> {
  QueryBuilder<RoomMember, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<RoomMember, int, QQueryOperations> msgIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'msgId');
    });
  }

  QueryBuilder<RoomMember, String?, QQueryOperations> pairIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pairId');
    });
  }

  QueryBuilder<RoomMember, ShowUser?, QQueryOperations> senderUserProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderUser');
    });
  }

  QueryBuilder<RoomMember, int?, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
