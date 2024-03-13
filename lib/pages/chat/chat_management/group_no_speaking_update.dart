import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupNoSpeakingUpdate extends StatefulWidget {
  const GroupNoSpeakingUpdate({super.key});

  static const String path = 'chat/chat_management/group_no_speaking';

  @override
  State<StatefulWidget> createState() {
    return _GroupNoSpeakingUpdateState();
  }
}

class _GroupNoSpeakingUpdateState extends State<GroupNoSpeakingUpdate> {
  int limit = 50;
  String keywords = '';
  String roomId = ''; //群聊id
  bool isEnableProhibition = false; //禁言或取消禁言

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

  //获取用户列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = RoomApi(apiClient());
    List<GRoomMemberModel> l = [];
    try {
      if (isEnableProhibition) {
        final res = await api.roomListMember(
          V1ListMemberRoomArgs(
            keywords: keywords,
            roomId: roomId,
            pager: GPagination(
              limit: limit.toString(),
              offset: init ? '0' : userList.length.toString(),
            ),
          ),
        );

        if (!mounted) return 0;
        l = [];
        for (var v in res?.list ?? []) {
          if (v.identity == GRoomMemberIdentity.MEMBER &&
              v.enableProhibition != GSure.YES) {
            l.add(v);
          }
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
      }
      if (!isEnableProhibition) {
        final res = await api.roomListMember(V1ListMemberRoomArgs(
          isProhibition: GSure.YES,
          roomId: roomId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : userList.length.toString(),
          ),
        ));
        if (!mounted) return 0;
        l = res?.list.toList() ?? [];
        setState(() {
          if (init) {
            userList = l;
          } else {
            userList.addAll(l);
          }
        });
        if (res == null) return 0;
        return res.list.length;
      }
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  //禁言
  onSpeaking() async {
    confirm(
      context,
      title: '确定对勾选用户进行禁言'.tr(),
      onEnter: () async {
        List<String> userIds = [];
        for (var v in activeIds) {
          userIds.add(v.userId.toString());
        }
        logger.i(userIds);
        var success = await ApiRequest.apiUserSilence(
          userIds,
          roomId,
          load: true,
        );
        if (!success) return;
        activeIds = [];
        _getList(init: true);
      },
    );
  }

  //恢复发言
  speaking() async {
    confirm(
      context,
      title: '确定恢复对勾选用户的发言'.tr(),
      onEnter: () async {
        List<String> userIds = [];
        for (var v in activeIds) {
          userIds.add(v.userId.toString());
        }
        logger.i(userIds);
        final api = RoomApi(apiClient());
        loading();
        try {
          await api.roomChannelMemberProhibition(V1ChannelMemberProhibitionArgs(
            roomId: roomId,
            ids: userIds,
          ));
          if (mounted) {
            activeIds = [];
            _getList(init: true);
          }
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          isEnableProhibition ? '禁言成员'.tr() : '解除禁言'.tr(),
        ),
        actions: [
          TextButton(
              onPressed: activeIds.isEmpty
                  ? null
                  : () {
                      if (isEnableProhibition) {
                        onSpeaking();
                      }
                      if (!isEnableProhibition) {
                        speaking();
                      }
                    },
              child: Text(
                '完成'.tr(),
                style: TextStyle(
                  fontSize: 15,
                  color:
                      activeIds.isEmpty ? myColors.textGrey : myColors.primary,
                ),
              )),
        ],
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
                      onPressed: keywords != ''
                          ? () {
                              _getList(init: true);
                            }
                          : null,
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
                    limit: limit,
                    onInit: () async {
                      if (!mounted) return 0;
                      dynamic args = ModalRoute.of(context)!.settings.arguments;
                      if (args == null) return 0;
                      if (args['roomId'] != null) roomId = args['roomId'];
                      if (args['isenableProhibition'] != null) {
                        isEnableProhibition = args['isenableProhibition'];
                      }
                      logger.i(isEnableProhibition);
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
