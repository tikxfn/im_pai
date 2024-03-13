import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupInvite extends StatefulWidget {
  const GroupInvite({super.key});

  static const String path = 'chat/chat_management/group_invite';

  @override
  State<StatefulWidget> createState() {
    return _GroupInviteState();
  }
}

class _GroupInviteState extends State<GroupInvite> {
  int limit = 50;
  String keywords = '';
  String roomId = ''; //群聊id
  //朋友列表
  List<ChatItemData> list1 = [];

  //已在群的朋友
  List<ChatItemData> list2 = [];

  //勾选列表
  List<ChatItemData> activeIds = [];

  //选择用户
  onChoose(ChatItemData e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //获取列表
  getList({bool init = false, bool load = false}) async {
    if (load) loading();
    //群成员列表
    final api = UserApi(apiClient());
    try {
      final res = await api.userListFriend(V1ListFriendArgs(
        keyword: keywords,
        roomId: roomId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : list1.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<ChatItemData> newlist1 = [];
      for (var v in res?.list ?? []) {
        newlist1.add(ChatItemData(
          icons: [v.avatar ?? ''],
          title: v.nickname ?? '',
          id: v.id,
        ));
      }
      setState(() {
        if (init) {
          list1 = newlist1;
        } else {
          list1.addAll(newlist1);
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

  //邀请群成员进入
  invite() async {
    List<String> userIds = [];
    for (var v in activeIds) {
      userIds.add(v.id.toString());
    }
    logger.i(userIds);
    final api = RoomApi(apiClient());
    loading();
    try {
      await api.roomInviteRoom(V1InviteRoomArgs(
        roomId: roomId,
        userIds: userIds,
      ));
      // if (res == null) return;
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('选择联系人'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
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
                      onPressed: () {
                        getList(init: true);
                      },
                      child: Text(
                        '搜索',
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
                if (activeIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < activeIds.length; i++)
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: AppAvatar(
                                      list: activeIds[i].icons,
                                      size: 41,
                                      userName: activeIds[i].title,
                                      userId: activeIds[i].id ?? '',
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        onChoose(activeIds[i]);
                                      },
                                      child: Image.asset(
                                        assetPath(
                                            'images/talk/group_close.png'),
                                        height: 19,
                                        width: 19,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: PagerBox(
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    limit: limit,
                    onInit: () async {
                      if (!mounted) return 0;
                      dynamic args = ModalRoute.of(context)!.settings.arguments;
                      if (args == null) return 0;
                      if (args['roomId'] != null) roomId = args['roomId'];
                      return await getList(init: true);
                    },
                    onPullDown: () async {
                      return await getList(init: true);
                    },
                    onPullUp: () async {
                      return await getList();
                    },
                    children: [
                      for (var e in list1)
                        GestureDetector(
                          onTap: () => onChoose(e),
                          child: Row(
                            children: [
                              AppCheckbox(
                                value: activeIds.contains(e),
                                size: 25,
                                paddingLeft: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: ChatItem(
                                  hasSlidable: false,
                                  avatarSize: 46,
                                  titleSize: 16,
                                  data: ChatItemData(
                                    icons: e.icons,
                                    title: e.title,
                                    id: e.id,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                BottomButton(
                  title: '邀请加入'.tr(),
                  disabled: activeIds.isEmpty,
                  onTap: activeIds.isEmpty ? null : invite,
                ),
                // SafeArea(
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     child: Container(
                //       width: double.infinity,
                //       height: 50,
                //       padding: const EdgeInsets.fromLTRB(0, 5, 20, 10),
                //       color: myColors.tagColor,
                //       alignment: Alignment.topRight,
                //       child: ElevatedButton(
                //           onPressed: activeIds.isEmpty ? null : invite,
                //           child: Text(
                //             '邀请加入'.tr(),
                //             style: const TextStyle(
                //               fontSize: 12,
                //             ),
                //           )),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
