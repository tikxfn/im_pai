import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';

class CircleMore extends StatefulWidget {
  const CircleMore({super.key});

  static const String path = 'circle/more';

  @override
  State<StatefulWidget> createState() {
    return _CircleMoreState();
  }
}

class _CircleMoreState extends State<CircleMore> {
  //圈子列表
  List<GCircleModel> circleData = [];
  int limit = 30;

  //获取rowList
  Future<int> getList({init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircle(
        V1ListCircleArgs(
          isPublic: GSure.YES,
          name: '',
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : circleData.length.toString(),
          ),
        ),
      );
      if (res == null) return 0;
      List<GCircleModel> newCirlceData = res.list.toList();

      if (!mounted) return 0;
      if (init) {
        circleData = newCirlceData;
      } else {
        circleData.addAll(newCirlceData);
      }
      setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //加入圈子
  join(String id) async {
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleJoinCircle(V1JoinCircleArgs(
        id: id,
        inviterUserId: '0',
      ));
      getList(init: true);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('更多圈子'.tr()),
        ),
        body: PagerBox(
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
          children: circleData.map((v) {
            return ChatItem(
              avatarSize: 44,
              titleSize: 15,
              onTap: () {
                Navigator.pushNamed(context, GroupHome.path,
                    arguments: {'circleId': v.id!});
              },
              hasSlidable: false,
              data: ChatItemData(
                icons: [v.image ?? ''],
                title: v.name ?? '',
              ),
              end: toBool(v.isJoin)
                  ? CircleButton(
                      onTap: null,
                      title: '已加入'.tr(),
                      // color: myColors.lineGrey,
                      width: 44,
                      disabled: true,
                    )
                  : CircleButton(
                      onTap: () {
                        join(v.id!);
                      },
                      title: '加入'.tr(),
                      theme: AppButtonTheme.blue,
                      // color: myColors.primary,
                      width: 44,
                    ),
            );
          }).toList(),
        ));
  }
}
