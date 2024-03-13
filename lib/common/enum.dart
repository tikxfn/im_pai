import 'package:easy_localization/easy_localization.dart';
import 'package:unionchat/common/func.dart';
import 'package:openapi/api.dart';

import '../global.dart';

class Bitmask {
  final int value;

  const Bitmask(this.value);

  Bitmask operator |(Bitmask other) {
    return Bitmask(value | other.value);
  }

  Bitmask operator ^(Bitmask other) {
    return Bitmask(value ^ other.value);
  }

  Bitmask operator &(Bitmask other) {
    return Bitmask(value & other.value);
  }

  bool contains(Bitmask other) {
    return (this & other) == other;
  }

  Bitmask remove(Bitmask other) {
    return Bitmask(value & ~other.value);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bitmask && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value.toString();
  }
}

//加载状态
enum LoadStatus {
  nil,
  loading,
  more,
  failed,
  no,
}

extension LoadStateExtension on LoadStatus {
  String get toChar {
    switch (this) {
      case LoadStatus.loading:
        return '数据加载中'.tr();
      case LoadStatus.more:
        return '松开加载'.tr();
      case LoadStatus.no:
        return '没有更多了'.tr();
      case LoadStatus.nil:
        return '';
      case LoadStatus.failed:
        return '加载失败'.tr();
    }
  }
}

//uuid类型
enum UuidType {
  nil,
  message,
  signaler,
}

extension UuidTypeExtension on UuidType {
  String get name => toString().split('.').last;

  static UuidType fromString(String name) {
    return UuidType.values.firstWhere((e) => e.name == name);
  }
}

//用户权限
class UserPowerType extends Bitmask {
  const UserPowerType(int value) : super(value);

  //加好友权限
  static const UserPowerType addFriend = UserPowerType(1 << 0);

  //陌生人对话权限
  static const UserPowerType talk = UserPowerType(1 << 1);

  //建群权限
  static const UserPowerType group = UserPowerType(1 << 2);

  //编辑消息
  static const UserPowerType edit = UserPowerType(1 << 3);

  //撤回消息
  static const UserPowerType undo = UserPowerType(1 << 4);

  bool get hasPower {
    return Bitmask(toInt(Global.user?.privilege)).contains(this);
  }
}

// 用户权限
class UserPrivacy extends Bitmask {
  const UserPrivacy(int value) : super(value);

  // 陌生人对话权限
  static const UserPrivacy strangerConversation = UserPrivacy(1 << 0);
  // 好友邀请进群
  static const UserPrivacy friendInviteRoom = UserPrivacy(1 << 1);
  // 陌生人邀请进群
  static const UserPrivacy strangerInviteRoom = UserPrivacy(1 << 2);
  // 好友通话
  static const UserPrivacy friendCall = UserPrivacy(1 << 3);
  // 陌生人通话
  static const UserPrivacy strangerCall = UserPrivacy(1 << 4);
  // 可被二维码添加
  static const UserPrivacy friendFromQr = UserPrivacy(1 << 5);
  // 可被手机号添加
  static const UserPrivacy friendFromPhone = UserPrivacy(1 << 6);
  // 可被名片添加
  static const UserPrivacy friendFromRecommend = UserPrivacy(1 << 7);
  // 可被群中添加
  static const UserPrivacy friendFromRoom = UserPrivacy(1 << 8);
  // 可被靓号添加
  static const UserPrivacy friendFromNumber = UserPrivacy(1 << 9);
  // 可被账号添加
  static const UserPrivacy friendFromAccount = UserPrivacy(1 << 10);
  // 陌生人发送消息
  static const UserPrivacy strangerMessage = UserPrivacy(1 << 11);

  bool get hasPower {
    return Bitmask(toInt(Global.user?.privacy)).contains(this);
  }
}

//用户类型
enum UserType {
  nil,
  //系统号
  system,
  //客服号
  customer,
}

extension UserTypeExt on UserType {
  //后台类型转换
  static UserType formMerchantType(GCustomerType? customerType) {
    switch (customerType) {
      case GCustomerType.NONE:
        return UserType.nil;
      case GCustomerType.MERCHANT:
        return UserType.customer;
      case GCustomerType.SYSTEM:
        return UserType.system;
    }
    return UserType.nil;
  }
}

//自毁时间
enum DestroyTime {
  off,
  // todo:自毁时间测试
  // fiveSecond,
  oneDay,
  twoDay,
  threeDay,
  fourDay,
  fiveDay,
  sixDay,
  oneWeek,
  twoWeek,
  threeWeek,
  oneMonth,
  threeMonth,
  sixMonth,
  oneYear,
}

extension DestroyTimeExt on DestroyTime {
  String get toChar {
    switch (this) {
      case DestroyTime.off:
        return '关闭'.tr();
      // case DestroyTime.fiveSecond:
      //   return '5秒'.tr();
      case DestroyTime.oneDay:
        return '1天'.tr();
      case DestroyTime.twoDay:
        return '2天'.tr();
      case DestroyTime.threeDay:
        return '3天'.tr();
      case DestroyTime.fourDay:
        return '4天'.tr();
      case DestroyTime.fiveDay:
        return '5天'.tr();
      case DestroyTime.sixDay:
        return '6天'.tr();
      case DestroyTime.oneWeek:
        return '1周'.tr();
      case DestroyTime.twoWeek:
        return '2周'.tr();
      case DestroyTime.threeWeek:
        return '3周'.tr();
      case DestroyTime.oneMonth:
        return '1个月'.tr();
      case DestroyTime.threeMonth:
        return '3个月'.tr();
      case DestroyTime.sixMonth:
        return '6个月'.tr();
      case DestroyTime.oneYear:
        return '1年'.tr();
    }
  }

  int get toSecond {
    var hour = 3600;
    var day = hour * 24;
    var week = day * 7;
    var month = day * 30;
    switch (this) {
      case DestroyTime.off:
        return 0;
      // case DestroyTime.fiveSecond:
      //   return 5;
      case DestroyTime.oneDay:
        return day;
      case DestroyTime.twoDay:
        return day * 2;
      case DestroyTime.threeDay:
        return day * 3;
      case DestroyTime.fourDay:
        return day * 4;
      case DestroyTime.fiveDay:
        return day * 5;
      case DestroyTime.sixDay:
        return day * 6;
      case DestroyTime.oneWeek:
        return week;
      case DestroyTime.twoWeek:
        return week * 2;
      case DestroyTime.threeWeek:
        return week * 3;
      case DestroyTime.oneMonth:
        return month;
      case DestroyTime.threeMonth:
        return month * 3;
      case DestroyTime.sixMonth:
        return month * 6;
      case DestroyTime.oneYear:
        return day * 365;
    }
  }

  static DestroyTime? fromSecond(int second) {
    for (var v in DestroyTime.values) {
      if (v.toSecond == second) return v;
    }
    return null;
  }
}
