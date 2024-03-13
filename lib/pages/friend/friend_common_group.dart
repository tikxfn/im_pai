import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

import '../../common/interceptor.dart';
import '../chat/chat_talk.dart';
import '../chat/widgets/chat_talk_model.dart';

class FriendCommonGroup extends StatefulWidget {
  const FriendCommonGroup({super.key});

  static const String path = 'friend/common/group';

  @override
  State<StatefulWidget> createState() => _FriendCommonGroupState();
}

class _FriendCommonGroupState extends State<FriendCommonGroup> {
  String userId = '';
  int limit = 20;
  List<ChatItemData> list = [];
  String keywords = '';

  //获取数据
  _getList() async {
    final api = UserApi(apiClient());
    try {
      var args = V1CommonFriendsArgs(userId: userId);
      final res = await api.userCommonRooms(args);
      if (res == null || !mounted) return;
      List<ChatItemData> l = [];
      for (var v in res.list) {
        l.add(ChatItemData(
          icons: [v.roomAvatar ?? ''],
          title: v.roomName ?? '',
          mark: v.roomMark ?? '',
          id: v.id,
        ));
      }
      setState(() {
        list = l;
      });
    } on ApiException catch (e) {
      onError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      userId = args['userId'];
      _getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardBlur(
      child: Scaffold(
        appBar: AppBar(title: Text('共同群聊'.tr())),
        body: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                hint: '请输入关键词搜索',
                onChanged: (val) {
                  setState(() {
                    keywords = val;
                  });
                },
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: [
                    for (var e in list)
                      if (e.title.contains(keywords) ||
                          e.mark.contains(keywords))
                        ChatItem(
                          data: e,
                          onTap: () {
                            // logger.d(e.id);
                            Navigator.pushNamed(
                              context,
                              ChatTalk.path,
                              arguments: ChatTalkParams(
                                roomId: e.id ?? '',
                                name: e.title,
                                mark: e.mark,
                              ),
                            );
                          },
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
