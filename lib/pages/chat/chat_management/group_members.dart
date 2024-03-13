import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/chat/chat_management/group_invite.dart';
import 'package:unionchat/pages/chat/chat_management/group_kick_out.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar_name.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../function_config.dart';
import '../../../notifier/theme_notifier.dart';

class GroupMembers extends StatefulWidget {
  const GroupMembers({super.key});

  static const String path = 'friends/group_members';

  @override
  State<StatefulWidget> createState() {
    return _GroupMembersState();
  }
}

class _GroupMembersState extends State<GroupMembers> {
  String keywords = '';
  String roomId = ''; //群id
  double size = 44; //头像大小
  Color nameColor = ThemeNotifier().textBlack; //文字颜色
  GRoomModel? detail; //群信息
  GRoomMemberModel? userDetail; //用户在群的信息
  GRoomMemberIdentity? identity; //群身份
  bool enableVisit = false; //是否可以查看群成员
  List<GRoomMemberModel> userList = [];
  bool roomManage = false;
  int limit = 50;
  String totalNumber = '';

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
      List<GRoomMemberModel> l = res?.list.toList() ?? [];
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

  //获取详情
  getDetail() async {
    final api = RoomApi(apiClient());
    //获取自己在群里的信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null || !mounted) return;
      setState(() {
        detail = res.room;
        userDetail = res.my;
        identity = res.my!.identity;
        roomManage = identity == GRoomMemberIdentity.ADMIN ||
            identity == GRoomMemberIdentity.MEMBER;
        enableVisit = toBool(res.room!.enableVisit);
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['roomId'] != null) roomId = args['roomId'];
    if (args['number'] != null) totalNumber = args['number'];
    // getList();
    // getDetail();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    nameColor = myColors.iconThemeColor;
    bool admin = identity == GRoomMemberIdentity.OWNER ||
        identity == GRoomMemberIdentity.ADMIN;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FunctionConfig.roomShowTotal
              ? '群成员()'.tr(args: [totalNumber])
              : '群成员'.tr(),
        ),
      ),
      body: KeyboardBlur(
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
              Expanded(
                flex: 1,
                child: PagerBox(
                  pullBottom: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  limit: limit,
                  onInit: () async {
                    getDetail();
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    getDetail();
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    RowList(
                      lineSpacing: 10,
                      rowNumber: 5,
                      children: [
                        //邀请进群
                        // if (admin)
                        CircularButton(
                          onTap: () {
                            if (admin && toInt(detail?.totalCount) < 10) {
                              Navigator.pushNamed(
                                context,
                                GroupInvite.path,
                                arguments: {'roomId': roomId},
                              ).then((value) {
                                _getList(init: true);
                              });
                            } else {
                              Navigator.push(
                                context,
                                CupertinoModalPopupRoute(
                                  builder: (context) {
                                    var msg = Message()
                                      ..senderUser = getSenderUser()
                                      ..type = GMessageType.ROOM_CARD
                                      ..content = detail?.roomName
                                      ..contentId = toInt(roomId)
                                      ..fileUrl = detail?.avatar;
                                    return ShareHome(
                                      shareText: '[群名片]'
                                          .tr(args: [detail?.roomName ?? '']),
                                      list: [msg],
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          title: '邀请'.tr(),
                          size: size,
                          nameColor: nameColor,
                          child: Icon(
                            Icons.add,
                            color: myColors.lineGrey,
                          ),
                        ),
                        //踢出群聊
                        if (admin)
                          CircularButton(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                GroupKickOut.path,
                                arguments: {
                                  'roomId': roomId,
                                  'userId': userDetail?.userId,
                                },
                              ).then((value) {
                                _getList(init: true);
                              });
                            },
                            title: '移除'.tr(),
                            size: size,
                            nameColor: nameColor,
                            child: Icon(
                              Icons.remove,
                              color: myColors.lineGrey,
                            ),
                          ),
                        for (var v in userList)
                          // if (v.roomNickname!.toLowerCase().contains(keywords))
                          GestureDetector(
                            onTap: () {
                              if (identity == GRoomMemberIdentity.MEMBER &&
                                  !enableVisit) {
                                return;
                              }
                              var id = v.userId;
                              if (id != Global.user!.id!) {
                                Navigator.pushNamed(
                                  context,
                                  FriendDetails.path,
                                  arguments: {
                                    'id': v.userId,
                                    'friendFrom': 'ROOM',
                                    'roomId': roomId,
                                    'removeToTabs': true,
                                    'detail': GUserModel(
                                      avatar: v.avatar,
                                      nickname: v.nickname,
                                      id: v.userId,
                                    ),
                                  },
                                );
                              }
                            },
                            onLongPress: () {
                              // if(roomManage) return;
                              // goUpdateMark(v.roomNickname ?? '', v.userId ?? '');
                            },
                            child: AvatarName(
                              // avatars: userList[i].avatar!,
                              avatars: [v.avatar ?? ''],
                              name: v.roomNickname ?? '',
                              userName: v.nickname ?? '',
                              userId: v.userId ?? '',
                              nameColor: nameColor,
                              isAdmin: v.identity == GRoomMemberIdentity.ADMIN,
                              isOwner: v.identity == GRoomMemberIdentity.OWNER,
                              onlineTime: time2onlineDate(v.lastOnlineTime,
                                  zeroStr: '当前在线'.tr()),
                            ),
                          ),
                      ],
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
