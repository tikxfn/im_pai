import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleBanMembers extends StatefulWidget {
  const CircleBanMembers({super.key});

  static const String path = 'circle/circle_ban_members';

  @override
  State<StatefulWidget> createState() {
    return _CircleBanMembersState();
  }
}

class _CircleBanMembersState extends State<CircleBanMembers> {
  int limit = 50;
  String keywords = '';
  String circleId = ''; //群聊id
  static List<GCircleJoinModel> userList = [];
  //勾选列表
  List<GCircleJoinModel> activeIds = [];
  //禁用时间
  String banTime = '1';
  List<String> timeSelect = [
    '1',
    '3',
    '7',
    '15',
    '30',
  ];

  //选择用户
  onChoose(GCircleJoinModel e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListMember(V1ListMemberCircleArgs(
        keywords: keywords,
        circleId: circleId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : userList.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<GCircleJoinModel> l = [];
      for (var v in res?.list ?? []) {
        if (v.role == GRole.LEADER || v.role == GRole.ADMIN) {
          continue;
        }
        l.add(v);
      }
      setState(() {
        if (init) {
          userList = l;
        } else {
          userList.addAll(l);
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

  //设置入圈所需邀请人数
  _chooseNumber() {
    var index = 0;
    openSelect(
      context,
      index: index,
      list: timeSelect,
      onEnter: (i) {
        setState(() {
          banTime = timeSelect[i];
        });
      },
    );
  }

  //禁用用户
  ban() async {
    confirm(
      context,
      title: '确定封禁所选用户天'.tr(args: [banTime]),
      onEnter: () async {
        List<String> userIds = [];
        for (var v in activeIds) {
          userIds.add(v.userId.toString());
        }
        final api = CircleApi(apiClient());
        loading();
        try {
          await api.circleDisableUser(V1CircleDisableUserArgs(
            circleId: circleId,
            userId: userIds,
            disableTime: banTime,
          ));
          tip('操作成功'.tr());
          if (!mounted) return;
          Navigator.pop(context);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('圈子成员'.tr()),
        // actions: [
        //   TextButton(
        //       onPressed: activeIds.isEmpty ? null : ban,
        //       child: Text(
        //         '封禁'.tr(),
        //         style: TextStyle(
        //           fontSize: 15,
        //           color:
        //               activeIds.isEmpty ? myColors.textGrey : myColors.primary,
        //         ),
        //       )),
        // ],
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
                              _getList(init: true);
                            }
                          });
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _getList(init: true);
                      },
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
                MenuUl(
                  marginTop: 5,
                  marginBottom: 5,
                  children: [
                    MenuItemData(
                      title: '禁用天数'.tr(),
                      content: Text(
                        '天'.tr(args: [banTime]),
                        style: TextStyle(
                          color: textColor,
                        ),
                      ),
                      onTap: _chooseNumber,
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
                                      list: [activeIds[i].avatar ?? ''],
                                      size: 41,
                                      userName: activeIds[i].nickname ?? '',
                                      userId: activeIds[i].userId ?? '',
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
                      if (args['circleId'] != null) circleId = args['circleId'];
                      return await _getList(init: true);
                    },
                    onPullDown: () async {
                      return await _getList(init: true);
                    },
                    onPullUp: () async {
                      return await _getList();
                    },
                    children: [
                      for (var e in userList)
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
                                  onAvatarTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      FriendDetails.path,
                                      arguments: {'id': e.userId ?? ''},
                                    );
                                  },
                                  hasSlidable: false,
                                  data: ChatItemData(
                                    icons: [e.avatar ?? ''],
                                    title: e.nickname ?? '',
                                    id: e.userId,
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
                  title: '封禁'.tr(),
                  onTap: activeIds.isEmpty ? null : ban,
                  disabled: activeIds.isEmpty,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
