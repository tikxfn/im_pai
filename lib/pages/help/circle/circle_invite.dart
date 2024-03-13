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
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openapi/api.dart';

class CircleInvite extends StatefulWidget {
  const CircleInvite({super.key});

  static const String path = 'circle/circle_invite';

  @override
  State<StatefulWidget> createState() {
    return _CircleInviteState();
  }
}

class _CircleInviteState extends State<CircleInvite> {
  String keywords = '';
  String circleId = ''; //群聊id
  //朋友列表
  static List<ChatItemData> list1 = [];

  //已在圈子的朋友
  static List<ChatItemData> list2 = [];

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
  getList() async {
    //群成员列表
    final api = UserApi(apiClient());
    try {
      List<ChatItemData> newlist1 = [];
      final res = await api.userListFriend(V1ListFriendArgs(
        pager: GPagination(
          limit: '1000000',
          offset: '0',
        ),
      ));
      if (res == null) return;
      for (var v in res.list) {
        newlist1.add(ChatItemData(
          icons: [v.avatar ?? ''],
          title: v.nickname ?? '',
          id: v.id,
        ));
      }
      list1 = newlist1;
    } on ApiException catch (e) {
      onError(e);
    } finally {}
    //已在群的好友列
    list2 = [];
    final api2 = CircleApi(apiClient());
    //获取成员信息
    try {
      final res = await api2.circleListMember(
        V1ListMemberCircleArgs(
          circleId: circleId,
        ),
      );
      if (res == null) return;
      for (var v in res.list) {
        list2.add(ChatItemData(
          icons: [v.avatar ?? ''],
          title: v.nickname ?? '',
          id: v.userId,
        ));
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
    for (var v in list2) {
      for (int i = 0; i < list1.length; i++) {
        if (v.id == list1[i].id) {
          list1.remove(list1[i]);
        }
      }
    }
    if (mounted) setState(() {});
  }

  //邀请群成员进入
  invite() async {
    List<String> userIds = [];
    for (var v in activeIds) {
      userIds.add(v.id.toString());
    }
    logger.i(userIds);
    logger.i(circleId);
    final api = CircleApi(apiClient());
    loading();
    try {
      await api.circleInviteCircle(V1InviteCircleArgs(
        circleId: circleId,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['circleId'] != null) circleId = args['circleId'];
    getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('聊天成员'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              children: [
                SearchInput(
                  onChanged: (str) {
                    setState(() {
                      keywords = str;
                    });
                  },
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
                  child: ListView(
                    children: [
                      for (var e in list1)
                        if (e.title.toLowerCase().contains(keywords) ||
                            PinyinHelper.getPinyinE(e.title)
                                .split('')
                                .first
                                .toLowerCase()
                                .contains(keywords.toLowerCase()))
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
                                    avatarSize: 46,
                                    titleSize: 16,
                                    hasSlidable: false,
                                    data: e,
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
                  onTap: activeIds.isEmpty ? null : invite,
                  disabled: activeIds.isEmpty,
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
