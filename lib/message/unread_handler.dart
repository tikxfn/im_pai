import 'dart:async';

import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/unread_value.dart';

Future<void> unreadHandler(GUnreadNumber data) async {
  switch (data.type) {
    case GUnreadNumberType.CIRCLE_APPLY: //我的圈子申请状态
      UnreadValue.circleMyApplyNotRead.value = toInt(data.number);
      break;
    case GUnreadNumberType.ADMIN_CIRCLE_APPLY: //别人申请加入我管理的圈子待审核
      break;
    case GUnreadNumberType.CIRCLE_ARTICLE: //圈子未读动
      UnreadValue.circleNotRead.value =
          CircleNotRead(circleTrendsNotRead: toInt(data.number));
      if (toInt(data.number) > 0 && circleNoticeOpen) {
        messageNotice(); //圈子未读动态响铃
      }
      break;
    case GUnreadNumberType.FRIEND_APPLY: //好友申请未读
      UnreadValue.friendNotRead.value = toInt(data.number);
      break;
    case GUnreadNumberType.NIL:
      break;
    case GUnreadNumberType.ROOM_APPLY: //我的群组申请状态
      UnreadValue.groupMyApplyNotRead.value = toInt(data.number);
      logger.i(UnreadValue.groupMyApplyNotRead.value);
      break;
    case GUnreadNumberType.ADMIN_ROOM_APPLY: //别人申请加入我管理的群组待审核
      break;
    case GUnreadNumberType.USER_TRENDS: //朋友圈动态未读
      UnreadValue.newTrendsNotRead.value = toInt(data.number);
      break;
    case GUnreadNumberType.USER_TRENDS_COMMENT: //朋友圈评论动态未读
      UnreadValue.communityNotRead.value = toInt(data.number);
      break;
    case GUnreadNumberType.NOTICE: //未读公告
      UnreadValue.takeNewNotice();
      break;
  }
  return;
}

//别人申请加入我管理的圈子申请状态
Future<void> circleUnreadHandler(V1AdminCircleApplyUnread data) async {
  UnreadValue.circleApplyNotRead.value = CircleApplyNotRead(
    applicationNotRead: toInt(data.total),
    applicationJoinNotRead: toInt(data.joined),
    applicationCreateNotRead: toInt(data.created),
  );
  return;
}

//别人申请加入我管理的群组申请状态
Future<void> groupUnreadHandler(V1AdminRoomApplyUnread data) async {
  UnreadValue.groupApplyNotRead.value = GroupApplyNotRead(
    groupApplyNotRead: toInt(data.total),
    groupMyJoinApplyNotRead: toInt(data.joined),
    groupMyCreateApplyNotRead: toInt(data.created),
  );
  return;
}
