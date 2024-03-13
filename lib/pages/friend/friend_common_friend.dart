import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class FriendCommonFriend extends StatefulWidget {
  const FriendCommonFriend({super.key});

  static const String path = 'friend/common/friend';

  @override
  State<StatefulWidget> createState() => _FriendCommonFriendState();
}

class _FriendCommonFriendState extends State<FriendCommonFriend> {
  String userId = '';
  int limit = 20;
  List<ChatItemData> list = [];
  String keywords = '';

  //获取数据
  _getList() async {
    final api = UserApi(apiClient());
    try {
      var args = V1CommonFriendsArgs(userId: userId);
      final res = await api.userCommonFriends(args);
      if (res == null || !mounted) return;
      List<ChatItemData> l = [];
      for (var v in res.list) {
        l.add(ChatItemData(
          id: v.id,
          icons: [v.avatar ?? ''],
          title: v.nickname ?? '',
          mark: v.mark ?? '',
          origin: v,
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
        appBar: AppBar(
          title: Text('共同好友'.tr()),
        ),
        body: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                hint: '请输入关键词搜索'.tr(),
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
                            Navigator.pushNamed(
                              context,
                              FriendDetails.path,
                              arguments: {
                                'id': e.id,
                                'removeToTabs': true,
                                'detail': e.origin,
                                'isFriend': true,
                              },
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
