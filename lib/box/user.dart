part of 'box.dart';

class LoginUser {
  final int id;
  final String account;
  final bool userVip;
  final GVipLevel userVipLevel;
  final bool userGoodNumber;
  final bool userOnlyName;
  final bool enablePin;
  final bool isPin;
  final GUserModel user;

  LoginUser(
    this.user, {
    required this.id,
    required this.account,
    required this.userVip,
    required this.userVipLevel,
    required this.userGoodNumber,
    required this.userOnlyName,
    this.enablePin = false,
    this.isPin = false,
  });

  factory LoginUser.fromModel(GUserModel user) {
    final userVip =
        toInt(user.userExtend?.vipExpireTime) >= toInt(date2time(null));
    final userVipLevel = user.userExtend?.vipLevel ?? GVipLevel.NIL;
    final userGoodNumber = (user.userNumber ?? '').isNotEmpty;
    final userOnlyName = toBool(user.useChangeNicknameCard);
    final account = user.platform == GAuthPlatform.REGISTER_BY_TOURIST
        ? '-'
        : (user.account ?? '-');

    return LoginUser(
      user,
      id: toInt(user.id),
      account: account,
      userVip: userVip,
      userVipLevel: userVipLevel,
      userGoodNumber: userGoodNumber,
      userOnlyName: userOnlyName,
      enablePin: user.enablePin == GSure.YES,
      isPin: user.isPin == GSure.YES,
    );
  }
}

class UserAdapter extends TypeAdapter<GUserModel> {
  static const activeKey = 'active_user';

  @override
  GUserModel read(BinaryReader reader) {
    return GUserModel.fromJson(jsonDecode(reader.read())) ?? GUserModel();
  }

  @override
  int get typeId => 0;

  @override
  void write(BinaryWriter writer, GUserModel obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}
