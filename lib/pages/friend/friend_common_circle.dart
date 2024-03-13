import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/help/group/group_home.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

class FriendCommonCircle extends StatefulWidget {
  const FriendCommonCircle({super.key});

  static const String path = 'friend/common/circle';

  @override
  State<StatefulWidget> createState() => _FriendCommonCircleState();
}

class _FriendCommonCircleState extends State<FriendCommonCircle> {
  String userId = '';
  int limit = 20;
  List<ChatItemData> list = [];
  String keywords = '';

  //获取数据
  _getList() async {
    final api = UserApi(apiClient());
    try {
      var args = V1CommonFriendsArgs(userId: userId);
      final res = await api.userCommonCircle(args);
      if (res == null || !mounted) return;
      List<ChatItemData> l = [];
      for (var v in res.list) {
        l.add(ChatItemData(
          icons: [v.image ?? ''],
          title: v.name ?? '',
          id: v.id,
          origin: v,
        ));
        logger.i(v);
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
          title: Text('共同圈子'.tr()),
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
                            FocusManager.instance.primaryFocus?.unfocus();
                            Navigator.pushNamed(context, GroupHome.path,
                                arguments: {
                                  'circleId': e.id,
                                  'detail': e.origin,
                                });
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
