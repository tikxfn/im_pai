import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/help/circle/circle_invite.dart';
import 'package:unionchat/pages/help/circle/circle_kick_out.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar_name.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleMembers extends StatefulWidget {
  const CircleMembers({super.key});

  static const String path = 'circle/members';

  @override
  State<StatefulWidget> createState() {
    return _CircleMembersState();
  }
}

class _CircleMembersState extends State<CircleMembers> {
  String keywords = '';
  String circleId = ''; //群id
  String userId = ''; //所属者用户id
  double size = 50; //头像大小
  int limit = 50;
  static List<GCircleJoinModel> userList = [];
  bool isAdmin = false; //是否拥有管理员权限
  GCircleModel? _detail;

  //圈子邀请需要邀请人的个数
  String needInviteNum = '0';

  //获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    //获取圈子信息
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      _detail = res;
      needInviteNum = res.inviteUser ?? '0';

      if (res.role == GRole.ADMIN || res.role == GRole.LEADER) isAdmin = true;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e, errTip: false);
    } finally {}
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListMember(V1ListMemberCircleArgs(
        keywords: keywords,
        circleId: circleId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : userList.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<GCircleJoinModel> l = res?.list.toList() ?? [];
      setState(() {
        if (init) {
          userList = l;
        } else {
          userList.addAll(l);
        }
      });
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  //发送邀请
  invite() {
    if (isAdmin) {
      Navigator.pushNamed(context, CircleInvite.path, arguments: {
        'circleId': circleId,
      }).then((value) {
        _getList(init: true);
      });
    } else {
      if (toInt(needInviteNum) > 0) tip('当前圈子设置了邀请人数条件，所以只能向单个好友发送邀请');
      String content =
          '[邀请信息]收到的入群邀请，加入我们吧'.tr(args: [Global.user!.nickname ?? '']);
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            var msg = Message()
              ..senderUser = getSenderUser()
              ..type = GMessageType.FORWARD_CIRCLE
              ..contentId = toInt(circleId)
              ..content = _detail?.name
              ..fileUrl = _detail?.image
              ..location = (Global.user?.id ?? '').isNotEmpty
                  ? Global.user!.id!
                  : ''; //分享人id
            return ShareHome(
              shareText: content,
              list: [msg],
              isCircleShare: toInt(needInviteNum) > 0,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('圈子成员'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SearchInput(
                      onChanged: (str) {
                        setState(() {
                          keywords = str;
                          if (keywords == '') {
                            _getList(init: true);
                          }
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _getList(init: true);
                    },
                    child: Text(
                      '搜索'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: keywords != ''
                            ? myColors.primary
                            : myColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  pullBottom: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  limit: limit,
                  onInit: () async {
                    if (!mounted) return 0;
                    dynamic args = ModalRoute.of(context)!.settings.arguments;
                    if (args == null) return 0;
                    if (args['circleId'] != null) circleId = args['circleId'];
                    if (args['userId'] != null) userId = args['userId'];

                    logger.d('圈子id：$circleId');

                    getDetail();
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    RowList(
                      rowNumber: 5,
                      lineSpacing: 10,
                      spacing: 10,
                      children: [
                        for (var i = 0; i < (userList.length); i++)
                          GestureDetector(
                            onTap: () {
                              if (userList[i].userId != Global.user!.id!) {
                                Navigator.pushNamed(context, FriendDetails.path,
                                    arguments: {'id': userList[i].userId});
                              }
                            },
                            child: AvatarName(
                              avatars: [userList[i].avatar ?? ''],
                              name: userList[i].nickname ?? '',
                              userName: userList[i].nickname ?? '',
                              userId: userList[i].userId ?? '',
                              size: size,
                              nameColor: textColor,
                            ),
                          ),
                        //邀请进群
                        CircularButton(
                          onTap: invite,
                          title: '邀请'.tr(),
                          size: size,
                          nameColor: textColor,
                          child: Icon(
                            Icons.add,
                            color: myColors.lineGrey,
                          ),
                        ),

                        //踢出群聊
                        CircularButton(
                          onTap: () {
                            Navigator.pushNamed(context, CircleKickOut.path,
                                arguments: {
                                  'circleId': circleId,
                                  'userId': userId,
                                }).then((value) {
                              _getList(init: true);
                            });
                          },
                          title: '移除'.tr(),
                          size: size,
                          nameColor: textColor,
                          child: Icon(
                            Icons.remove,
                            color: myColors.lineGrey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
