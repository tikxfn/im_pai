import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class GroupTransferLeader extends StatefulWidget {
  const GroupTransferLeader({super.key});

  static const String path = 'chat/chat_management/transfer_leader';

  @override
  State<StatefulWidget> createState() {
    return _GroupTransferLeaderState();
  }
}

class _GroupTransferLeaderState extends State<GroupTransferLeader> {
  int limit = 50;
  String keywords = '';

  String roomId = ''; //群聊id

  //朋友列表
  List<GRoomMemberModel> userList = [];

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
        if (v.identity == GRoomMemberIdentity.OWNER) continue;
        l.add(v);
      }
      setState(() {
        if (init) {
          userList = l;
        } else {
          userList.addAll(l);
        }
      });
      logger.i(userList);
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  transferLeader(String id, String name) {
    confirm(
      context,
      title: '${'确定将群主转让给'.tr()}"$name"${'用户'.tr()}',
      onEnter: () async {
        final api = RoomApi(apiClient());
        loading();
        try {
          await api.roomTransferRoomOwner(
              V1RoomTransferRoomOwnerArgs(roomId: roomId, userId: id));
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
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('聊天成员'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
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
                    logger.i(roomId);
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
                        onTap: () {
                          transferLeader(e.userId!, e.nickname ?? '');
                        },
                        child: ChatItem(
                          hasSlidable: false,
                          avatarSize: 46,
                          titleSize: 16,
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
      ),
    );
  }
}
