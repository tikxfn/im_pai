import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/chat/chat_management/group_notice_update.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupNotice extends StatefulWidget {
  const GroupNotice({super.key});

  static const String path = 'chat/chat_management/group_notice';

  @override
  State<StatefulWidget> createState() {
    return _GroupNoticeState();
  }
}

class _GroupNoticeState extends State<GroupNotice> {
  final TextEditingController _controller = TextEditingController();
  String roomId = '';
  String notice = '';
  GRoomModel? detail; //群信息
  GRoomMemberIdentity identity = GRoomMemberIdentity.MEMBER;

  //获取详情
  getDetail() async {
    final api = RoomApi(apiClient());
    //获取群信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null) return;
      setState(() {
        detail = res.room;
        notice = res.room?.notice ?? '';
        identity = res.my?.identity ?? GRoomMemberIdentity.MEMBER;
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
    getDetail();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('群公告'.tr()),
        actions: [
          if (identity == GRoomMemberIdentity.ADMIN ||
              identity == GRoomMemberIdentity.OWNER)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, GroupNoticeUpdate.path,
                    arguments: {
                      'notice': detail?.notice ?? '',
                      'roomId': roomId,
                    }).then((value) => getDetail());
              },
              child: Text(
                '编辑'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: myColors.primary,
                ),
              ),
            )
        ],
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: notice != ''
                ? Column(
                    children: [
                      // ChatItem(
                      //   avatarSize: 50,
                      //   hasSlidable: false,
                      //   data: ChatItemData(
                      //     icons: [testNetworkPhoto],
                      //     title: '发布人',
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 30,
                      // ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            notice,
                            style: TextStyle(
                              fontSize: 18,
                              color: myColors.iconThemeColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
          ),
        ),
      ),
    );
  }
}
