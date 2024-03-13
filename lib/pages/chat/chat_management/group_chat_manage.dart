import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupChatManage extends StatefulWidget {
  const GroupChatManage({super.key});

  static const String path = 'chat/chat_management/group_chat_manage';

  @override
  State<StatefulWidget> createState() {
    return _GroupChatManageState();
  }
}

class _GroupChatManageState extends State<GroupChatManage> {
  String roomId = '';
  int chatType = 0;

  //朋友列表
  List<GPrivilegeItem> list1 = [];

  //选择类型
  onChoose(GMessageType e) {
    if (chatType == -1) {
      chatType = GMessageType.values.fold(0, (previousValue, element) {
        return previousValue | messageType2int(element);
      });
      // chatType = e.all;
    }
    chatType = chatType ^ messageType2int(e);
    logger.i('---- $chatType');
    setState(() {});
  }

  //获取群信息
  getDetail() async {
    final api = RoomApi(apiClient());
    //获取群信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null) return;
      chatType = toInt(res.room!.allowChatType!);
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //限制群消息类型
  chatManage() async {
    confirm(
      context,
      title: '确定修改群成员允许发送信息类型？'.tr(),
      onEnter: () async {
        var api = RoomApi(apiClient());
        loading();
        try {
          await api.roomUpdateRoomInfo(
            V1UpdateRoomInfoArgs(
              roomId: roomId,
              allowChatType: UpdateRoomInfoArgsAllowChatType(
                allowChatType: chatType.toString(),
              ),
            ),
          );

          if (!mounted) return;
          tipSuccess('设置成功'.tr());
        } on ApiException catch (e) {
          onError(e);
        } finally {}
        loadClose();
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {'roomId': ''};
    if (args['roomId'] == null) return;
    roomId = args['roomId'];
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('修改群内允许的消息类型'.tr()),
        actions: [
          TextButton(
            onPressed: chatManage,
            child: Text(
              '确认'.tr(),
              style: TextStyle(
                color: myColors.blueTitle,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ThemeBody(
          topPadding: 0,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  '群成员允许发送以下消息类型'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              for (var e in GMessageType.values)
                if (e != GMessageType.AUDIO_CALL &&
                    e != GMessageType.NIL &&
                    e != GMessageType.VIDEO_CALL &&
                    e != GMessageType.FRIEND_APPLY_PASS)
                  GestureDetector(
                    onTap: () => onChoose(e),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: myColors.lineGrey,
                            width: .5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppCheckbox(
                            value: messageHasPower(chatType, e),
                            size: 25,
                            paddingLeft: 15,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: Text(
                                  messageType2text(e),
                                  style: TextStyle(
                                    color: textColor,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
