// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotesCollection on Isar {
  IsarCollection<Notes> get notes => this.collection();
}

const NotesSchema = CollectionSchema(
  name: r'Notes',
  id: 1316144172548953035,
  properties: {
    r'contentWords': PropertySchema(
      id: 0,
      name: r'contentWords',
      type: IsarType.string,
    ),
    r'createTime': PropertySchema(
      id: 1,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'deleteTime': PropertySchema(
      id: 2,
      name: r'deleteTime',
      type: IsarType.long,
    ),
    r'items': PropertySchema(
      id: 3,
      name: r'items',
      type: IsarType.objectList,
      target: r'NoteItem',
    ),
    r'mark': PropertySchema(
      id: 4,
      name: r'mark',
      type: IsarType.string,
    ),
    r'reason': PropertySchema(
      id: 5,
      name: r'reason',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 6,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'taskStatusInt': PropertySchema(
      id: 7,
      name: r'taskStatusInt',
      type: IsarType.long,
    ),
    r'topTime': PropertySchema(
      id: 8,
      name: r'topTime',
      type: IsarType.long,
    ),
    r'upId': PropertySchema(
      id: 9,
      name: r'upId',
      type: IsarType.long,
    ),
    r'updateTime': PropertySchema(
      id: 10,
      name: r'updateTime',
      type: IsarType.long,
    )
  },
  estimateSize: _notesEstimateSize,
  serialize: _notesSerialize,
  deserialize: _notesDeserialize,
  deserializeProp: _notesDeserializeProp,
  idName: r'id',
  indexes: {
    r'upId': IndexSchema(
      id: -1252797001115891002,
      name: r'upId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'upId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'updateTime': IndexSchema(
      id: 397922507239516479,
      name: r'updateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'updateTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'topTime': IndexSchema(
      id: -9060848617112983115,
      name: r'topTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topTime',
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
    r'tags': IndexSchema(
      id: 4029205728550669204,
      name: r'tags',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tags',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'taskStatusInt': IndexSchema(
      id: -5774138784597690482,
      name: r'taskStatusInt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'taskStatusInt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'NoteItem': NoteItemSchema},
  getId: _notesGetId,
  getLinks: _notesGetLinks,
  attach: _notesAttach,
  version: '3.1.0+1',
);

int _notesEstimateSize(
  Notes object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.contentWords.length * 3;
  bytesCount += 3 + object.items.length * 3;
  {
    final offsets = allOffsets[NoteItem]!;
    for (var i = 0; i < object.items.length; i++) {
      final value = object.items[i];
      bytesCount += NoteItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.mark;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _notesSerialize(
  Notes object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.contentWords);
  writer.writeLong(offsets[1], object.createTime);
  writer.writeLong(offsets[2], object.deleteTime);
  writer.writeObjectList<NoteItem>(
    offsets[3],
    allOffsets,
    NoteItemSchema.serialize,
    object.items,
  );
  writer.writeString(offsets[4], object.mark);
  writer.writeString(offsets[5], object.reason);
  writer.writeStringList(offsets[6], object.tags);
  writer.writeLong(offsets[7], object.taskStatusInt);
  writer.writeLong(offsets[8], object.topTime);
  writer.writeLong(offsets[9], object.upId);
  writer.writeLong(offsets[10], object.updateTime);
}

Notes _notesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Notes();
  object.createTime = reader.readLong(offsets[1]);
  object.deleteTime = reader.readLong(offsets[2]);
  object.id = id;
  object.items = reader.readObjectList<NoteItem>(
        offsets[3],
        NoteItemSchema.deserialize,
        allOffsets,
        NoteItem(),
      ) ??
      [];
  object.mark = reader.readStringOrNull(offsets[4]);
  object.reason = reader.readStringOrNull(offsets[5]);
  object.tags = reader.readStringList(offsets[6]) ?? [];
  object.taskStatusInt = reader.readLong(offsets[7]);
  object.topTime = reader.readLong(offsets[8]);
  object.upId = reader.readLong(offsets[9]);
  object.updateTime = reader.readLong(offsets[10]);
  return object;
}

P _notesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readObjectList<NoteItem>(
            offset,
            NoteItemSchema.deserialize,
            allOffsets,
            NoteItem(),
          ) ??
          []) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notesGetId(Notes object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notesGetLinks(Notes object) {
  return [];
}

void _notesAttach(IsarCollection<dynamic> col, Id id, Notes object) {
  object.id = id;
}

extension NotesByIndex on IsarCollection<Notes> {
  Future<Notes?> getByUpId(int upId) {
    return getByIndex(r'upId', [upId]);
  }

  Notes? getByUpIdSync(int upId) {
    return getByIndexSync(r'upId', [upId]);
  }

  Future<bool> deleteByUpId(int upId) {
    return deleteByIndex(r'upId', [upId]);
  }

  bool deleteByUpIdSync(int upId) {
    return deleteByIndexSync(r'upId', [upId]);
  }

  Future<List<Notes?>> getAllByUpId(List<int> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'upId', values);
  }

  List<Notes?> getAllByUpIdSync(List<int> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'upId', values);
  }

  Future<int> deleteAllByUpId(List<int> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'upId', values);
  }

  int deleteAllByUpIdSync(List<int> upIdValues) {
    final values = upIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'upId', values);
  }

  Future<Id> putByUpId(Notes object) {
    return putByIndex(r'upId', object);
  }

  Id putByUpIdSync(Notes object, {bool saveLinks = true}) {
    return putByIndexSync(r'upId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUpId(List<Notes> objects) {
    return putAllByIndex(r'upId', objects);
  }

  List<Id> putAllByUpIdSync(List<Notes> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'upId', objects, saveLinks: saveLinks);
  }
}

extension NotesQueryWhereSort on QueryBuilder<Notes, Notes, QWhere> {
  QueryBuilder<Notes, Notes, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhere> anyUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'upId'),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhere> anyUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'updateTime'),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhere> anyTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'topTime'),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhere> anyDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'deleteTime'),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhere> anyTaskStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'taskStatusInt'),
      );
    });
  }
}

extension NotesQueryWhere on QueryBuilder<Notes, Notes, QWhereClause> {
  QueryBuilder<Notes, Notes, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> idBetween(
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> upIdEqualTo(int upId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'upId',
        value: [upId],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> upIdNotEqualTo(int upId) {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> upIdGreaterThan(
    int upId, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> upIdLessThan(
    int upId, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> upIdBetween(
    int lowerUpId,
    int upperUpId, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> updateTimeEqualTo(
      int updateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'updateTime',
        value: [updateTime],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> updateTimeNotEqualTo(
      int updateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTime',
              lower: [],
              upper: [updateTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTime',
              lower: [updateTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTime',
              lower: [updateTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'updateTime',
              lower: [],
              upper: [updateTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> updateTimeGreaterThan(
    int updateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTime',
        lower: [updateTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> updateTimeLessThan(
    int updateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTime',
        lower: [],
        upper: [updateTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> updateTimeBetween(
    int lowerUpdateTime,
    int upperUpdateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'updateTime',
        lower: [lowerUpdateTime],
        includeLower: includeLower,
        upper: [upperUpdateTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> topTimeEqualTo(int topTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topTime',
        value: [topTime],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> topTimeNotEqualTo(int topTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime',
              lower: [],
              upper: [topTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime',
              lower: [topTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime',
              lower: [topTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topTime',
              lower: [],
              upper: [topTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> topTimeGreaterThan(
    int topTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime',
        lower: [topTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> topTimeLessThan(
    int topTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime',
        lower: [],
        upper: [topTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> topTimeBetween(
    int lowerTopTime,
    int upperTopTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'topTime',
        lower: [lowerTopTime],
        includeLower: includeLower,
        upper: [upperTopTime],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> deleteTimeEqualTo(
      int deleteTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'deleteTime',
        value: [deleteTime],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> deleteTimeNotEqualTo(
      int deleteTime) {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> deleteTimeGreaterThan(
    int deleteTime, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> deleteTimeLessThan(
    int deleteTime, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> deleteTimeBetween(
    int lowerDeleteTime,
    int upperDeleteTime, {
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

  QueryBuilder<Notes, Notes, QAfterWhereClause> tagsEqualTo(List<String> tags) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tags',
        value: [tags],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> tagsNotEqualTo(
      List<String> tags) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tags',
              lower: [],
              upper: [tags],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tags',
              lower: [tags],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tags',
              lower: [tags],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tags',
              lower: [],
              upper: [tags],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> taskStatusIntEqualTo(
      int taskStatusInt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'taskStatusInt',
        value: [taskStatusInt],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> taskStatusIntNotEqualTo(
      int taskStatusInt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskStatusInt',
              lower: [],
              upper: [taskStatusInt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskStatusInt',
              lower: [taskStatusInt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskStatusInt',
              lower: [taskStatusInt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'taskStatusInt',
              lower: [],
              upper: [taskStatusInt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> taskStatusIntGreaterThan(
    int taskStatusInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskStatusInt',
        lower: [taskStatusInt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> taskStatusIntLessThan(
    int taskStatusInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskStatusInt',
        lower: [],
        upper: [taskStatusInt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterWhereClause> taskStatusIntBetween(
    int lowerTaskStatusInt,
    int upperTaskStatusInt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'taskStatusInt',
        lower: [lowerTaskStatusInt],
        includeLower: includeLower,
        upper: [upperTaskStatusInt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotesQueryFilter on QueryBuilder<Notes, Notes, QFilterCondition> {
  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentWords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentWords',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentWords',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentWords',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> contentWordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentWords',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> createTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> createTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> createTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> createTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> deleteTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deleteTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> deleteTimeGreaterThan(
    int value, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> deleteTimeLessThan(
    int value, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> deleteTimeBetween(
    int lower,
    int upper, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markEqualTo(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markGreaterThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markLessThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markBetween(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markStartsWith(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markEndsWith(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mark',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mark',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> markIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reason',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reason',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> taskStatusIntEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> taskStatusIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> taskStatusIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskStatusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> taskStatusIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskStatusInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> topTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> topTimeGreaterThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> topTimeLessThan(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> topTimeBetween(
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> upIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'upId',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> upIdGreaterThan(
    int value, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> upIdLessThan(
    int value, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> upIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<Notes, Notes, QAfterFilterCondition> updateTimeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> updateTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> updateTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Notes, Notes, QAfterFilterCondition> updateTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotesQueryObject on QueryBuilder<Notes, Notes, QFilterCondition> {
  QueryBuilder<Notes, Notes, QAfterFilterCondition> itemsElement(
      FilterQuery<NoteItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension NotesQueryLinks on QueryBuilder<Notes, Notes, QFilterCondition> {}

extension NotesQuerySortBy on QueryBuilder<Notes, Notes, QSortBy> {
  QueryBuilder<Notes, Notes, QAfterSortBy> sortByContentWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentWords', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByContentWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentWords', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByDeleteTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByTaskStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskStatusInt', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByTaskStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskStatusInt', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByTopTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByUpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> sortByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }
}

extension NotesQuerySortThenBy on QueryBuilder<Notes, Notes, QSortThenBy> {
  QueryBuilder<Notes, Notes, QAfterSortBy> thenByContentWords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentWords', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByContentWordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentWords', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByDeleteTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deleteTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByTaskStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskStatusInt', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByTaskStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskStatusInt', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByTopTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topTime', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByUpIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'upId', Sort.desc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.asc);
    });
  }

  QueryBuilder<Notes, Notes, QAfterSortBy> thenByUpdateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updateTime', Sort.desc);
    });
  }
}

extension NotesQueryWhereDistinct on QueryBuilder<Notes, Notes, QDistinct> {
  QueryBuilder<Notes, Notes, QDistinct> distinctByContentWords(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentWords', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByDeleteTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deleteTime');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByMark(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByTaskStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskStatusInt');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByTopTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topTime');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByUpId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'upId');
    });
  }

  QueryBuilder<Notes, Notes, QDistinct> distinctByUpdateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updateTime');
    });
  }
}

extension NotesQueryProperty on QueryBuilder<Notes, Notes, QQueryProperty> {
  QueryBuilder<Notes, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Notes, String, QQueryOperations> contentWordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentWords');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> deleteTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deleteTime');
    });
  }

  QueryBuilder<Notes, List<NoteItem>, QQueryOperations> itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<Notes, String?, QQueryOperations> markProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mark');
    });
  }

  QueryBuilder<Notes, String?, QQueryOperations> reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<Notes, List<String>, QQueryOperations> tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> taskStatusIntProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskStatusInt');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> topTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topTime');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> upIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'upId');
    });
  }

  QueryBuilder<Notes, int, QQueryOperations> updateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updateTime');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const NoteItemSchema = Schema(
  name: r'NoteItem',
  id: -2852008337419419180,
  properties: {
    r'color': PropertySchema(
      id: 0,
      name: r'color',
      type: IsarType.string,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'fontSize': PropertySchema(
      id: 2,
      name: r'fontSize',
      type: IsarType.string,
    ),
    r'fontWeight': PropertySchema(
      id: 3,
      name: r'fontWeight',
      type: IsarType.bool,
    ),
    r'subTitle': PropertySchema(
      id: 4,
      name: r'subTitle',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 5,
      name: r'title',
      type: IsarType.string,
    ),
    r'typeInt': PropertySchema(
      id: 6,
      name: r'typeInt',
      type: IsarType.long,
    )
  },
  estimateSize: _noteItemEstimateSize,
  serialize: _noteItemSerialize,
  deserialize: _noteItemDeserialize,
  deserializeProp: _noteItemDeserializeProp,
);

int _noteItemEstimateSize(
  NoteItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.color;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.content;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fontSize;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _noteItemSerialize(
  NoteItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.color);
  writer.writeString(offsets[1], object.content);
  writer.writeString(offsets[2], object.fontSize);
  writer.writeBool(offsets[3], object.fontWeight);
  writer.writeString(offsets[4], object.subTitle);
  writer.writeString(offsets[5], object.title);
  writer.writeLong(offsets[6], object.typeInt);
}

NoteItem _noteItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NoteItem();
  object.color = reader.readStringOrNull(offsets[0]);
  object.content = reader.readStringOrNull(offsets[1]);
  object.fontSize = reader.readStringOrNull(offsets[2]);
  object.fontWeight = reader.readBoolOrNull(offsets[3]);
  object.subTitle = reader.readStringOrNull(offsets[4]);
  object.title = reader.readStringOrNull(offsets[5]);
  object.typeInt = reader.readLong(offsets[6]);
  return object;
}

P _noteItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension NoteItemQueryFilter
    on QueryBuilder<NoteItem, NoteItem, QFilterCondition> {
  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'color',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> colorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'content',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontSize',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontSize',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fontSize',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fontSize',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontSizeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fontSize',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontWeight',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition>
      fontWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontWeight',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> fontWeightEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontWeight',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subTitle',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subTitle',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> subTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'title',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> typeIntEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'typeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> typeIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'typeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> typeIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'typeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<NoteItem, NoteItem, QAfterFilterCondition> typeIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'typeInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoteItemQueryObject
    on QueryBuilder<NoteItem, NoteItem, QFilterCondition> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notes _$NotesFromJson(Map<String, dynamic> json) => Notes()
  ..upId = json['upId'] as int
  ..mark = json['mark'] as String?
  ..items = (json['items'] as List<dynamic>)
      .map((e) => NoteItem.fromJson(e as Map<String, dynamic>))
      .toList()
  ..createTime = json['createTime'] as int
  ..updateTime = json['updateTime'] as int
  ..topTime = json['topTime'] as int
  ..deleteTime = json['deleteTime'] as int
  ..reason = json['reason'] as String?
  ..tags = (json['tags'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$NotesToJson(Notes instance) {
  final val = <String, dynamic>{
    'upId': instance.upId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('mark', instance.mark);
  val['items'] = instance.items.map((e) => e.toJson()).toList();
  val['createTime'] = instance.createTime;
  val['updateTime'] = instance.updateTime;
  val['topTime'] = instance.topTime;
  val['deleteTime'] = instance.deleteTime;
  writeNotNull('reason', instance.reason);
  val['tags'] = instance.tags;
  return val;
}

NoteItem _$NoteItemFromJson(Map<String, dynamic> json) => NoteItem()
  ..type = NoteItem._typeFromJson(json['type'] as int?)
  ..title = json['title'] as String?
  ..subTitle = json['subTitle'] as String?
  ..content = json['content'] as String?
  ..fontSize = json['fontSize'] as String?
  ..fontWeight = json['fontWeight'] as bool?
  ..color = json['color'] as String?;

Map<String, dynamic> _$NoteItemToJson(NoteItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('type', NoteItem._typeToJson(instance.type));
  writeNotNull('title', instance.title);
  writeNotNull('subTitle', instance.subTitle);
  writeNotNull('content', instance.content);
  writeNotNull('fontSize', instance.fontSize);
  writeNotNull('fontWeight', instance.fontWeight);
  writeNotNull('color', instance.color);
  return val;
}
