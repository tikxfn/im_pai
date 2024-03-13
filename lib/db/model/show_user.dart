import 'package:unionchat/common/func.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';
part 'show_user.g.dart';

@embedded
class ShowUser {
  // 用户Id
  int? userId;
  // 账号
  String? account;
  // 头像
  String? avatar;
  // 昵称
  String? nickname;
  // 邮箱
  String? email;
  // 手机号
  String? phone;
  // VIP到期时间
  int? vipExpireTime;
  // vip等级
  int get vipLevelInt => GVipLevel.values.indexOf(
        vipLevel ?? GVipLevel.NIL,
      );
  set vipLevelInt(int index) {
    if (index < 0 || index >= GVipLevel.values.length) {
      index = 0;
    }
    vipLevel = GVipLevel.values[index];
  }

  @ignore
  GVipLevel? vipLevel;
  // 展示名称
  int get showNameInt => GShowNameType.values.indexOf(
        showName ?? GShowNameType.NIL,
      );
  set showNameInt(int index) {
    if (index < 0 || index >= GShowNameType.values.length) {
      index = 0;
    }
    showName = GShowNameType.values[index];
  }

  @ignore
  GShowNameType? showName;
  // vip徽章
  int get vipBadgeInt => GBadge.values.indexOf(
        vipBadge ?? GBadge.NIL,
      );
  set vipBadgeInt(int index) {
    if (index < 0 || index >= GBadge.values.length) {
      index = 0;
    }
    vipBadge = GBadge.values[index];
  }

  @ignore
  GBadge? vipBadge;
  // 靠谱值
  int? reliable;
  // 担保圈子
  bool get circleGuaranteeBool => circleGuarantee == GSure.YES;

  set circleGuaranteeBool(bool value) {
    circleGuarantee = value ? GSure.YES : GSure.NO;
  }

  @ignore
  GSure? circleGuarantee;
  // 靓号
  String? userNumber;
  // 靓号类型

  int get userNumberTypeInt => GUserNumberType.values.indexOf(
        userNumberType ?? GUserNumberType.NIL,
      );
  set userNumberTypeInt(int index) {
    if (index < 0 || index >= GUserNumberType.values.length) {
      index = 0;
    }
    userNumberType = GUserNumberType.values[index];
  }

  @ignore
  GUserNumberType? userNumberType;
  // 靓号有效期
  int? userNumberEffectiveTime;
  // 好友备注
  String? mark;

  // 用户在房间中的昵称
  String? roomNickname;

  bool? useChangeNicknameCard;

  int get customerTypeInt => GCustomerType.values.indexOf(
        customerType ?? GCustomerType.NONE,
      );
  set customerTypeInt(int index) {
    if (index < 0 || index >= GCustomerType.values.length) {
      index = 0;
    }
    customerType = GCustomerType.values[index];
  }

  @ignore
  GCustomerType? customerType;

  ShowUser();

  ShowUser.fromModel(GShowUserModel? m) {
    if (m == null) return;
    userId = toInt(m.userId);
    account = m.account;
    avatar = m.avatar;
    nickname = m.nickname;
    email = m.email;
    phone = m.phone;
    vipExpireTime = toInt(m.vipExpireTime);
    vipLevel = m.vipLevel;
    showName = m.showName;
    vipBadge = m.vipBadge;
    reliable = toInt(m.reliable);
    circleGuarantee = m.circleGuarantee;
    userNumber = m.userNumber;
    userNumberType = m.userNumberType;
    userNumberEffectiveTime = toInt(m.userNumberEffectiveTime);
    mark = m.mark;
    useChangeNicknameCard = toBool(m.useChangeNicknameCard);
    roomNickname = m.roomNickname;
    customerType = m.customerType;
  }
}
