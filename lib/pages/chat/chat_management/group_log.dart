import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupLog extends StatefulWidget {
  const GroupLog({super.key});

  static const path = 'chat/chat_management/log';

  @override
  State<GroupLog> createState() => _GroupLogState();
}

class _GroupLogState extends State<GroupLog> {
  String keywords = '';
  int limit = 20;

  //群Id
  String? roomId;

  //日志列表
  List<GRoomOperateModel> list1 = [];

  //获取列表
  Future<int> getList({bool init = false}) async {
    if (roomId == '') return 0;
    // activeIds = [];
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListRoomOperate(
        V1ListRoomOperateArgs(
          keywords: keywords,
          roomId: roomId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : list1.length.toString(),
          ),
        ),
      );
      List<GRoomOperateModel> newList = res?.list.toList() ?? [];
      if (!mounted) return 0;
      if (init) {
        list1 = newList;
      } else {
        list1.addAll(newList);
      }
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('日志记录'.tr()),
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
                            getList(init: true);
                          }
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: keywords != ''
                        ? () {
                            getList(init: true);
                          }
                        : null,
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
                  limit: limit,
                  onInit: () async {
                    if (!mounted) return 0;
                    dynamic args =
                        ModalRoute.of(context)!.settings.arguments ?? {};
                    if (args['roomId'] == null) return 0;
                    roomId = args['roomId'];
                    return await getList(init: true);
                  },
                  onPullDown: () async {
                    //下拉刷新
                    return await getList(init: true);
                  },
                  onPullUp: () async {
                    //上拉加载
                    return await getList();
                  },
                  children: list1.map((e) {
                    String status = '';
                    String from = '';
                    switch (e.status) {
                      case GApplyStatus.APPLY:
                        status = '等待审核'.tr();
                        break;
                      case GApplyStatus.SUCCESS:
                        status = '已通过'.tr();
                        break;

                      case GApplyStatus.REFUSE:
                        status = '已拒绝'.tr();
                        break;
                      case GApplyStatus.NIL:
                        break;
                      case GApplyStatus.BAN:
                        break;
                    }
                    switch (e.from) {
                      case GRoomFrom.CARD:
                        from = '群卡片邀请'.tr();
                        break;
                      case GRoomFrom.ADMIN_INVITE:
                        from = '管理员邀请'.tr();
                        break;
                      case GRoomFrom.ID:
                        break;
                      case GRoomFrom.NIL:
                        break;
                      case GRoomFrom.QR:
                        from = '二维码'.tr();
                        break;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: myColors.circleBorder,
                            width: .5,
                          ),
                        ),
                      ),
                      child: ChatItem(
                        hideAvatar: true,
                        titleSize: 15,
                        avatarSize: 0,
                        onTitleTap: () {
                          Navigator.pushNamed(
                            context,
                            FriendDetails.path,
                            arguments: {
                              'id': e.userId ?? '',
                              'friendFrom': 'ROOM',
                              'roomId': roomId,
                              'removeToTabs': true,
                              'detail': GUserModel(nickname: e.nickname),
                            },
                          );
                        },
                        data: ChatItemData(
                            id: e.userId,
                            icons: [''],
                            title: e.nickname ?? '',
                            time: time2date(e.createTime)),
                        hasSlidable: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (e.roomOperateType == GRoomOperateType.JOIN)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '通过进行入群申请'.tr(args: [
                                      from != '二维码'.tr()
                                          ? '的'.tr(
                                              args: [e.inviteNickname ?? ''])
                                          : '扫描'.tr(),
                                      from
                                    ]),
                                    style: TextStyle(
                                      color: myColors.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '操作人：'
                                            .tr(args: [e.verifyNickname ?? '']),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (e.roomOperateType == GRoomOperateType.KICK)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '被移出群聊'.tr(),
                                    style: TextStyle(
                                      color: myColors.textGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '操作人：'.tr(args: ['']),
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (e.verifyUserId ==
                                                  Global.user!.id) return;
                                              Navigator.pushNamed(
                                                context,
                                                FriendDetails.path,
                                                arguments: {
                                                  'id': e.verifyUserId ?? '',
                                                  'friendFrom': 'ROOM',
                                                  'roomId': roomId,
                                                  'removeToTabs': true,
                                                  'detail': GUserModel(
                                                    nickname: e.verifyNickname,
                                                  ),
                                                },
                                              );
                                            },
                                            child: Text(
                                              e.verifyNickname ?? '',
                                              style: TextStyle(
                                                color: textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        '踢出'.tr(),
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (e.roomOperateType == GRoomOperateType.EXIT)
                              Text(
                                '退出了群聊'.tr(),
                                style: TextStyle(
                                  color: myColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
