import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/chat/chat_management/chat_complaint.dart';
import 'package:unionchat/pages/chat/chat_management/group_card.dart';
import 'package:unionchat/pages/chat/chat_management/group_invite.dart';
import 'package:unionchat/pages/chat/chat_management/group_kick_out.dart';
import 'package:unionchat/pages/chat/chat_management/group_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_members.dart';
import 'package:unionchat/pages/chat/chat_management/group_notice.dart';
import 'package:unionchat/pages/chat/search_self_messaged.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/widgets/avatar_name.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/undo_dialog.dart';
import 'package:provider/provider.dart';

import '../../function_config.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/form_widget.dart';

class ChatSetting extends StatefulWidget {
  const ChatSetting({super.key});

  static const String path = 'chat/setting';

  @override
  State<StatefulWidget> createState() {
    return _ChatSettingState();
  }
}

class _ChatSettingState extends State<ChatSetting> {
  String receiver = ''; //接受者id
  String roomId = ''; //群聊id
  String pairId = '';
  String searchRoomId = ''; //搜索作用群id，用于生成二维码
  int limit = 18;
  List<GRoomMemberModel> userList = []; //群成员列表
  GRoomModel? detail; //群信息
  GRoomMemberModel? userDetail; //用户在群的信息
  GRoomMemberIdentity? identity; //群身份
  GChannelModel? topic; //群topic
  bool enableFriend = false; //是否可以添加朋友
  bool enableVisit = false; //是否可以查看群成员
  double size = 50; //头像大小
  Color nameColor = ThemeNotifier().textBlack; //文字颜色
  bool _isInitialized = false;

  // 消息免打扰
  bool _doNotDisturb = false;

  //置顶
  bool _setTop = false;

  //清空聊天记录提示
  removeHistoryConfirm() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return UndoDialog(
          showUndo: identity == GRoomMemberIdentity.OWNER ||
              identity == GRoomMemberIdentity.ADMIN,
          onEnter: (undo) {
            removeHistory(undo);
          },
        );
      },
    );
  }

  //清空聊天记录
  removeHistory(bool undo) async {
    loading();
    try {
      await MessageUtil.clearChannelMessages(pairId, both: undo);
      tipSuccess('操作成功');
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //群成员列表
  getUserList() async {
    final api = RoomApi(apiClient());
    try {
      var args = V1ListMemberRoomArgs(
        roomId: roomId,
        pager: GPagination(
          limit: limit.toString(),
          offset: '0',
        ),
      );
      final res = await api.roomListMember(args);
      userList = res?.list ?? [];
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //获取详情
  getDetail() async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null || !mounted) return;
      setState(() {
        //获取群的信息
        detail = res.room;
        searchRoomId = res.room!.roomId!;
        enableFriend = toBool(res.room!.enableFriend);
        enableVisit = toBool(res.room!.enableVisit);
        //获取自己在群里的信息
        userDetail = res.my;
        identity = res.my!.identity;
        topic = res.channel;

        _doNotDisturb = topic?.doNotDisturb ?? false;
        _setTop = topic?.topTime == '0' ? false : true;
      });
      // logger.i(roomId);
      // logger.i(identity);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //设置群名称
  Future<bool> saveRoomName(String str) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          roomName: V1UpdateRoomInfoArgsValue(value: str),
        ),
      );
      MessageUtil.updateChannelInfo(pairId, name: str);
      getDetail();
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return true;
  }

  //保存群备注
  Future<bool> saveRoomMark(String str) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomMemberInfo(
        V1UpdateRoomMemberInfoArgs(
          roomId: roomId,
          roomMark: V1UpdateRoomMemberInfoArgsValue(value: str),
        ),
      );
      MessageUtil.updateChannelInfo(pairId, mark: str);
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return true;
  }

  //启用置顶
  isTop(bool val) async {
    MessageUtil.top(pairId, val);
  }

  //保存自己在群的名称
  Future<bool> saveNickName(String str) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomMemberInfo(
        V1UpdateRoomMemberInfoArgs(
          roomId: roomId,
          roomNickname: V1UpdateRoomMemberInfoArgsValue(value: str),
        ),
      );
      getDetail();
      getUserList();
      // ChatTalkNotifier().updateRoomNickName(str);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return true;
  }

  //退出群聊
  delete() {
    confirm(
      context,
      title: '确定要退出该群聊'.tr(),
      onEnter: () async {
        var api = RoomApi(apiClient());
        loading();
        try {
          await api.roomExitRoom(V1ExitRoomArgs(roomId: roomId));
          MessageUtil.deleteLocalChannel(pairId);
          if (mounted) {
            Navigator.popUntil(context, ModalRoute.withName(Tabs.path));
          }
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    if (_isInitialized) return;
    _isInitialized = true;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      receiver = args['receiver'] ?? '';
      roomId = args['roomId'] ?? '';
      pairId = args['pairId'] ?? '';
      getUserList();
      getDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    nameColor = myColors.iconThemeColor;
    int groupApplyNotRead = toInt(detail?.unreadCount);
    bool admin = identity == GRoomMemberIdentity.OWNER ||
        identity == GRoomMemberIdentity.ADMIN;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          FunctionConfig.roomShowTotal
              ? '聊天详情()'.tr(args: [toInt(detail?.totalCount).toString()])
              : '聊天详情',
        ),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            //成员信息
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: const BoxDecoration(
                  // color: myColors.white,
                  ),
              child: Column(
                children: [
                  //成员列表
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: RowList(
                      rowNumber: 5,
                      lineSpacing: 10,
                      spacing: 10,
                      children: [
                        for (var i = 0; i < userList.length; i++)
                          GestureDetector(
                            onTap: () {
                              if (identity == GRoomMemberIdentity.MEMBER &&
                                  !enableVisit) {
                                return;
                              }
                              if (userList[i].userId != Global.user!.id) {
                                Navigator.pushNamed(context, FriendDetails.path,
                                    arguments: {
                                      'id': userList[i].userId,
                                      'friendFrom': 'ROOM',
                                      'roomId': roomId,
                                      'removeToTabs': true,
                                      'detail': GUserModel(
                                        avatar: userList[i].avatar ?? '',
                                        nickname: userList[i].nickname ?? '',
                                        id: userList[i].userId ?? '',
                                      ),
                                    });
                              }
                            },
                            child: AvatarName(
                              avatars: [userList[i].avatar ?? ''],
                              name: userList[i].roomNickname ?? '',
                              userName: userList[i].nickname ?? '',
                              userId: userList[i].userId ?? '',
                              size: size,
                              nameColor: nameColor,
                              isAdmin: userList[i].identity ==
                                  GRoomMemberIdentity.ADMIN,
                              isOwner: userList[i].identity ==
                                  GRoomMemberIdentity.OWNER,
                              onlineTime: time2onlineDate(
                                userList[i].lastOnlineTime,
                                zeroStr: '当前在线'.tr(),
                              ),
                            ),
                          ),
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
                                getDetail();
                                getUserList();
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
                                getDetail();
                                getUserList();
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            GroupMembers.path,
                            arguments: {
                              'roomId': roomId,
                              'userId': userDetail?.userId,
                              'number': detail!.totalCount,
                            },
                          ).then((value) {
                            getUserList();
                          });
                        },
                        child: Text(
                          '查看更多群成员'.tr(),
                          style: TextStyle(
                            color: myColors.textGrey,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: myColors.textGrey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '群聊名称'.tr(),
                  content: Text(
                    detail?.roomName ?? 'null',
                    style: TextStyle(
                      fontSize: 12,
                      color: myColors.textGrey,
                    ),
                  ),
                  onTap: () {
                    if (identity == GRoomMemberIdentity.OWNER ||
                        identity == GRoomMemberIdentity.ADMIN) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SetNameInput(
                            title: '设置群聊名称'.tr(),
                            // subTitle: '群聊名称不能超过15个字',
                            value: detail?.roomName ?? '',
                            onEnter: saveRoomName,
                          );
                        }),
                      );
                    }
                  },
                ),
                // if (admin)
                MenuItemData(
                    title: '群二维码'.tr(),
                    content: Icon(
                      Icons.qr_code,
                      color: myColors.textGrey,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, GroupCard.path, arguments: {
                        'roomId': roomId,
                      }).then((value) {
                        getDetail();
                        getUserList();
                      });
                    }),
                // MenuItemData(
                //   title: '群公告',
                //   content: Container(
                //     width: 200,
                //     alignment: Alignment.topRight,
                //     child: Text(
                //       detail?.notice ?? '',
                //       overflow: TextOverflow.ellipsis,
                //       maxLines: 2,
                //       softWrap: true,
                //       style: const TextStyle(color: myColors.textGrey),
                //     ),
                //   ),
                //   onTap: () {
                //     Navigator.pushNamed(context, GroupNotice.path,
                //         arguments: {
                //           'roomId': roomId,
                //         }).then((value) => getDetail());
                //   },
                // ),
                MenuItemData(
                  title: '群公告'.tr(),
                  subtitle: detail?.notice ?? '',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      GroupNotice.path,
                      arguments: {'roomId': roomId},
                    ).then((value) => getDetail());
                  },
                ),
                MenuItemData(
                  title: '群备注'.tr(),
                  content: Text(userDetail?.roomMark ?? detail?.roomMark ?? ''),
                  onTap: () {
                    logger.d(userDetail);
                    var mark = userDetail?.roomMark ?? '';
                    var name = detail?.roomName ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return SetNameInput(
                          title: '设置群备注'.tr(),
                          subTitle: '群聊备注仅自己可见'.tr(),
                          value: mark.isEmpty ? name : mark,
                          onEnter: (val) {
                            if (val == name) return Future.value(true);
                            return saveRoomMark(val);
                          },
                        );
                      }),
                    );
                  },
                ),
                if (identity == GRoomMemberIdentity.OWNER ||
                    identity == GRoomMemberIdentity.ADMIN)
                  MenuItemData(
                    title: '群管理'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        GroupManage.path,
                        arguments: {'roomId': roomId},
                      ).then((value) {
                        getDetail();
                        getUserList();
                      });
                    },
                    notReadNumber: groupApplyNotRead,
                  ),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                    title: '查找聊天内容'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SearchSelfMessagesPage.path,
                        arguments: {
                          'id': receiver,
                          'roomId': roomId,
                          'pairId': pairId,
                        },
                      );
                    }),
                if (FunctionConfig.cleanTalkHistory)
                  MenuItemData(
                    title: '清空聊天记录'.tr(),
                    onTap: removeHistoryConfirm,
                  ),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '消息免打扰'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _doNotDisturb,
                    onChanged: (val) {
                      setState(() {
                        _doNotDisturb = val;
                      });
                      MessageUtil.silence(pairId, val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '置顶聊天'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _setTop,
                    onChanged: (val) {
                      setState(() {
                        _setTop = val;
                      });
                      isTop(val);
                    },
                  ),
                ),
              ],
            ),
            MenuUl(
              children: [
                if (detail?.enableModifyRoomNickname != null &&
                    detail!.enableModifyRoomNickname == GSure.YES)
                  MenuItemData(
                    title: '我在本群的昵称'.tr(),
                    content: Text(
                      userDetail?.roomNickname ?? detail?.roomNickname ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: myColors.textGrey,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SetNameInput(
                            title: '我在本群的昵称'.tr(),
                            subTitle: '昵称修改后，只会在此群内显示，群内成员都可以看见'.tr(),
                            value: userDetail?.roomNickname ??
                                detail?.roomNickname ??
                                '',
                            onEnter: saveNickName,
                          );
                        }),
                      );
                    },
                  ),
                // MenuItemData(
                //   title: '显示群昵称'.tr(),
                //   arrow: false,
                //   content: AppSwitch(
                //     value: true,
                //     onChanged: (val) {},
                //   ),
                // ),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '投诉'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, ChatComplaint.path,
                        arguments: {'roomId': roomId});
                  },
                ),
                if (identity != GRoomMemberIdentity.OWNER)
                  MenuItemData(
                    title: '退出群聊'.tr(),
                    titleColor: myColors.red,
                    arrow: false,
                    onTap: delete,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
