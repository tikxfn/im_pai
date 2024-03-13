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

class CircleLog extends StatefulWidget {
  const CircleLog({super.key});

  static const path = 'help/log';

  @override
  State<CircleLog> createState() => _CircleLogState();
}

class _CircleLogState extends State<CircleLog> {
  String keywords = '';
  int limit = 20;

  //群Id
  String? circleId;

  //日志列表
  List<GCircleOperateModel> list1 = [];

  //获取列表
  Future<int> getList({bool init = false}) async {
    if (circleId == '') return 0;
    // activeIds = [];
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircleOperate(
        V1ListCircleOperateArgs(
          keywords: keywords,
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : list1.length.toString(),
          ),
        ),
      );
      if (res == null) return 0;
      List<GCircleOperateModel> newList = res.list.toList();
      if (!mounted) return 0;
      if (init) {
        list1 = newList;
      } else {
        list1.addAll(newList);
      }
      if (mounted) setState(() {});

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
                    if (args['circleId'] == null) return 0;
                    circleId = args['circleId'];
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
                      case GCircleJoinFrom.CARD:
                        from = '卡片分享'.tr();
                        break;
                      case GCircleJoinFrom.INVITE:
                        from = '邀请'.tr();
                        break;
                      case GCircleJoinFrom.NIL:
                        break;
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: myColors.lineGrey,
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
                            if (e.circleOperateType == GCircleOperateType.JOIN)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '通过的进行入圈申请'.tr(
                                        args: [e.inviteNickname ?? '', from]),
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
                                                },
                                              );
                                            },
                                            child: Text(
                                              e.verifyNickname ?? '',
                                              style: TextStyle(
                                                color: myColors.textBlack,
                                                fontSize: 14,
                                              ),
                                            ),
                                          )
                                        ],
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
                            if (e.circleOperateType == GCircleOperateType.KICK)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '被移出圈子'.tr(),
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
                            if (e.circleOperateType == GCircleOperateType.EXIT)
                              Text(
                                '退出了圈子'.tr(),
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
