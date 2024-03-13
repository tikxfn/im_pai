import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/help/circle/circle_log.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';
import '../../../notifier/unread_value.dart';

class CircleApplyManage extends StatefulWidget {
  const CircleApplyManage({super.key});

  static const path = 'help/circle_apply_manage';

  @override
  State<CircleApplyManage> createState() => _CircleApplyManageState();
}

class _CircleApplyManageState extends State<CircleApplyManage> {
  int limit = 20;

  //圈子Id
  String? circleId;

  //审核列表
  List<GCircleJoinModel> list1 = [];

  //已选列表
  List<String> ids = [];

  //获取列表
  Future<int> getList({bool init = false}) async {
    if (circleId == '') return 0;
    // activeIds = [];
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListApplyCircleJoin(
        V1ListApplyCircleJoinArgs(
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : list1.length.toString(),
          ),
        ),
      );

      List<GCircleJoinModel> newList = res?.list.toList() ?? [];
      logger.i(newList);
      if (!mounted) return 0;
      if (init) {
        list1 = newList;
        UnreadValue.queryWaitApplyCircleNotRead();
      } else {
        list1 = [...list1, ...newList];
        // list1.addAll(newList);
      }
      logger.i(list1);
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  // 是否全选
  bool checkAll() {
    var ck = true;
    for (var v in list1) {
      if (v.status != GApplyStatus.APPLY) continue;
      if (!ids.contains(v.id)) {
        ck = false;
      }
    }
    return ids.isNotEmpty && ck;
  }

  //审核
  manage(List<String> id, GApplyStatus status) async {
    if (id.isEmpty) return;
    confirm(
      context,
      content: '确认审核？'.tr(args: [status == GApplyStatus.SUCCESS ? '通过' : '拒绝']),
      onEnter: () async {
        loading();
        // List<String> active = [];
        // active.add(id);
        final api = CircleApi(apiClient());
        try {
          await api.circleVerifyCircleJoin(
            V1VerifyCircleJoinArgs(
              circleId: circleId,
              id: id,
              status: status,
            ),
          );
          // if (res == null) return;
          if (!mounted) return;
          getList(init: true);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   if (!mounted) return;
    //   dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
    //   if (args['circleId'] == null) return;
    //   circleId = args['circleId'];
    //   getList(init: true);
    // });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('申请验证'.tr()),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  CircleLog.path,
                  arguments: {'circleId': circleId},
                );
              },
              child: Text(
                '日志'.tr(),
                style: TextStyle(
                  color: textColor,
                ),
              )),
        ],
      ),
      body: ThemeBody(
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (checkAll()) {
                  ids.clear();
                } else {
                  for (var v in list1) {
                    if (v.status != GApplyStatus.APPLY) continue;
                    if (!ids.contains(v.id)) {
                      ids.add(v.id!);
                    }
                  }
                }
                setState(() {});
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    AppCheckbox(
                      value: checkAll(),
                      paddingRight: 10,
                    ),
                    Text(
                      '全选'.tr(),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
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
                  var id = e.id ?? '';
                  var active = ids.contains(e.id);
                  var disabled = e.status != GApplyStatus.APPLY;
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
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: .5,
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (disabled) return;
                        setState(() {
                          if (active) ids.remove(id);
                          if (!active) ids.add(id);
                        });
                      },
                      child: Row(
                        children: [
                          AppCheckbox(
                            disabled: disabled,
                            value: active,
                            paddingLeft: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: ChatItem(
                              onAvatarTap: () {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': e.userId ?? '',
                                    'detail': GUserModel(
                                      avatar: e.avatar ?? '',
                                      nickname: e.nickname ?? '',
                                    ),
                                  },
                                );
                              },
                              titleSize: 15,
                              avatarSize: 44,
                              data: ChatItemData(
                                id: e.userId,
                                icons: [e.avatar ?? ''],
                                title: e.nickname ?? '',
                              ),
                              hasSlidable: false,
                              end: !disabled
                                  ? Row(
                                      children: [
                                        CircleButton(
                                          onTap: () {
                                            manage(
                                                [e.id!], GApplyStatus.REFUSE);
                                          },
                                          title: '拒绝'.tr(),
                                          width: 52,
                                          height: 27,
                                          theme: AppButtonTheme.grey,
                                        ),
                                        const SizedBox(
                                          width: 11,
                                        ),
                                        CircleButton(
                                          onTap: () {
                                            manage(
                                                [e.id!], GApplyStatus.SUCCESS);
                                          },
                                          title: '通过'.tr(),
                                          width: 52,
                                          height: 27,
                                        ),
                                      ],
                                    )
                                  : Text(
                                      status,
                                      style: TextStyle(
                                        color: myColors.textGrey,
                                        fontSize: 14,
                                      ),
                                    ),
                              child: Text(
                                '通过的进行申请'.tr(
                                    args: [e.inviterUserNickname ?? '', from]),
                                style: TextStyle(
                                  color: myColors.textGrey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            AppButtonBottomBox(
              child: Row(
                children: [
                  Expanded(
                    child: CircleButton(
                      title: '拒绝'.tr(),
                      height: 50,
                      width: 100,
                      fontSize: 14,
                      radius: 50,
                      theme: AppButtonTheme.grey,
                      onTap: () => manage(ids, GApplyStatus.REFUSE),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: CircleButton(
                      title: '通过'.tr(),
                      height: 50,
                      fontSize: 14,
                      radius: 50,
                      onTap: () => manage(ids, GApplyStatus.SUCCESS),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
