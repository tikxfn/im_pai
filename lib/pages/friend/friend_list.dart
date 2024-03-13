import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';

class FriendList extends StatefulWidget {
  //对话id

  const FriendList({
    super.key,
  });

  static const String path = 'friends/list';

  @override
  State<StatefulWidget> createState() {
    return _FriendListState();
  }
}

class _FriendListState extends State<FriendList> {
  String keywords = '';
  String count = '';
  String receiver = '';
  String roomId = '';

  //获取列表
  // getList() async {
  //   final api = UserApi(apiClient());
  //   try {
  //     final res = await api.userListFriend(V1ListFriendArgs(
  //       pager: GPagination(
  //         limit: '1000000',
  //         offset: '0',
  //       ),
  //     ));
  //     if (res == null) return;
  //     List<UserInfo> list = [];
  //     count = res.total ?? '0';
  //     for (var v in res.list) {
  //       list.add(getFriendByModal(v));
  //     }
  //     if (!mounted) return;
  //     FriendListNotifier().list = list;
  //   } on ApiException catch (e) {
  //     onError(e);
  //   } finally {}
  // }

  //发送分享  发消息
  _sendShare(ChatItemData e) async {
    var pairId = '';
    var msg = Message()
      ..senderUser = getSenderUser()
      ..type = GMessageType.USER_CARD
      ..content = e.origin.nickname
      ..fileUrl = e.icons[0]
      ..contentId = toInt(e.id);
    if (roomId.isNotEmpty) {
      pairId = generatePairId(0, toInt(roomId));
      msg.receiverRoomId = toInt(roomId);
    } else if (receiver.isNotEmpty) {
      pairId = generatePairId(toInt(Global.user!.id), toInt(receiver));
      msg.receiverUserId = toInt(receiver);
    }
    msg.pairId = pairId;
    if (roomId.isEmpty && receiver.isEmpty) {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) {
            return ShareHome(
              shareText: '[名片转发]'.tr(),
              list: [msg],
            );
          },
        ),
      );
      return;
    }
    loading();
    try {
      await MessageUtil.send(msg);
      loadClose();
      tipSuccess('分享成功'.tr());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      loadClose();
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      receiver = args['receiver'] ?? '';
      roomId = args['roomId'] ?? '';
      logger.i(receiver);
      // getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FriendListNotifier>();
    // final list = context.watch<FriendListNotifier>().list;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '通讯录'.tr(),
        ),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
            child: Column(
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: SearchInput(
                    height: 45,
                    radius: 30,
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 0,
                      bottom: 5,
                    ),
                    onChanged: (str) {
                      setState(() {
                        keywords = str;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ContactList(
                    // showCount: true,
                    // count: count,
                    list: const [],
                    orderList: [
                      for (var e in notifier.search(keywords))
                        ContractData(
                          name: (e.mark ?? '').isNotEmpty
                              ? e.mark ?? ''
                              : e.nickname ?? '',
                          widget: ChatItem(
                            titleSize: 16,
                            avatarSize: 46,
                            avatarTopPadding: 8,
                            avatarFrameSizeHight: 24,
                            avatarFrameSizeWidth: 14,
                            paddingLeft: 16,
                            hasSlidable: false,
                            data: e.toChatItem(),
                            onTap: () {
                              _sendShare(e.toChatItem());
                              // Adapter.navigatorTo(
                              //   FriendDetails.path,
                              //   arguments: {'id': e.id},
                              // ).then((value) {
                              //   // getList();
                              // });
                            },
                          ),
                        )
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
