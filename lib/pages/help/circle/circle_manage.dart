import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/help/circle/circle_apply_manage.dart';
import 'package:unionchat/pages/help/circle/circle_ban.dart';
import 'package:unionchat/pages/help/circle/circle_clean_user.dart';
import 'package:unionchat/pages/help/circle/circle_invite.dart';
import 'package:unionchat/pages/help/circle/circle_kick_out.dart';
import 'package:unionchat/pages/help/circle/circle_log.dart';
import 'package:unionchat/pages/help/circle/circle_members.dart';
import 'package:unionchat/pages/help/circle/circle_my.dart';
import 'package:unionchat/pages/help/circle/circle_set_manage.dart';
import 'package:unionchat/pages/help/circle/circle_transfer_leader.dart';
import 'package:unionchat/pages/help/circle/circle_update.dart';
import 'package:unionchat/pages/help/circle/usernumber_list.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar_name.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleManage extends StatefulWidget {
  const CircleManage({super.key});

  static const String path = 'circle/my_manage';

  @override
  State<StatefulWidget> createState() {
    return _CircleManageState();
  }
}

class _CircleManageState extends State<CircleManage> {
  // String userId = ''; //所属者id
  String circleId = ''; //圈子id
  String circleName = ''; //圈子名称
  GCircleModel? detail; //圈子信息
  static List<GCircleJoinModel> list = [];
  int limit = 18;
  double size = 50; //头像大小

  bool isMaster = false; //是否圈主
  static bool isAdmin = false; //是否拥有管理员权限
  String inviteNumber = '0';
  String joinVip = 'VIP1';
  String timeSpan = '0';
  List<GUserNumberType> typeList = []; //靓号等级
  List<String> inviteSelect = [
    '不限制',
    '1',
    '2',
    '3',
    '4',
    '5',
  ];
  List<String> vipSelect = [
    '不限制',
    'VIP1',
    'VIP2',
    'VIP3',
    'VIP4',
    'VIP5',
    'VIP6',
  ];
  List<String> timeSelect = [
    '不限制',
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  //获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    //获取圈子信息
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      detail = res;
      circleName = '${res.name!}(${detail?.countUser ?? ''})';
      // userId = res.userId!;
      typeList = res.joinUserNumberTypes;
      // logger.i(res.joinVipLevel);
      // logger.i(typeList);
      inviteNumber = res.inviteUser ?? '0';
      timeSpan = (toInt(res.releaseFrequency) ~/ 60).toString();
      switch (res.joinVipLevel) {
        case GVipLevel.NIL:
          joinVip = vipSelect[0];
          break;
        case GVipLevel.n1:
          joinVip = vipSelect[1];
          break;
        case GVipLevel.n2:
          joinVip = vipSelect[2];
          break;
        case GVipLevel.n3:
          joinVip = vipSelect[3];
          break;
        case GVipLevel.n4:
          joinVip = vipSelect[4];
          break;
        case GVipLevel.n5:
          joinVip = vipSelect[5];
          break;
        case GVipLevel.n6:
          joinVip = vipSelect[6];
          break;
      }

      isMaster = res.userId == Global.user!.id;
      if (res.role == GRole.ADMIN || res.role == GRole.LEADER) isAdmin = true;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e, errTip: false);
    } finally {}
  }

  //获取成员列表
  getList() async {
    final api = CircleApi(apiClient());
    //获取成员信息
    try {
      final res = await api.circleListMember(V1ListMemberCircleArgs(
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: '0',
          )));

      List<GCircleJoinModel> newList = [];
      newList = res?.list ?? [];
      list = newList;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //发送邀请
  invite() {
    if (isAdmin) {
      Navigator.pushNamed(context, CircleInvite.path, arguments: {
        'circleId': circleId,
      }).then((value) {
        getList();
      });
    } else {
      if (toInt(inviteNumber) > 0) tip('当前圈子设置了邀请人数条件，所以只能向单个好友发送邀请'.tr());
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
              ..content = detail?.name
              ..fileUrl = detail?.image
              ..location = (Global.user?.id ?? '').isNotEmpty
                  ? Global.user!.id!
                  : ''; //分享人id
            return ShareHome(
              shareText: content,
              list: [msg],
              isCircleShare: toInt(inviteNumber) > 0,
            );
          },
        ),
      );
    }
  }

  //保存入圈所需邀请人数
  setInviteNumber(String number) async {
    String n = number == '不限制' ? '0' : number;
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleUpdateCircle(V1CircleUpdateArgs(
          id: circleId,
          inviteUser: V1CircleUpdateArgsInviteUser(
            value: n,
          )));
      if (!mounted) return;
      if (mounted) {
        inviteNumber = n;
        setState(() {});
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //设置入圈所需邀请人数
  _chooseNumber() {
    var index = 0;
    openSelect(
      context,
      index: index,
      list: inviteSelect,
      onEnter: (i) async {
        await setInviteNumber(inviteSelect[i]);
      },
    );
  }

//设置入圈所需vip
  _chooseVip() {
    var index = 0;
    openSelect(
      context,
      index: index,
      list: vipSelect,
      onEnter: (i) async {
        await setJoinVipLevel(i);
      },
    );
  }

//保存入圈所需VIP等级
  setJoinVipLevel(int number) async {
    List<GVipLevel> level = [
      GVipLevel.NIL,
      GVipLevel.n1,
      GVipLevel.n2,
      GVipLevel.n3,
      GVipLevel.n4,
      GVipLevel.n5,
      GVipLevel.n6,
    ];
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleUpdateCircle(V1CircleUpdateArgs(
          id: circleId,
          joinVipLevel: CircleUpdateArgsJoinVipLevel(
            joinVipLevel: level[number],
          )));
      if (!mounted) return;
      if (mounted) {
        joinVip = vipSelect[number];
        setState(() {});
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //保存入圈所需靓号等级
  setJoinUserNumberLevel() async {
    logger.i(typeList);
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleUpdateCircle(
        V1CircleUpdateArgs(
          id: circleId,
          joinUserNumberTypes: typeList,
        ),
      );
      if (!mounted) return;
      if (mounted) {
        setState(() {});
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

//设置动态发送频率
  _chooseTime() {
    var index = 0;
    openSelect(
      context,
      index: index,
      list: timeSelect,
      onEnter: (i) async {
        await setReleaseFrequency(i);
      },
    );
  }

//保存发布动态频率
  setReleaseFrequency(int number) async {
    // logger.i(circleId);
    // logger.i((toInt(timeSelect[number]) * 60).toString());
    int time = number == 0 ? 0 : toInt(timeSelect[number]);
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleSetReleaseFrequency(
        V1SetReleaseFrequencyArgs(
          id: circleId,
          releaseFrequency: (time * 60).toString(),
        ),
      );
      if (!mounted) return;
      if (mounted) {
        timeSpan = timeSelect[number];
        setState(() {});
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //解散圈子
  delete() async {
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleDelCircle(GIdArgs(id: circleId));
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName(CircleMy.path));
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['circleId'] != null) circleId = args['circleId'];
      // logger.i('圈子id：$circleId');
      getDetail();
      getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(circleName),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            //成员信息
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  bottom: BorderSide(
                    color: myColors.tagColor,
                    width: .5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  //成员列表
                  RowList(
                    rowNumber: 5,
                    lineSpacing: 10,
                    spacing: 10,
                    children: [
                      for (var i = 0; i < list.length; i++)
                        GestureDetector(
                          onTap: () {
                            if (list[i].userId != Global.user!.id) {
                              Navigator.pushNamed(context, FriendDetails.path,
                                  arguments: {'id': list[i].userId});
                            }
                          },
                          child: AvatarName(
                            avatars: [list[i].avatar ?? ''],
                            name: list[i].nickname ?? '',
                            nameColor: textColor,
                            size: size,
                            userName: list[i].nickname ?? '',
                            userId: list[i].userId ?? '',
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
                                'userId': detail!.userId,
                              }).then((value) {
                            getList();
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
                  const SizedBox(height: 5),
                  //更多
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, CircleMembers.path,
                              arguments: {
                                'circleId': circleId,
                                'userId': detail!.userId,
                                'isAdmin': isAdmin,
                              }).then((value) {
                            getList();
                          });
                        },
                        child: Text(
                          '查看更多群成员'.tr(),
                          style: TextStyle(
                            color: myColors.textGrey,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: myColors.textGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            MenuUl(
              children: [
                MenuItemData(
                  title: '基本信息'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, CircleUpdate.path,
                        arguments: {'circleId': circleId}).then((value) {
                      getDetail();
                      setState(() {});
                    });
                  },
                ),
                MenuItemData(
                  title: '入圈所需介绍人个数'.tr(),
                  content: Text(
                    inviteNumber == '0' || inviteNumber == '不限制'
                        ? '不限制'.tr()
                        : '个'.tr(args: [inviteNumber]),
                    style: TextStyle(color: textColor),
                  ),
                  onTap: _chooseNumber,
                ),
                MenuItemData(
                  title: '入圈所需ViP等级'.tr(),
                  content: Text(
                    joinVip,
                    style: TextStyle(color: textColor),
                  ),
                  onTap: _chooseVip,
                ),
                MenuItemData(
                  title: '入圈靓号等级'.tr(),
                  content: Text(
                    typeList
                        .map((e) => goodNumberType2string(e))
                        .toList()
                        .join(','),
                    style: TextStyle(color: textColor),
                  ),
                  onTap: () async {
                    var data = await Navigator.pushNamed(
                        context, UserNumberList.path,
                        arguments: {'typeList': typeList});
                    if (data == null) return;
                    typeList = data as List<GUserNumberType>;
                    logger.i(typeList);
                    setJoinUserNumberLevel();
                  },
                ),
                MenuItemData(
                  title: '动态发布频率'.tr(),
                  content: Text(
                    timeSpan == '0' || timeSpan == '不限制'
                        ? '不限制'.tr()
                        : '分钟'.tr(args: [timeSpan]),
                    style: TextStyle(color: textColor),
                  ),
                  onTap: _chooseTime,
                ),
                MenuItemData(
                  title: '用户封禁'.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CircleBan.path,
                      arguments: {'circleId': circleId},
                    );
                  },
                ),
                MenuItemData(
                  title: '异常用户清理'.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CircleCleanUser.path,
                      arguments: {'circleId': circleId},
                    ).then((value) {
                      getList();
                    });
                  },
                ),
                MenuItemData(
                  title: '审核列表'.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CircleApplyManage.path,
                      arguments: {'circleId': circleId},
                    ).then((value) {
                      getList();
                    });
                  },
                ),
                MenuItemData(
                  title: '日志记录'.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CircleLog.path,
                      arguments: {'circleId': circleId},
                    );
                  },
                ),
                if (isMaster)
                  MenuItemData(
                    title: '管理员列表'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        CircleSetManage.path,
                        arguments: {'circleId': circleId},
                      ).then((value) {
                        getList();
                      });
                    },
                  ),
                if (isMaster)
                  MenuItemData(
                    title: '转让圈主'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, CircleTransferLeader.path,
                          arguments: {'circleId': circleId}).then((value) {
                        getDetail();
                      });
                    },
                  ),
              ],
            ),
            if (isMaster)
              AppBlockButton(
                text: '解散圈子'.tr(),
                color: myColors.red,
                onTap: () {
                  confirm(
                    context,
                    content: '是否解散此圈子？'.tr(),
                    onEnter: delete,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
