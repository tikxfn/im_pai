import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
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
import '../../friend/friend_detail.dart';

class GroupKickOut extends StatefulWidget {
  const GroupKickOut({super.key});

  static const String path = 'chat/chat_management/group_kick_out';

  @override
  State<StatefulWidget> createState() {
    return _GroupKickOutState();
  }
}

class _GroupKickOutState extends State<GroupKickOut> {
  int limit = 50;
  String keywords = '';
  String userId = ''; //用户id
  String roomId = ''; //群聊id

  //勾选列表
  List<GRoomMemberModel> activeIds = [];

  //朋友列表
  List<GRoomMemberModel> userList = [];

  //选择用户
  onChoose(GRoomMemberModel e) {
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
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListMember(V1ListMemberRoomArgs(
        keywords: keywords,
        roomId: roomId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : userList.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<GRoomMemberModel> l = [];
      for (var v in res?.list ?? []) {
        if (userId == v.userId) {
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

  //踢出群成员
  delete() async {
    confirm(
      context,
      title: '确定删除成员'.tr(),
      onEnter: () async {
        List<String> userIds = [];
        for (var v in activeIds) {
          userIds.add(v.userId.toString());
        }
        final api = RoomApi(apiClient());
        loading();
        try {
          await api.roomExitRoomMember(
              V1ExitRoomMemberArgs(roomId: roomId, userIds: userIds));
          if (mounted) Navigator.pop(context);
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['roomId'] != null) roomId = args['roomId'];
    if (args['userId'] != null) userId = args['userId'];
    // getList();
    // _getList(init: true);
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _textController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
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
                                  onAvatarTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      FriendDetails.path,
                                      arguments: {
                                        'id': e.userId,
                                        'friendFrom': 'ROOM',
                                        'roomId': roomId,
                                        'removeToTabs': true,
                                        'detail': GUserModel(
                                          avatar: e.avatar ?? '',
                                          nickname: e.nickname ?? '',
                                        ),
                                      },
                                    );
                                  },
                                  avatarSize: 46,
                                  titleSize: 16,
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
                  title: '删除'.tr(),
                  disabled: activeIds.isEmpty,
                  onTap: activeIds.isEmpty ? null : delete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
