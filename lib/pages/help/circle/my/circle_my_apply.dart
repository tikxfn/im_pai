import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../../notifier/theme_notifier.dart';
import '../../../../notifier/unread_value.dart';

class CircleMyApply extends StatefulWidget {
  const CircleMyApply({super.key});

  static const String path = 'circle/my_apply';

  @override
  State<StatefulWidget> createState() {
    return _CircleMyApplyState();
  }
}

class _CircleMyApplyState extends State<CircleMyApply> {
  int limit = 20;

  //用户列
  static List<ChatItemData> listData = [];
  //初始加载后数据为空
  bool noList = false;

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListUserApplyCircleJoin(
        V1ListUserApplyCircleJoinArgs(
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : listData.length.toString(),
          ),
        ),
      );
      if (res == null) return 0;
      List<ChatItemData> newListData = [];
      for (var v in res.list) {
        newListData.add(ChatItemData(
            icons: [v.image ?? ''],
            title: v.name ?? '',
            // text: '来自：${v.inviterUserNickname!} 的邀请',
            time: v.status == GApplyStatus.APPLY
                ? '等待审核'.tr()
                : v.status == GApplyStatus.SUCCESS
                    ? '申请通过'.tr()
                    : '已拒绝'.tr()));
      }
      if (!mounted) return 0;
      if (init) {
        listData = newListData;
        UnreadValue.circleMyApplyNotRead.value = 0;

        if (listData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        listData.addAll(newListData);
      }
      setState(() {});
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
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: PagerBox(
                limit: limit,
                onInit: () async {
                  //初始化

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
                children: [
                  if (listData.isEmpty && noList)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            assetPath('images/help/sp_zanwuneirong2.png'),
                            width: 200,
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '暂无申请'.tr(),
                            style: TextStyle(
                              color: myColors.textGrey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (listData.isNotEmpty)
                    Column(
                      children: listData.map((e) {
                        Color statusColor = myColors.textGrey;
                        Color statusBgColor = myColors.white;
                        switch (e.time) {
                          case '等待审核':
                            statusColor = myColors.im2Apply;
                            // statusBgColor = myColors.im2ApplyBg;
                            break;
                          case '申请通过':
                            statusColor = myColors.im2Success;
                            // statusBgColor = myColors.im2SuccessBg;
                            break;
                          case '已拒绝':
                            statusColor = myColors.im2Refuse;
                            // statusBgColor = myColors.im2RefuseBg;
                            break;
                        }
                        return ChatItem(
                          avatarSize: 46,
                          titleSize: 16,
                          data: ChatItemData(
                            icons: e.icons,
                            title: e.title,
                          ),
                          hasSlidable: false,
                          end: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 8),
                            decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              e.time,
                              style: TextStyle(
                                color: statusColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ]),
          ),
        ],
      ),
    );
  }
}
