import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleApplyLog extends StatefulWidget {
  const CircleApplyLog({super.key});

  static const path = 'help/circle_apply_log';

  @override
  State<CircleApplyLog> createState() => _CircleApplyLogState();
}

class _CircleApplyLogState extends State<CircleApplyLog> {
  int limit = 20;

  //圈子Id
  String? circleId;

  //审核列表
  List<GCircleJoinModel> list1 = [];

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
      if (res == null) return 0;
      List<GCircleJoinModel> newList = res.list.toList();

      if (!mounted) return 0;
      if (init) {
        list1 = newList;
      } else {
        list1 = [...list1, ...newList];
        // list1.addAll(newList);
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('审核记录'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: PagerBox(
              limit: limit,
              onInit: () async {
                if (!mounted) return 0;
                dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
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
                    from = '邀请';
                    break;
                  case GCircleJoinFrom.INVITE:
                    from = '圈子分享';
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
                  child: ChatItem(
                    onAvatarTap: () {
                      Navigator.pushNamed(
                        context,
                        FriendDetails.path,
                        arguments: {'id': e.userId ?? ''},
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '通过${e.inviterUserNickname}的$from进行申请',
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '审核人：${e.verifyNickname ?? ''}',
                              style: TextStyle(
                                color: myColors.textBlack,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              status,
                              style: TextStyle(
                                color: myColors.textBlack,
                                fontSize: 14,
                              ),
                            ),
                          ],
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
    );
  }
}
