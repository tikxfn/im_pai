// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserInfoCollection on Isar {
  IsarCollection<UserInfo> get userInfos => this.collection();
}

const UserInfoSchema = CollectionSchema(
  name: r'UserInfo',
  id: 8636641989201795248,
  properties: {
    r'account': PropertySchema(
      id: 0,
      name: r'account',
      type: IsarType.string,
    ),
    r'avatar': PropertySchema(
      id: 1,
      name: r'avatar',
      type: IsarType.string,
    ),
    r'birthday': PropertySchema(
      id: 2,
      name: r'birthday',
      type: IsarType.long,
    ),
    r'chatDestroyDuration': PropertySchema(
      id: 3,
      name: r'chatDestroyDuration',
      type: IsarType.long,
    ),
    r'city': PropertySchema(
      id: 4,
      name: r'city',
      type: IsarType.string,
    ),
    r'commonCircle': PropertySchema(
      id: 5,
      name: r'commonCircle',
      type: IsarType.long,
    ),
    r'commonFriend': PropertySchema(
      id: 6,
      name: r'commonFriend',
      type: IsarType.long,
    ),
    r'commonRoom': PropertySchema(
      id: 7,
      name: r'commonRoom',
      type: IsarType.long,
    ),
    r'createTime': PropertySchema(
      id: 8,
      name: r'createTime',
      type: IsarType.long,
    ),
    r'customerTypeInt': PropertySchema(
      id: 9,
      name: r'customerTypeInt',
      type: IsarType.long,
    ),
    r'disableReason': PropertySchema(
      id: 10,
      name: r'disableReason',
      type: IsarType.string,
    ),
    r'disableTime': PropertySchema(
      id: 11,
      name: r'disableTime',
      type: IsarType.long,
    ),
    r'email': PropertySchema(
      id: 12,
      name: r'email',
      type: IsarType.string,
    ),
    r'enablePin': PropertySchema(
      id: 13,
      name: r'enablePin',
      type: IsarType.bool,
    ),
    r'integral': PropertySchema(
      id: 14,
      name: r'integral',
      type: IsarType.long,
    ),
    r'ip': PropertySchema(
      id: 15,
      name: r'ip',
      type: IsarType.string,
    ),
    r'isChangeAccount': PropertySchema(
      id: 16,
      name: r'isChangeAccount',
      type: IsarType.bool,
    ),
    r'isHavePhone': PropertySchema(
      id: 17,
      name: r'isHavePhone',
      type: IsarType.bool,
    ),
    r'isPin': PropertySchema(
      id: 18,
      name: r'isPin',
      type: IsarType.bool,
    ),
    r'isSetPassword': PropertySchema(
      id: 19,
      name: r'isSetPassword',
      type: IsarType.bool,
    ),
    r'lastOnlineTime': PropertySchema(
      id: 20,
      name: r'lastOnlineTime',
      type: IsarType.long,
    ),
    r'leftUserId': PropertySchema(
      id: 21,
      name: r'leftUserId',
      type: IsarType.long,
    ),
    r'level': PropertySchema(
      id: 22,
      name: r'level',
      type: IsarType.long,
    ),
    r'mark': PropertySchema(
      id: 23,
      name: r'mark',
      type: IsarType.string,
    ),
    r'nickPingyin': PropertySchema(
      id: 24,
      name: r'nickPingyin',
      type: IsarType.string,
    ),
    r'nickname': PropertySchema(
      id: 25,
      name: r'nickname',
      type: IsarType.string,
    ),
    r'password': PropertySchema(
      id: 26,
      name: r'password',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 27,
      name: r'phone',
      type: IsarType.string,
    ),
    r'privacy': PropertySchema(
      id: 28,
      name: r'privacy',
      type: IsarType.long,
    ),
    r'privilege': PropertySchema(
      id: 29,
      name: r'privilege',
      type: IsarType.long,
    ),
    r'sexInt': PropertySchema(
      id: 30,
      name: r'sexInt',
      type: IsarType.long,
    ),
    r'slogan': PropertySchema(
      id: 31,
      name: r'slogan',
      type: IsarType.string,
    ),
    r'statusInt': PropertySchema(
      id: 32,
      name: r'statusInt',
      type: IsarType.long,
    ),
    r'trendsBackground': PropertySchema(
      id: 33,
      name: r'trendsBackground',
      type: IsarType.string,
    ),
    r'useChangeNicknameCard': PropertySchema(
      id: 34,
      name: r'useChangeNicknameCard',
      type: IsarType.bool,
    ),
    r'userExtend': PropertySchema(
      id: 35,
      name: r'userExtend',
      type: IsarType.object,
      target: r'UserInfoExtend',
    )
  },
  estimateSize: _userInfoEstimateSize,
  serialize: _userInfoSerialize,
  deserialize: _userInfoDeserialize,
  deserializeProp: _userInfoDeserializeProp,
  idName: r'id',
  indexes: {
    r'account': IndexSchema(
      id: -5827943236100964141,
      name: r'account',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'account',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'customerTypeInt': IndexSchema(
      id: -7911838351681389963,
      name: r'customerTypeInt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'customerTypeInt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'sexInt': IndexSchema(
      id: 162876968480249156,
      name: r'sexInt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sexInt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'statusInt': IndexSchema(
      id: -3732240100120322434,
      name: r'statusInt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'statusInt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'UserInfoExtend': UserInfoExtendSchema},
  getId: _userInfoGetId,
  getLinks: _userInfoGetLinks,
  attach: _userInfoAttach,
  version: '3.1.0+1',
);

int _userInfoEstimateSize(
  UserInfo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.account.length * 3;
  {
    final value = object.avatar;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.city;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.disableReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ip;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.mark;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nickPingyin;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.nickname;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.password;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.phone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.slogan;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.trendsBackground;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.userExtend;
    if (value != null) {
      bytesCount += 3 +
          UserInfoExtendSchema.estimateSize(
              value, allOffsets[UserInfoExtend]!, allOffsets);
    }
  }
  return bytesCount;
}

void _userInfoSerialize(
  UserInfo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.account);
  writer.writeString(offsets[1], object.avatar);
  writer.writeLong(offsets[2], object.birthday);
  writer.writeLong(offsets[3], object.chatDestroyDuration);
  writer.writeString(offsets[4], object.city);
  writer.writeLong(offsets[5], object.commonCircle);
  writer.writeLong(offsets[6], object.commonFriend);
  writer.writeLong(offsets[7], object.commonRoom);
  writer.writeLong(offsets[8], object.createTime);
  writer.writeLong(offsets[9], object.customerTypeInt);
  writer.writeString(offsets[10], object.disableReason);
  writer.writeLong(offsets[11], object.disableTime);
  writer.writeString(offsets[12], object.email);
  writer.writeBool(offsets[13], object.enablePin);
  writer.writeLong(offsets[14], object.integral);
  writer.writeString(offsets[15], object.ip);
  writer.writeBool(offsets[16], object.isChangeAccount);
  writer.writeBool(offsets[17], object.isHavePhone);
  writer.writeBool(offsets[18], object.isPin);
  writer.writeBool(offsets[19], object.isSetPassword);
  writer.writeLong(offsets[20], object.lastOnlineTime);
  writer.writeLong(offsets[21], object.leftUserId);
  writer.writeLong(offsets[22], object.level);
  writer.writeString(offsets[23], object.mark);
  writer.writeString(offsets[24], object.nickPingyin);
  writer.writeString(offsets[25], object.nickname);
  writer.writeString(offsets[26], object.password);
  writer.writeString(offsets[27], object.phone);
  writer.writeLong(offsets[28], object.privacy);
  writer.writeLong(offsets[29], object.privilege);
  writer.writeLong(offsets[30], object.sexInt);
  writer.writeString(offsets[31], object.slogan);
  writer.writeLong(offsets[32], object.statusInt);
  writer.writeString(offsets[33], object.trendsBackground);
  writer.writeBool(offsets[34], object.useChangeNicknameCard);
  writer.writeObject<UserInfoExtend>(
    offsets[35],
    allOffsets,
    UserInfoExtendSchema.serialize,
    object.userExtend,
  );
}

UserInfo _userInfoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserInfo();
  object.account = reader.readString(offsets[0]);
  object.avatar = reader.readStringOrNull(offsets[1]);
  object.birthday = reader.readLongOrNull(offsets[2]);
  object.chatDestroyDuration = reader.readLongOrNull(offsets[3]);
  object.city = reader.readStringOrNull(offsets[4]);
  object.commonCircle = reader.readLong(offsets[5]);
  object.commonFriend = reader.readLong(offsets[6]);
  object.commonRoom = reader.readLong(offsets[7]);
  object.createTime = reader.readLongOrNull(offsets[8]);
  object.customerTypeInt = reader.readLong(offsets[9]);
  object.disableReason = reader.readStringOrNull(offsets[10]);
  object.disableTime = reader.readLongOrNull(offsets[11]);
  object.email = reader.readStringOrNull(offsets[12]);
  object.enablePin = reader.readBool(offsets[13]);
  object.id = id;
  object.integral = reader.readLong(offsets[14]);
  object.ip = reader.readStringOrNull(offsets[15]);
  object.isChangeAccount = reader.readBool(offsets[16]);
  object.isHavePhone = reader.readBool(offsets[17]);
  object.isPin = reader.readBool(offsets[18]);
  object.isSetPassword = reader.readBool(offsets[19]);
  object.lastOnlineTime = reader.readLongOrNull(offsets[20]);
  object.leftUserId = reader.readLongOrNull(offsets[21]);
  object.level = reader.readLong(offsets[22]);
  object.mark = reader.readStringOrNull(offsets[23]);
  object.nickPingyin = reader.readStringOrNull(offsets[24]);
  object.nickname = reader.readStringOrNull(offsets[25]);
  object.password = reader.readStringOrNull(offsets[26]);
  object.phone = reader.readStringOrNull(offsets[27]);
  object.privacy = reader.readLong(offsets[28]);
  object.privilege = reader.readLong(offsets[29]);
  object.sexInt = reader.readLong(offsets[30]);
  object.slogan = reader.readStringOrNull(offsets[31]);
  object.statusInt = reader.readLong(offsets[32]);
  object.trendsBackground = reader.readStringOrNull(offsets[33]);
  object.useChangeNicknameCard = reader.readBool(offsets[34]);
  object.userExtend = reader.readObjectOrNull<UserInfoExtend>(
    offsets[35],
    UserInfoExtendSchema.deserialize,
    allOffsets,
  );
  return object;
}

P _userInfoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readLongOrNull(offset)) as P;
    case 21:
      return (reader.readLongOrNull(offset)) as P;
    case 22:
      return (reader.readLong(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (reader.readLong(offset)) as P;
    case 30:
      return (reader.readLong(offset)) as P;
    case 31:
      return (reader.readStringOrNull(offset)) as P;
    case 32:
      return (reader.readLong(offset)) as P;
    case 33:
      return (reader.readStringOrNull(offset)) as P;
    case 34:
      return (reader.readBool(offset)) as P;
    case 35:
      return (reader.readObjectOrNull<UserInfoExtend>(
        offset,
        UserInfoExtendSchema.deserialize,
        allOffsets,
      )) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userInfoGetId(UserInfo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userInfoGetLinks(UserInfo object) {
  return [];
}

void _userInfoAttach(IsarCollection<dynamic> col, Id id, UserInfo object) {
  object.id = id;
}

extension UserInfoQueryWhereSort on QueryBuilder<UserInfo, UserInfo, QWhere> {
  QueryBuilder<UserInfo, UserInfo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhere> anyCustomerTypeInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'customerTypeInt'),
      );
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhere> anySexInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sexInt'),
      );
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhere> anyStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'statusInt'),
      );
    });
  }
}

extension UserInfoQueryWhere on QueryBuilder<UserInfo, UserInfo, QWhereClause> {
  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> idBetween(
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

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> accountEqualTo(
      String account) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'account',
        value: [account],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> accountNotEqualTo(
      String account) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'account',
              lower: [],
              upper: [account],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'account',
              lower: [account],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'account',
              lower: [account],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'account',
              lower: [],
              upper: [account],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> customerTypeIntEqualTo(
      int customerTypeInt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'customerTypeInt',
        value: [customerTypeInt],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> customerTypeIntNotEqualTo(
      int customerTypeInt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'customerTypeInt',
              lower: [],
              upper: [customerTypeInt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'customerTypeInt',
              lower: [customerTypeInt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'customerTypeInt',
              lower: [customerTypeInt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'customerTypeInt',
              lower: [],
              upper: [customerTypeInt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause>
      customerTypeIntGreaterThan(
    int customerTypeInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'customerTypeInt',
        lower: [customerTypeInt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> customerTypeIntLessThan(
    int customerTypeInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'customerTypeInt',
        lower: [],
        upper: [customerTypeInt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> customerTypeIntBetween(
    int lowerCustomerTypeInt,
    int upperCustomerTypeInt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'customerTypeInt',
        lower: [lowerCustomerTypeInt],
        includeLower: includeLower,
        upper: [upperCustomerTypeInt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> sexIntEqualTo(
      int sexInt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sexInt',
        value: [sexInt],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> sexIntNotEqualTo(
      int sexInt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sexInt',
              lower: [],
              upper: [sexInt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sexInt',
              lower: [sexInt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sexInt',
              lower: [sexInt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sexInt',
              lower: [],
              upper: [sexInt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> sexIntGreaterThan(
    int sexInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sexInt',
        lower: [sexInt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> sexIntLessThan(
    int sexInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sexInt',
        lower: [],
        upper: [sexInt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> sexIntBetween(
    int lowerSexInt,
    int upperSexInt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sexInt',
        lower: [lowerSexInt],
        includeLower: includeLower,
        upper: [upperSexInt],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> statusIntEqualTo(
      int statusInt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'statusInt',
        value: [statusInt],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> statusIntNotEqualTo(
      int statusInt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statusInt',
              lower: [],
              upper: [statusInt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statusInt',
              lower: [statusInt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statusInt',
              lower: [statusInt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'statusInt',
              lower: [],
              upper: [statusInt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> statusIntGreaterThan(
    int statusInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'statusInt',
        lower: [statusInt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> statusIntLessThan(
    int statusInt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'statusInt',
        lower: [],
        upper: [statusInt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterWhereClause> statusIntBetween(
    int lowerStatusInt,
    int upperStatusInt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'statusInt',
        lower: [lowerStatusInt],
        includeLower: includeLower,
        upper: [upperStatusInt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserInfoQueryFilter
    on QueryBuilder<UserInfo, UserInfo, QFilterCondition> {
  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'account',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'account',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'account',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'account',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> accountIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'account',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avatar',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarEqualTo(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarGreaterThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarLessThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarBetween(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarStartsWith(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarEndsWith(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarContains(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarMatches(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> avatarIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'avatar',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'birthday',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'birthday',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'birthday',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'birthday',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'birthday',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> birthdayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'birthday',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chatDestroyDuration',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chatDestroyDuration',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chatDestroyDuration',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      chatDestroyDurationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chatDestroyDuration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'city',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'city',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'city',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'city',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> cityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonCircleEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonCircle',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      commonCircleGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commonCircle',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonCircleLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commonCircle',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonCircleBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commonCircle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonFriendEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonFriend',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      commonFriendGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commonFriend',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonFriendLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commonFriend',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonFriendBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commonFriend',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonRoomEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'commonRoom',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonRoomGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'commonRoom',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonRoomLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'commonRoom',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> commonRoomBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'commonRoom',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> createTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      createTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> createTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> createTimeGreaterThan(
    int? value, {
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> createTimeLessThan(
    int? value, {
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> createTimeBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      customerTypeIntEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'customerTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      customerTypeIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'customerTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      customerTypeIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'customerTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      customerTypeIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'customerTypeInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'disableReason',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'disableReason',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disableReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'disableReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableReasonMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'disableReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableReason',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'disableReason',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'disableTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'disableTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disableTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      disableTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disableTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disableTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> disableTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disableTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> enablePinEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enablePin',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> integralEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'integral',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> integralGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'integral',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> integralLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'integral',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> integralBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'integral',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ip',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ip',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ip',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ip',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ip',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ip',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> ipIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ip',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      isChangeAccountEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isChangeAccount',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> isHavePhoneEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHavePhone',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> isPinEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPin',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> isSetPasswordEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSetPassword',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      lastOnlineTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastOnlineTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      lastOnlineTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastOnlineTime',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> lastOnlineTimeEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastOnlineTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      lastOnlineTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastOnlineTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      lastOnlineTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastOnlineTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> lastOnlineTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastOnlineTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> leftUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'leftUserId',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      leftUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'leftUserId',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> leftUserIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'leftUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> leftUserIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'leftUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> leftUserIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'leftUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> leftUserIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'leftUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> levelEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> levelGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> levelLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'level',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> levelBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'level',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mark',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markEqualTo(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markGreaterThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markLessThan(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markBetween(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markStartsWith(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markEndsWith(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markContains(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markMatches(
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

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> markIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mark',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nickPingyin',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      nickPingyinIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nickPingyin',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      nickPingyinGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nickPingyin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nickPingyin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nickPingyin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nickPingyinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickPingyin',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      nickPingyinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nickPingyin',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nickname',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nickname',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nickname',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nickname',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> nicknameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nickname',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'password',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'password',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> passwordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'phone',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privacyEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privacy',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privacyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'privacy',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privacyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'privacy',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privacyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'privacy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privilegeEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'privilege',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privilegeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'privilege',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privilegeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'privilege',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> privilegeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'privilege',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sexIntEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sexInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sexIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sexInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sexIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sexInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sexIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sexInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'slogan',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'slogan',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slogan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slogan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slogan',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> sloganIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slogan',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> statusIntEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'statusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> statusIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'statusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> statusIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'statusInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> statusIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'statusInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trendsBackground',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trendsBackground',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trendsBackground',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'trendsBackground',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'trendsBackground',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trendsBackground',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      trendsBackgroundIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'trendsBackground',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      useChangeNicknameCardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'useChangeNicknameCard',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> userExtendIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userExtend',
      ));
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition>
      userExtendIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userExtend',
      ));
    });
  }
}

extension UserInfoQueryObject
    on QueryBuilder<UserInfo, UserInfo, QFilterCondition> {
  QueryBuilder<UserInfo, UserInfo, QAfterFilterCondition> userExtend(
      FilterQuery<UserInfoExtend> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'userExtend');
    });
  }
}

extension UserInfoQueryLinks
    on QueryBuilder<UserInfo, UserInfo, QFilterCondition> {}

extension UserInfoQuerySortBy on QueryBuilder<UserInfo, UserInfo, QSortBy> {
  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'account', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'account', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByBirthday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByBirthdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy>
      sortByChatDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonCircle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonCircle', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonCircleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonCircle', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonFriend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonFriend', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonFriendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonFriend', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonRoom', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCommonRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonRoom', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCustomerTypeInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerTypeInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByCustomerTypeIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerTypeInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByDisableReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableReason', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByDisableReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableReason', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByDisableTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByDisableTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByEnablePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByEnablePinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIntegral() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'integral', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIntegralDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'integral', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsChangeAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isChangeAccount', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsChangeAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isChangeAccount', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsHavePhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHavePhone', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsHavePhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHavePhone', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsSetPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetPassword', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByIsSetPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetPassword', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLastOnlineTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLastOnlineTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLeftUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leftUserId', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLeftUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leftUserId', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByNickPingyin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickPingyin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByNickPingyinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickPingyin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacy', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPrivacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacy', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPrivilege() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privilege', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByPrivilegeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privilege', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortBySexInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sexInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortBySexIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sexInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortBySlogan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortBySloganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByTrendsBackground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendsBackground', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByTrendsBackgroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendsBackground', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> sortByUseChangeNicknameCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useChangeNicknameCard', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy>
      sortByUseChangeNicknameCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useChangeNicknameCard', Sort.desc);
    });
  }
}

extension UserInfoQuerySortThenBy
    on QueryBuilder<UserInfo, UserInfo, QSortThenBy> {
  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'account', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'account', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByAvatar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByAvatarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avatar', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByBirthday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByBirthdayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'birthday', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatDestroyDuration', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy>
      thenByChatDestroyDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatDestroyDuration', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonCircle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonCircle', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonCircleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonCircle', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonFriend() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonFriend', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonFriendDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonFriend', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonRoom', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCommonRoomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'commonRoom', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCreateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCustomerTypeInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerTypeInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByCustomerTypeIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'customerTypeInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByDisableReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableReason', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByDisableReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableReason', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByDisableTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByDisableTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disableTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByEnablePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByEnablePinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enablePin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIntegral() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'integral', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIntegralDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'integral', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ip', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsChangeAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isChangeAccount', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsChangeAccountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isChangeAccount', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsHavePhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHavePhone', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsHavePhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHavePhone', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsSetPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetPassword', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByIsSetPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSetPassword', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLastOnlineTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineTime', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLastOnlineTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastOnlineTime', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLeftUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leftUserId', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLeftUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'leftUserId', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'level', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByMark() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByMarkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mark', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByNickPingyin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickPingyin', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByNickPingyinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickPingyin', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByNickname() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByNicknameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nickname', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacy', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPrivacyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacy', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPrivilege() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privilege', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByPrivilegeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privilege', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenBySexInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sexInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenBySexIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sexInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenBySlogan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenBySloganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusInt', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByStatusIntDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'statusInt', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByTrendsBackground() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendsBackground', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByTrendsBackgroundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trendsBackground', Sort.desc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy> thenByUseChangeNicknameCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useChangeNicknameCard', Sort.asc);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QAfterSortBy>
      thenByUseChangeNicknameCardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useChangeNicknameCard', Sort.desc);
    });
  }
}

extension UserInfoQueryWhereDistinct
    on QueryBuilder<UserInfo, UserInfo, QDistinct> {
  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByAccount(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'account', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByAvatar(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avatar', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByBirthday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'birthday');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByChatDestroyDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatDestroyDuration');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'city', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCommonCircle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonCircle');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCommonFriend() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonFriend');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCommonRoom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'commonRoom');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCreateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createTime');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByCustomerTypeInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'customerTypeInt');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByDisableReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableReason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByDisableTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disableTime');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByEnablePin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enablePin');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIntegral() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'integral');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIp(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ip', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIsChangeAccount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isChangeAccount');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIsHavePhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHavePhone');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIsPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPin');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByIsSetPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSetPassword');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByLastOnlineTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastOnlineTime');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByLeftUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'leftUserId');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'level');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByMark(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mark', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByNickPingyin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickPingyin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByNickname(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nickname', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByPassword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'password', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByPrivacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'privacy');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByPrivilege() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'privilege');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctBySexInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sexInt');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctBySlogan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slogan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByStatusInt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'statusInt');
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct> distinctByTrendsBackground(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trendsBackground',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserInfo, UserInfo, QDistinct>
      distinctByUseChangeNicknameCard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useChangeNicknameCard');
    });
  }
}

extension UserInfoQueryProperty
    on QueryBuilder<UserInfo, UserInfo, QQueryProperty> {
  QueryBuilder<UserInfo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserInfo, String, QQueryOperations> accountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'account');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> avatarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avatar');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> birthdayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'birthday');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> chatDestroyDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatDestroyDuration');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> cityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'city');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> commonCircleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonCircle');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> commonFriendProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonFriend');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> commonRoomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'commonRoom');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> createTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createTime');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> customerTypeIntProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'customerTypeInt');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> disableReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableReason');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> disableTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disableTime');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations> enablePinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enablePin');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> integralProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'integral');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> ipProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ip');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations> isChangeAccountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isChangeAccount');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations> isHavePhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHavePhone');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations> isPinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPin');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations> isSetPasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSetPassword');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> lastOnlineTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastOnlineTime');
    });
  }

  QueryBuilder<UserInfo, int?, QQueryOperations> leftUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'leftUserId');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> levelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'level');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> markProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mark');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> nickPingyinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickPingyin');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> nicknameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nickname');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> passwordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'password');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> privacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'privacy');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> privilegeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'privilege');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> sexIntProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sexInt');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> sloganProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slogan');
    });
  }

  QueryBuilder<UserInfo, int, QQueryOperations> statusIntProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'statusInt');
    });
  }

  QueryBuilder<UserInfo, String?, QQueryOperations> trendsBackgroundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trendsBackground');
    });
  }

  QueryBuilder<UserInfo, bool, QQueryOperations>
      useChangeNicknameCardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useChangeNicknameCard');
    });
  }

  QueryBuilder<UserInfo, UserInfoExtend?, QQueryOperations>
      userExtendProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userExtend');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const UserInfoExtendSchema = Schema(
  name: r'UserInfoExtend',
  id: -4672479689354828024,
  properties: {
    r'circleGuarantee': PropertySchema(
      id: 0,
      name: r'circleGuarantee',
      type: IsarType.bool,
    ),
    r'isCircleSound': PropertySchema(
      id: 1,
      name: r'isCircleSound',
      type: IsarType.bool,
    ),
    r'registerIp': PropertySchema(
      id: 2,
      name: r'registerIp',
      type: IsarType.string,
    ),
    r'registerReferer': PropertySchema(
      id: 3,
      name: r'registerReferer',
      type: IsarType.string,
    ),
    r'reliable': PropertySchema(
      id: 4,
      name: r'reliable',
      type: IsarType.long,
    ),
    r'userNumber': PropertySchema(
      id: 5,
      name: r'userNumber',
      type: IsarType.string,
    ),
    r'userNumberEffectiveTime': PropertySchema(
      id: 6,
      name: r'userNumberEffectiveTime',
      type: IsarType.long,
    ),
    r'userNumberTypeInt': PropertySchema(
      id: 7,
      name: r'userNumberTypeInt',
      type: IsarType.long,
    ),
    r'vipBadgeInt': PropertySchema(
      id: 8,
      name: r'vipBadgeInt',
      type: IsarType.long,
    ),
    r'vipExperience': PropertySchema(
      id: 9,
      name: r'vipExperience',
      type: IsarType.long,
    ),
    r'vipExpireTime': PropertySchema(
      id: 10,
      name: r'vipExpireTime',
      type: IsarType.long,
    ),
    r'vipLevelInt': PropertySchema(
      id: 11,
      name: r'vipLevelInt',
      type: IsarType.long,
    )
  },
  estimateSize: _userInfoExtendEstimateSize,
  serialize: _userInfoExtendSerialize,
  deserialize: _userInfoExtendDeserialize,
  deserializeProp: _userInfoExtendDeserializeProp,
);

int _userInfoExtendEstimateSize(
  UserInfoExtend object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.registerIp;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.registerReferer;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.userNumber.length * 3;
  return bytesCount;
}

void _userInfoExtendSerialize(
  UserInfoExtend object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.circleGuarantee);
  writer.writeBool(offsets[1], object.isCircleSound);
  writer.writeString(offsets[2], object.registerIp);
  writer.writeString(offsets[3], object.registerReferer);
  writer.writeLong(offsets[4], object.reliable);
  writer.writeString(offsets[5], object.userNumber);
  writer.writeLong(offsets[6], object.userNumberEffectiveTime);
  writer.writeLong(offsets[7], object.userNumberTypeInt);
  writer.writeLong(offsets[8], object.vipBadgeInt);
  writer.writeLong(offsets[9], object.vipExperience);
  writer.writeLong(offsets[10], object.vipExpireTime);
  writer.writeLong(offsets[11], object.vipLevelInt);
}

UserInfoExtend _userInfoExtendDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserInfoExtend();
  object.circleGuarantee = reader.readBool(offsets[0]);
  object.isCircleSound = reader.readBool(offsets[1]);
  object.registerIp = reader.readStringOrNull(offsets[2]);
  object.registerReferer = reader.readStringOrNull(offsets[3]);
  object.reliable = reader.readLong(offsets[4]);
  object.userNumber = reader.readString(offsets[5]);
  object.userNumberEffectiveTime = reader.readLong(offsets[6]);
  object.userNumberTypeInt = reader.readLong(offsets[7]);
  object.vipBadgeInt = reader.readLong(offsets[8]);
  object.vipExperience = reader.readLongOrNull(offsets[9]);
  object.vipExpireTime = reader.readLongOrNull(offsets[10]);
  object.vipLevelInt = reader.readLong(offsets[11]);
  return object;
}

P _userInfoExtendDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension UserInfoExtendQueryFilter
    on QueryBuilder<UserInfoExtend, UserInfoExtend, QFilterCondition> {
  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      circleGuaranteeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'circleGuarantee',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      isCircleSoundEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCircleSound',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'registerIp',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'registerIp',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'registerIp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'registerIp',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'registerIp',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerIp',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerIpIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'registerIp',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'registerReferer',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'registerReferer',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'registerReferer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'registerReferer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'registerReferer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'registerReferer',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      registerRefererIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'registerReferer',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      reliableEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reliable',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      reliableGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reliable',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      reliableLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reliable',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      reliableBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reliable',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEffectiveTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNumberEffectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEffectiveTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNumberEffectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEffectiveTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNumberEffectiveTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberEffectiveTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNumberEffectiveTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberTypeIntEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNumberTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberTypeIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNumberTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberTypeIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNumberTypeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      userNumberTypeIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNumberTypeInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipBadgeIntEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vipBadgeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipBadgeIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vipBadgeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipBadgeIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vipBadgeInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipBadgeIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vipBadgeInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vipExperience',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vipExperience',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vipExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vipExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vipExperience',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExperienceBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vipExperience',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'vipExpireTime',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'vipExpireTime',
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vipExpireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vipExpireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vipExpireTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipExpireTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vipExpireTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipLevelIntEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vipLevelInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipLevelIntGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vipLevelInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipLevelIntLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vipLevelInt',
        value: value,
      ));
    });
  }

  QueryBuilder<UserInfoExtend, UserInfoExtend, QAfterFilterCondition>
      vipLevelIntBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vipLevelInt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UserInfoExtendQueryObject
    on QueryBuilder<UserInfoExtend, UserInfoExtend, QFilterCondition> {}
