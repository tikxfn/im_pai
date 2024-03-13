import 'package:flutter/material.dart';
import 'package:unionchat/pages/chat/chat_management/group_log.dart';
import 'package:unionchat/pages/help/circle/circle_apply_manage.dart';
import 'package:unionchat/pages/help/circle/circle_card.dart';
import 'package:unionchat/pages/help/circle/circle_invite.dart';
import 'package:unionchat/pages/help/circle/circle_kick_out.dart';
import 'package:unionchat/pages/help/circle/circle_log.dart';
import 'package:unionchat/pages/help/circle/circle_manage.dart';
import 'package:unionchat/pages/help/circle/circle_members.dart';
import 'package:unionchat/pages/help/circle/circle_more.dart';
import 'package:unionchat/pages/help/circle/circle_my_trends.dart';
import 'package:unionchat/pages/help/circle/circle_set_manage.dart';
import 'package:unionchat/pages/help/circle/circle_set_manage_update.dart';
import 'package:unionchat/pages/help/circle/circle_update.dart';
import 'package:unionchat/pages/help/circle/my/circle_my_all.dart';
import 'package:unionchat/pages/help/circle/my/circle_my_apply.dart';
import 'package:unionchat/pages/help/circle_my_select.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/pages/help/help_create.dart';
import 'package:unionchat/pages/help/help_detail.dart';
import 'package:unionchat/pages/help/help_home.dart';
import 'package:unionchat/pages/help/help_home_select.dart';
import 'package:unionchat/pages/help/province_my_select.dart';
import 'package:unionchat/pages/notice/notice_detail.dart';
import 'package:unionchat/pages/notice/notice_list.dart';

import 'circle/circle_create.dart';
import 'circle/circle_my.dart';

class HelpRoutes {
  static Map<String, Widget Function(BuildContext)> routes(GlobalKey? key) {
    Map<String, Widget Function(BuildContext)> routes = {
      HelpHome.path: (context) => HelpHome(key: key),
      HelpHomeSelect.path: (context) => HelpHomeSelect(key: key),
      CircleMore.path: (context) => CircleMore(key: key),
      HelpDetail.path: (context) => HelpDetail(key: key),
      HelpCreate.path: (context) => HelpCreate(key: key),
      GroupHome.path: (context) => GroupHome(key: key),
      NoticeDetail.path: (context) => NoticeDetail(key: key),
      NoticeList.path: (context) => NoticeList(key: key),
      CircleCreate.path: (context) => CircleCreate(key: key),
      CircleMy.path: (context) => CircleMy(key: key),
      CircleManage.path: (context) => CircleManage(key: key),
      CircleUpdate.path: (context) => CircleUpdate(key: key),
      CircleApplyManage.path: (context) => CircleApplyManage(key: key),
      CircleMyTrends.path: (context) => CircleMyTrends(key: key),
      CircleMyApply.path: (context) => CircleMyApply(key: key),
      CircleKickOut.path: (context) => CircleKickOut(key: key),
      CircleMembers.path: (context) => CircleMembers(key: key),
      CircleMyAll.path: (context) => CircleMyAll(key: key),
      CircleCard.path: (context) => CircleCard(key: key),
      CircleMySelect.path: (context) => CircleMySelect(key: key),
      ProvinceSelect.path: (context) => ProvinceSelect(key: key),
      CircleSetManage.path: (context) => CircleSetManage(key: key),
      CircleSetManageUpdate.path: (context) => CircleSetManageUpdate(key: key),
      CircleInvite.path: (context) => CircleInvite(key: key),
      GroupLog.path: (context) => GroupLog(key: key),
      CircleLog.path: (context) => CircleLog(key: key),
    };
    return routes;
  }
}
