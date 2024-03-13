import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/form_widget.dart';

class ShareHome extends StatefulWidget {
  // 要分享的消息
  final List<Message> list;

  //分享显示文字
  final String shareText;

  //是否合并转发
  final bool merge;

  //是否是发送收藏
  final bool collect;

  //是否圈子限制人数分享，为true只能给单独的人分享
  final bool isCircleShare;

  const ShareHome({
    // required this.contentIds,
    required this.list,
    required this.shareText,
    this.merge = false,
    this.collect = false,
    this.isCircleShare = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _ShareHomeState();
  }
}

class _ShareHomeState extends State<ShareHome> {
  ShareListType type = ShareListType.topic;
  bool multipleChoice = false;
  List<ShareChoiceData> roomList = [];
  List<ShareChoiceData> list = [];
  List<ShareChoiceData> topicList = [];
  List<ShareChoiceData> choiceList = [];
  String keywords = '';

  // 圈子分享
  Future<bool> _circleShare(String userId, BuildContext context1) async {
    logger.i(userId);
    logger.i(widget.isCircleShare);

    var api = CircleApi(apiClient());
    try {
      await api.circleCircleShare(V1CircleShareArgs(
        circleId: widget.list[0].contentId.toString(),
        toUserId: userId,
      ));
      return true;
    } on ApiException catch (e) {
      onError(e);
      if (!context1.mounted) return false;
      Navigator.pop(context1);
      return false;
    }
  }

  //发送分享  发消息
  _sendShare(List<ShareChoiceData> users, BuildContext context1) async {
    List<String> ids = [];
    List<String> roomIds = [];
    for (var v in users) {
      if (v.room) {
        roomIds.add(v.id);
      } else {
        ids.add(v.id);
      }
    }

    loading();
    if (widget.isCircleShare) {
      if (!await _circleShare(ids[0], context1)) {
        return;
      }
    }
    await ApiRequest.apiSendMessage(
      list: widget.list,
      ids: ids,
      roomIds: roomIds,
    );
    loadClose();
    tipSuccess('分享成功'.tr());
    if (mounted) Navigator.pop(context1);
    if (mounted) Navigator.pop(context);
  }

  _init() async {
    await Future.wait(<Future>[
      _getFriends(),
      _getRooms(),
      _getTopic(),
    ]);
    setState(() {});
  }

  //获取好友列表
  _getFriends() async {
    var api = UserApi(apiClient());
    try {
      var res = await api.userListFriend(V1ListFriendArgs(
        pager: GPagination(
          limit: '1000000',
          offset: '0',
        ),
      ));
      if (res == null) return;
      List<ShareChoiceData> l = [];
      for (var v in res.list) {
        var mark = v.mark ?? '';
        var name = v.nickname ?? '';
        l.add(ShareChoiceData(
          id: v.id ?? '',
          avatar: v.avatar ?? '',
          nickName: mark.isEmpty ? name : mark,
          userName: name,
          room: false,
        ));
      }
      list = l;
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //获取群聊列表
  _getRooms() async {
    if (widget.isCircleShare) return;
    var api = RoomApi(apiClient());
    try {
      var res = await api.roomList({});
      if (res == null) return;
      List<ShareChoiceData> l = [];
      List<GMessageType> types = [];
      for (var v in widget.list) {
        types.add(v.type!);
      }
      for (var v in res.list) {
        bool manage = v.identity == GRoomMemberIdentity.ADMIN ||
            v.identity == GRoomMemberIdentity.OWNER; //用户身份
        int allowType = toInt(v.allowChatType); //允许的消息类型
        bool prohibition =
            toInt(date2time(null)) - toInt(v.prohibitionTime) > 0 ||
                toBool(v.enableProhibition);
        bool canSend = true;
        for (var type in types) {
          //判断当前用户是否是管理员或者群组，群聊是否禁言，是否允许发送该类型的消息
          if (!manage && (prohibition || messageHasPower(allowType, type))) {
            canSend = false;
            break;
          }
        }
        if (canSend) continue;
        var mark = v.roomMark ?? '';
        var name = v.roomName ?? '';
        l.add(ShareChoiceData(
          id: v.id ?? '',
          avatar: v.roomAvatar ?? '',
          nickName: mark.isEmpty ? name : mark,
          userName: name,
          room: true,
        ));
      }
      roomList = l;
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //获取最近聊天
  _getTopic() async {
    List<ShareChoiceData> l = [];
    var channels = await MessageUtil.listAllChannel();
    for (var e in channels) {
      var v = channel2chatItem(e);
      if (widget.isCircleShare && v.room) continue;
      l.add(ShareChoiceData(
        id: v.id!,
        avatar: v.icons.isEmpty ? '' : v.icons[0],
        nickName: v.mark.isEmpty ? v.title : v.mark,
        userName: v.title,
        room: v.room,
      ));
    }
    setState(() {
      topicList = l;
    });
  }

  //选择事件
  choose(ShareChoiceData data) {
    if (multipleChoice) {
      if (choiceList.contains(data)) {
        choiceList.remove(data);
      } else {
        choiceList.add(data);
      }
      setState(() {});
    } else {
      shareDialog(data);
    }
  }

  //弹窗
  shareDialog(ShareChoiceData? user) {
    var users = user != null ? [user] : choiceList;
    if (users.isEmpty) return;
    showDialog(
      context: context,
      builder: (context1) {
        return _shareWidget(users, context1);
      },
    );
  }

  //分享弹窗组件
  Widget _shareWidget(List<ShareChoiceData> users, BuildContext context1) {
    var myColors = ThemeNotifier();
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/my/wallet_bg.png')),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '发送给：'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (users.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var v in users)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: AppAvatar(
                                    list: [v.avatar],
                                    size: 40,
                                    userName: v.userName,
                                    userId: v.id,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (users.length == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            AppAvatar(
                              list: [users[0].avatar],
                              size: 40,
                              userName: users[0].userName,
                              userId: users[0].id,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: Text(
                                users[0].nickName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    Text(
                      widget.shareText,
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: myColors.lineGrey,
                      width: .5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _shareButton(
                        '取消'.tr(),
                        color: myColors.textGrey,
                        onTap: () {
                          Navigator.pop(context1);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: _shareButton(
                        '确定'.tr(),
                        border: false,
                        onTap: () {
                          _sendShare(users, context1);
                        },
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

  //分享底部按钮
  Widget _shareButton(
    String title, {
    Color? color,
    bool border = true,
    Function()? onTap,
  }) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: border
              ? Border(
                  right: BorderSide(
                    color: myColors.lineGrey,
                    width: .5,
                  ),
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: color ?? myColors.linkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget changeBtn({
    required String title,
    bool active = false,
    Function()? onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 15, 15, 10),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: active ? FontWeight.bold : null,
            color: textColor,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color chatInputColor = myColors.chatInputColor;
    Color primary = myColors.primary;
    var originList = [];
    if (!widget.isCircleShare) {
      originList = topicList;
      if (type == ShareListType.friend) {
        originList = list;
      } else if (type == ShareListType.room) {
        originList = roomList;
      }
    } else {
      originList = list;
    }
    List<ShareChoiceData> showList = [];
    for (var v in originList) {
      if (v.nickName.contains(keywords) || v.userName.contains(keywords)) {
        showList.add(v);
      }
    }

    return ThemeImage(
      child: Scaffold(
        appBar: AppBar(
          title: Text('选择一个聊天'.tr()),
          leading: TextButton(
            onPressed: () {
              if (multipleChoice) {
                setState(() {
                  multipleChoice = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              multipleChoice ? '取消'.tr() : '关闭'.tr(),
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          actions: [
            if (!widget.isCircleShare)
              TextButton(
                onPressed: () {
                  if (multipleChoice) {
                    shareDialog(null);
                  } else {
                    setState(() {
                      multipleChoice = true;
                    });
                  }
                },
                child: Text(
                  multipleChoice ? '发送'.tr() : '多选'.tr(),
                  style: TextStyle(
                    color: multipleChoice ? primary : textColor,
                  ),
                ),
              ),
          ],
        ),
        body: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              children: [
                if (multipleChoice)
                  //已选的朋友
                  // Container(
                  //   color: myColors.white,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                            for (var v in choiceList)
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: AppAvatar(
                                  list: [v.avatar],
                                  size: 40,
                                  userName: v.userName,
                                  userId: v.id,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SearchInput(
                  onChanged: (val) {
                    setState(() {
                      keywords = val;
                    });
                  },
                ),
                // //最近转发
                // Container(
                //   padding: const EdgeInsets.only(
                //     left: 15,
                //     right: 15,
                //     top: 5,
                //     bottom: 20,
                //   ),
                //   decoration: const BoxDecoration(
                //     color: myColors.white,
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         '最近转发',
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       const SizedBox(height: 10),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           for (var i = 0; i < 5; i++)
                //             const AvatarName(
                //               avatars: [testNetworkPhoto],
                //               name: '用户昵称',
                //               size: 50,
                //               maxLines: 2,
                //             ),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: widget.isCircleShare
                      ? changeBtn(
                          title: ShareListType.friend.toChar,
                          active: type == ShareListType.friend,
                          onTap: () {
                            setState(() {
                              type = ShareListType.friend;
                            });
                          },
                          textColor: textColor,
                        )
                      : Row(
                          children: ShareListType.values.map((e) {
                            return changeBtn(
                              title: e.toChar,
                              active: type == e,
                              onTap: () {
                                setState(() {
                                  type = e;
                                });
                              },
                              textColor: textColor,
                            );
                          }).toList(),
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    itemCount: showList.length,
                    itemBuilder: (context, i) {
                      var v = showList[i];
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          choose(v);
                        },
                        child: Row(
                          children: [
                            if (multipleChoice)
                              AppCheckbox(
                                value: choiceList.contains(v),
                                size: 20,
                                paddingRight: 10,
                              ),
                            Expanded(
                              flex: 1,
                              child: ChatItem(
                                onTap: () => choose(v),
                                hasSlidable: false,
                                paddingLeft: 15,
                                titleSize: 16,
                                avatarSize: 46,
                                data: ChatItemData(
                                  icons: [v.avatar],
                                  title: v.userName,
                                  mark: v.nickName,
                                  id: v.id,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

enum ShareListType {
  topic,
  friend,
  room,
}

extension ShareListTypeExt on ShareListType {
  String get toChar {
    switch (this) {
      case ShareListType.topic:
        return '最近聊天'.tr();
      case ShareListType.friend:
        return '通讯录'.tr();
      case ShareListType.room:
        return '我的群聊'.tr();
    }
  }
}

class ShareChoiceData {
  String id;
  String avatar;
  String nickName;
  String userName;
  bool room;

  ShareChoiceData({
    required this.id,
    required this.avatar,
    required this.nickName,
    required this.userName,
    this.room = false,
  });
}
