import 'package:easy_localization/easy_localization.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';

part 'user_info.g.dart';

@collection
class UserInfo {
  Id id = Isar.autoIncrement;

  // 账号
  @Index()
  String account = '';

  // 头像
  String? avatar;

  // 生日
  int? birthday;

  // 消息自毁时间
  int? chatDestroyDuration;

  // 城市
  String? city;

  // 共同圈子
  int commonCircle = 0;

  // 共同好友
  int commonFriend = 0;

  // 共同群聊
  int commonRoom = 0;

  // 注册时间
  int? createTime;

  // 账号类型
  @Index()
  int get customerTypeInt => GCustomerType.values.indexOf(
        customerType ?? GCustomerType.NONE,
      );

  set customerTypeInt(int index) {
    if (index < 0 || index >= GCustomerType.values.length) {
      index = 0;
    }
    customerType = GCustomerType.values[index];
  }

  // 账号类型
  @ignore
  GCustomerType? customerType;

  // 封禁原因
  String? disableReason;

  // 封禁时间
  int? disableTime;

  // 邮箱
  String? email;

  // 是否开启锁定吗
  bool enablePin = false;

  // 积分
  int integral = 0;

  // ip
  String? ip;

  // 是否更换过账号
  bool isChangeAccount = false;

  // 是否绑定手机号
  bool isHavePhone = false;

  // 是否设置锁定码
  bool isPin = false;

  // 是否设置密码
  bool isSetPassword = false;

  // 最后登录时间
  int? lastOnlineTime;

  // 推荐人id
  int? leftUserId;

  // 等级
  int level = 0;

  // 备注
  String? mark;

  // 昵称拼音
  String? nickPingyin;

  // 昵称
  String? nickname;

  // 密码
  String? password;

  // 手机号
  String? phone;

  // 权限
  int privacy = 0;

  // 特权
  int privilege = 0;

  // 性别
  @Index()
  int get sexInt => GSex.values.indexOf(sex);

  set sexInt(int index) {
    if (index < 0 || index >= GSex.values.length) {
      index = 0;
    }
    sex = GSex.values[index];
  }

  // 性别
  @ignore
  GSex sex = GSex.UNKNOWN;

  // 个性签名
  String? slogan;

  // 账号状态
  @Index()
  int get statusInt => GUserStatus.values.indexOf(status);

  set statusInt(int index) {
    if (index < 0 || index >= GUserStatus.values.length) {
      index = 0;
    }
    status = GUserStatus.values[index];
  }

  @ignore
  // 账号状态
  GUserStatus status = GUserStatus.NORMAL;

  // 朋友圈背景图
  String? trendsBackground;

  // 是否使用唯名卡
  bool useChangeNicknameCard = false;

  // 扩展信息
  UserInfoExtend? userExtend;

  UserInfo();

  ChatItemData toChatItem() {
    var userNumber = userExtend?.userNumber ?? '';
    var data = ChatItemData(
      icons: [avatar ?? ''],
      title: nickname ?? '',
      mark: mark ?? '',
      id: id.toString(),
      userNumber: userNumber,
      account: account,
      phone: phone ?? '',
      goodNumber: userNumber.isNotEmpty,
      numberType: userExtend?.userNumberType ?? GUserNumberType.NIL,
      circleGuarantee: userExtend?.circleGuarantee ?? false,
      onlyName: useChangeNicknameCard,
      vip: (userExtend?.vipExpireTime ?? 0) >= toInt(date2time(null)),
      vipLevel: userExtend?.vipLevel ?? GVipLevel.NIL,
      vipBadge: userExtend?.vipBadge ?? GBadge.NIL,
      text: time2onlineDate(
        (lastOnlineTime ?? '').toString(),
        zeroStr: '在线'.tr(),
      ),
      lastOnlineTime: lastOnlineTime,
      userType: UserTypeExt.formMerchantType(customerType),
      origin: toGUserModel(),
    );
    return data;
  }

  GUserModel toGUserModel() {
    return GUserModel(
      id: id.toString(),
      account: account,
      nickname: nickname,
      mark: mark,
      avatar: avatar,
      phone: phone,
      birthday: (birthday ?? '').toString(),
      chatDestroyDuration: (chatDestroyDuration ?? '').toString(),
      city: city,
      commonCircle: (commonCircle).toString(),
      commonFriend: (commonFriend).toString(),
      commonRoom: (commonRoom).toString(),
      createTime: (createTime ?? '').toString(),
      customerType: customerType,
      disableReason: disableReason,
      disableTime: (disableTime ?? '').toString(),
      email: email,
      enablePin: toSure(enablePin),
      integral: (integral).toString(),
      ip: ip,
      isChangeAccount: toSure(isChangeAccount),
      isHavePhone: isHavePhone,
      isPin: toSure(isPin),
      isSetPassword: isSetPassword,
      lastOnlineTime: (lastOnlineTime ?? '').toString(),
      leftUserId: (leftUserId ?? '').toString(),
      level: (level).toString(),
      nickPingyin: nickPingyin,
      password: password,
      privacy: (privacy).toString(),
      privilege: (privilege).toString(),
      sex: sex,
      slogan: slogan,
      trendsBackground: trendsBackground,
      useChangeNicknameCard: toSure(useChangeNicknameCard),
      userExtend: userExtend == null ? null : userExtend!.toGUserExtendModel(),
    );
  }

  UserInfo.fromModel(GUserModel model) {
    id = toInt(model.id);
    account = model.account ?? '';
    avatar = model.avatar;
    birthday = toInt(model.birthday);
    chatDestroyDuration = toInt(model.chatDestroyDuration);
    city = model.city;
    commonCircle = toInt(model.commonCircle);
    commonFriend = toInt(model.commonFriend);
    commonRoom = toInt(model.commonRoom);
    createTime = toInt(model.createTime);
    customerType = model.customerType;
    disableReason = model.disableReason;
    disableTime = toInt(model.disableTime);
    email = model.email;
    enablePin = toBool(model.enablePin);
    integral = toInt(model.integral);
    ip = model.ip;
    isChangeAccount = toBool(model.isChangeAccount);
    isHavePhone = model.isHavePhone ?? false;
    isPin = toBool(model.isPin);
    isSetPassword = model.isSetPassword ?? false;
    lastOnlineTime = toInt(model.lastOnlineTime);
    leftUserId = toInt(model.leftUserId);
    level = toInt(model.level);
    mark = model.mark;
    nickPingyin = model.nickPingyin;
    nickname = model.nickname;
    password = model.password;
    phone = model.phone;
    privacy = toInt(model.privacy);
    privilege = toInt(model.privilege);
    sex = model.sex ?? GSex.UNKNOWN;
    slogan = model.slogan;
    status = model.status ?? GUserStatus.NORMAL;
    trendsBackground = model.trendsBackground;
    useChangeNicknameCard = toBool(model.useChangeNicknameCard);
    userExtend = model.userExtend != null
        ? UserInfoExtend.fromModel(model.userExtend!)
        : null;
  }
}

@embedded
class UserInfoExtend {
  // 是否加入保圈
  bool circleGuarantee = false;

  // 是否打开圈子提醒
  bool isCircleSound = false;

  // 注册ip
  String? registerIp;

  // 推荐人
  String? registerReferer;

  // 靠谱值
  int reliable = 0;

  // 靓号
  String userNumber = '';

  // 靓号过期时间
  int userNumberEffectiveTime = 0;

  // 靓号类型
  int get userNumberTypeInt =>
      GUserNumberType.values.indexOf(userNumberType ?? GUserNumberType.NIL);

  set userNumberTypeInt(int index) {
    if (index < 0 || index >= GUserNumberType.values.length) {
      index = 0;
    }
    userNumberType = GUserNumberType.values[index];
  }

  @ignore
  // 靓号类型
  GUserNumberType? userNumberType;

  // vip类型
  int get vipBadgeInt => GBadge.values.indexOf(vipBadge ?? GBadge.NIL);

  set vipBadgeInt(int index) {
    if (index < 0 || index >= GBadge.values.length) {
      index = 0;
    }
    vipBadge = GBadge.values[index];
  }

  @ignore
  // vip类型
  GBadge? vipBadge;

  // vip成长值
  int? vipExperience;

  // vip过期时间
  int? vipExpireTime;

  // vip类型
  int get vipLevelInt => GVipLevel.values.indexOf(vipLevel ?? GVipLevel.NIL);

  set vipLevelInt(int index) {
    if (index < 0 || index >= GVipLevel.values.length) {
      index = 0;
    }
    vipLevel = GVipLevel.values[index];
  }

  @ignore
  // vip等级
  GVipLevel? vipLevel;

  UserInfoExtend();

  GUserExtendModel toGUserExtendModel() {
    return GUserExtendModel(
      circleGuarantee: toSure(circleGuarantee),
      isCircleSound: toSure(isCircleSound),
      registerIp: registerIp,
      registerReferer: registerReferer,
      reliable: (reliable).toString(),
      userNumber: userNumber,
      userNumberEffectiveTime: (userNumberEffectiveTime).toString(),
      userNumberType: userNumberType,
      vipBadge: vipBadge,
      vipExperience: (vipExperience ?? '').toString(),
      vipExpireTime: (vipExpireTime ?? '').toString(),
      vipLevel: vipLevel,
    );
  }

  UserInfoExtend.fromModel(GUserExtendModel model) {
    circleGuarantee = toBool(model.circleGuarantee);
    isCircleSound = toBool(model.isCircleSound);
    registerIp = model.registerIp;
    registerReferer = model.registerReferer;
    reliable = toInt(model.reliable);
    userNumber = model.userNumber ?? '';
    userNumberEffectiveTime = toInt(model.userNumberEffectiveTime);
    userNumberType = model.userNumberType;
    vipBadge = model.vipBadge;
    vipExperience = toInt(model.vipExperience);
    vipExpireTime = toInt(model.vipExpireTime);
    vipLevel = model.vipLevel;
  }
}
