import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';

class FriendLabelMembersUpdate extends StatefulWidget {
  const FriendLabelMembersUpdate({super.key});

  static const String path = 'friends/label_members_update';

  @override
  State<StatefulWidget> createState() {
    return _FriendLabelMembersUpdateState();
  }
}

class _FriendLabelMembersUpdateState extends State<FriendLabelMembersUpdate> {
  String keywords = '';
  List<GUserModel> labelMembersData = []; //传入默认选择用户
  //朋友列表
  List<GUserModel> list1 = [];

  //勾选列表

  List<GUserModel> activeIds = [];

  //通过id判断列表是否存该用户
  bool userContainsId(String id) {
    for (var v in activeIds) {
      if (v.id == id) return true;
    }
    return false;
  }

  //选择用户
  onChoose(GUserModel e) {
    if (userContainsId(e.id!)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //获取列表
  getList() async {
    list1 = [];
    activeIds.addAll(labelMembersData);
    final api = UserApi(apiClient());
    try {
      final res = await api.userListFriend(V1ListFriendArgs(
        pager: GPagination(
          limit: '1000000',
          offset: '0',
        ),
      ));
      if (res == null) return;
      list1 = res.list;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args =
        ModalRoute.of(context)!.settings.arguments ?? {'labelMembersData': ''};
    if (args['labelMembersData'] == null) return;
    labelMembersData = args['labelMembersData'];
    getList();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color chatInputColor = myColors.chatInputColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('选择联系人'.tr()),
        actions: [
          TextButton(
            onPressed: activeIds.isEmpty
                ? null
                : () {
                    Navigator.pop(context, activeIds);
                  },
            child: Text(
              '完成'.tr(),
              style: TextStyle(
                color: activeIds.isEmpty ? myColors.textGrey : myColors.primary,
              ),
            ),
          ),
        ],
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
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: chatInputColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < activeIds.length; i++)
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: AppAvatar(
                                      list: [activeIds[i].avatar ?? ''],
                                      size: 40,
                                      userName: activeIds[i].nickname ?? '',
                                      userId: activeIds[i].id!,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        // onChoose(activeIds[i]);
                                        activeIds.removeAt(i);
                                        setState(() {});
                                      },
                                      child: Image.asset(
                                        assetPath(
                                            'images/talk/group_close.png'),
                                        height: 15,
                                        width: 15,
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
                  child: ContactList(
                    list: const [],
                    orderList: [
                      for (var e in list1)
                        if (e.nickname!.toLowerCase().contains(keywords) ||
                            PinyinHelper.getPinyinE(e.nickname!)
                                .split('')
                                .first
                                .toLowerCase()
                                .contains(keywords.toLowerCase()))
                          ContractData(
                            widget: GestureDetector(
                              onTap: () => onChoose(e),
                              child: Row(
                                children: [
                                  AppCheckbox(
                                    value: userContainsId(e.id!),
                                    size: 25,
                                    paddingLeft: 15,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: ChatItem(
                                      hasSlidable: false,
                                      data: ChatItemData(
                                        icons: [e.avatar ?? ''],
                                        title: e.nickname ?? '',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            name: e.nickname ?? '',
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
