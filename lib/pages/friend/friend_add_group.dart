import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/friend/friend_add_group_complete.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';

class FriendAddGroup extends StatefulWidget {
  const FriendAddGroup({super.key});

  static const String path = 'friends/addGroup';

  @override
  State<StatefulWidget> createState() {
    return _FriendAddGroupState();
  }
}

class _FriendAddGroupState extends State<FriendAddGroup> {
  String keywords = '';
  String? userId; //传入默认选择用户Id
  //朋友列表
  List<ChatItemData> list = [];

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
    list = [];
    activeIds = [];
    final api = UserApi(apiClient());
    try {
      final res = await api.userListFriend(
        V1ListFriendArgs(
          pager: GPagination(
            limit: '1000000',
            offset: '0',
          ),
        ),
      );
      if (res == null || !mounted) return;
      for (var v in res.list) {
        var mark = v.mark ?? '';
        list.add(ChatItemData(
          icons: [v.avatar ?? ''],
          title: mark.isNotEmpty ? mark : v.nickname ?? '',
          id: v.id,
        ));
      }
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
    for (int i = 0; i < list.length; i++) {
      if (userId == list[i].id) {
        activeIds.add(list[i]);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {'Id': ''};
    if (args['Id'] == null) return;
    userId = args['Id'];
    getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    List<ChatItemData> l = [];
    for (var v in list) {
      if (v.title.toLowerCase().contains(keywords)) {
        l.add(v);
      }
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('发起群聊'.tr()),
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
                                        fit: BoxFit.contain,
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
                  // child: ListView.builder(
                  //   itemCount: l.length,
                  //   itemBuilder: (context, i) {
                  //     var e = l[i];
                  //     return GestureDetector(
                  //       onTap: () => onChoose(e),
                  //       child: Row(
                  //         children: [
                  //           AppCheckbox(
                  //             value: activeIds.contains(e),
                  //             size: 25,
                  //             paddingLeft: 15,
                  //           ),
                  //           Expanded(
                  //             flex: 1,
                  //             child: ChatItem(
                  //               hasSlidable: false,
                  //               data: e,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                  child: ContactList(
                    list: const [],
                    orderList: [
                      for (var e in l)
                        ContractData(
                          widget: GestureDetector(
                            onTap: () => onChoose(e),
                            child: Container(
                              color: activeIds.contains(e)
                                  ? myColors.listCheckedBg
                                  : null,
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
                                      data: e,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          name: e.title,
                        ),
                    ],
                  ),
                ),
                BottomButton(
                  title: '下一步'.tr(),
                  disabled: activeIds.isEmpty,
                  onTap: activeIds.isEmpty
                      ? null
                      : () {
                          if (platformPhone) {
                            Navigator.pushReplacementNamed(
                              context,
                              FriendAddGroupComplete.path,
                              arguments: {'activeIds': activeIds},
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              FriendAddGroupComplete.path,
                              arguments: {'activeIds': activeIds},
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
