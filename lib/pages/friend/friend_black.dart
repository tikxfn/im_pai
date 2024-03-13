import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class FriendBlack extends StatefulWidget {
  const FriendBlack({super.key});

  static const String path = 'friends/black';

  @override
  State<StatefulWidget> createState() {
    return _FriendBlackState();
  }
}

class _FriendBlackState extends State<FriendBlack> {
  int limit = 20;
  //朋友列表
  List<GUserModel> blackList = [];

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userListBlackFriend(V1ListBlackFriendArgs(
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : blackList.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<GUserModel> newListData = res?.list.toList() ?? [];
      if (init) {
        blackList = newListData;
      } else {
        blackList.addAll(newListData);
      }
      if (mounted) setState(() {});
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //移除黑名单
  removeBlack(GUserModel v) async {
    confirm(
      context,
      title: '确定移除黑名单'.tr(),
      onEnter: () async {
        var id = v.id;
        final api = UserApi(apiClient());
        try {
          blackList = [];
          await api.userRemoveBlackFriend(GIdArgs(id: id));
          FriendListNotifier().add(UserInfo.fromModel(v));
          if (!mounted) return;
          getList();
        } on ApiException catch (e) {
          onError(e);
        } finally {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('黑名单'.tr()),
      ),
      body: ThemeBody(
        child: Column(
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
                  Container(
                    color: myColors.themeBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: blackList.map((e) {
                        return ChatItem(
                          hasSlidable: false,
                          data: ChatItemData(
                            icons: [e.avatar ?? ''],
                            title: e.nickname ?? '',
                          ),
                          end: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  removeBlack(e);
                                },
                                child: Text(
                                  '移除黑名单'.tr(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
