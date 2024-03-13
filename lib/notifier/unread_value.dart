import 'package:flutter/cupertino.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';

class UnreadValue {
  // 圈子未读
  static final ValueNotifier<CircleNotRead> circleNotRead =
      ValueNotifier(CircleNotRead());

  //  查询别人入圈需要我审核未读数量
  static final ValueNotifier<CircleApplyNotRead> circleApplyNotRead =
      ValueNotifier(CircleApplyNotRead());

  // 查询别人入圈需要我审核未读数量
  static Future<void> queryWaitApplyCircleNotRead() async {
    if (Global.token == null) return;
    var api = CircleApi(apiClient(tip: false));
    try {
      var res = await api.circleUnreadCountApplyVerify({});
      logger.i(res);
      var notRead = CircleApplyNotRead();
      if (res != null) {
        notRead.applicationNotRead =
            toInt(res.createCount) + toInt(res.joinCount);
        notRead.applicationJoinNotRead = toInt(res.joinCount); //我加入的圈子需要审核的未读
        notRead.applicationCreateNotRead =
            toInt(res.createCount); //我管理的圈子需要审核的未读
        circleApplyNotRead.value = notRead; //需要审核的未读总数
      } else {
        notRead.applicationNotRead = 0; //需要审核的未读总数
        notRead.applicationJoinNotRead = 0; //我加入的圈子需要审核的未读
        notRead.applicationCreateNotRead = 0; //我管理的圈子需要审核的未读
        circleApplyNotRead.value = notRead;
      }
    } on ApiException catch (e) {
      onError(e, errTip: false);
    }
  }

  // 圈子我的申请状态未读数量
  static final ValueNotifier<int> circleMyApplyNotRead = ValueNotifier(0);

  // 好友申请未读数量
  static final ValueNotifier<int> friendNotRead = ValueNotifier(0);

  // 我管理的群聊申请未读数量
  static final ValueNotifier<GroupApplyNotRead> groupApplyNotRead =
      ValueNotifier(GroupApplyNotRead());

  // 查询我管理的群聊申请未读数量
  static Future<void> queryGroupApplyNotRead() async {
    if (Global.token == null) return;
    var api = RoomApi(apiClient(tip: false));
    try {
      var res = await api.roomUnreadCountRoomApplyVerify({});
      // logger.d('群聊申请$res');
      var notRead = GroupApplyNotRead();
      if (res != null) {
        notRead.groupApplyNotRead =
            toInt(res.createCount) + toInt(res.joinCount);
        notRead.groupMyJoinApplyNotRead = toInt(res.joinCount); //我管理的群组需要审核的未读
        notRead.groupMyCreateApplyNotRead =
            toInt(res.createCount); //我创建的群组需要审核的未读
        groupApplyNotRead.value = notRead; //需要审核的未读总数
      } else {
        notRead.groupApplyNotRead = 0; //需要审核的未读总数
        notRead.groupMyJoinApplyNotRead = 0; //我加入的圈子需要审核的未读
        notRead.groupMyCreateApplyNotRead = 0; //我管理的圈子需要审核的未读
        groupApplyNotRead.value = notRead;
      }
    } on ApiException catch (e) {
      onError(e, errTip: false);
    }
  }

  // 群聊我的申请状态未读数量
  static final ValueNotifier<int> groupMyApplyNotRead = ValueNotifier(0);

  // 朋友圈新动态未读
  static final ValueNotifier<int> newTrendsNotRead = ValueNotifier(0);

  // 朋友圈评论未读数
  static final ValueNotifier<int> communityNotRead = ValueNotifier(0);

  // 公告未读数量
  static final ValueNotifier<int> noticeNotRead = ValueNotifier(0);

  // 获取未读公告数量
  static Future<void> refreshNoticeCount() async {
    try {
      var api = NoticeApi(apiClient());
      var res = await api.noticeGetUnReadNumber({});
      noticeNotRead.value = toInt(res?.number);
      if (noticeNotRead.value > 0) {
        FlutterRingtonePlayer.playNotification();
      }
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // 最新公告
  static final ValueNotifier<GNoticeModel?> notice = ValueNotifier(null);

  // 获取最新公告
  static Future<void> refreshNotice() async {
    try {
      var api = NoticeApi(apiClient());
      notice.value = await api.noticeNewest({});
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // 推送新公告
  static takeNewNotice() {
    refreshNoticeCount();
    refreshNotice();
  }
}

// 圈子未读
class CircleNotRead {
  //发现圈子动态未读数量
  int circleTrendsNotRead;

  //发现圈子我创建的动态未读数量
  int circleMyCreateTrendsNotRead;

  //发现圈子我加入的动态未读数量
  int circleMyJoinTrendsNotRead;

  CircleNotRead({
    this.circleTrendsNotRead = 0,
    this.circleMyCreateTrendsNotRead = 0,
    this.circleMyJoinTrendsNotRead = 0,
  });
}

// 圈子审核未读
class CircleApplyNotRead {
  // 查询发现入圈子待审核未读总数量
  int applicationNotRead;

  // 查询发现入我加入的圈子待审核未读数量
  int applicationJoinNotRead;

  // 查询发现入我创建的圈子待审核未读数量
  int applicationCreateNotRead;

  CircleApplyNotRead({
    this.applicationNotRead = 0,
    this.applicationJoinNotRead = 0,
    this.applicationCreateNotRead = 0,
  });
}

// 我的群组待审核未读
class GroupApplyNotRead {
  //群组待审核总未读数量
  int groupApplyNotRead;

  //群组待审核我创建的动态未读数量
  int groupMyCreateApplyNotRead;

  //群组待审核我加入的动态未读数量
  int groupMyJoinApplyNotRead;

  GroupApplyNotRead({
    this.groupApplyNotRead = 0,
    this.groupMyCreateApplyNotRead = 0,
    this.groupMyJoinApplyNotRead = 0,
  });
}
