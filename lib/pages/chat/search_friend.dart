import 'dart:async';

import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_model.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/up_loading.dart';
import 'package:provider/provider.dart';

import '../../notifier/friend_list_notifier.dart';
import '../../widgets/chat_item.dart';
import '../../widgets/light_text.dart';
import 'chat_talk.dart';

class SearchFriend extends StatefulWidget {
  const SearchFriend({super.key});

  static const String path = 'search/friend';

  @override
  State<SearchFriend> createState() => _SearchFriendState();
}

class _SearchFriendState extends State<SearchFriend> {
  final TextEditingController _controller = TextEditingController();
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier(LoadStatus.nil);
  Timer? timer;
  List<UserInfo> _friendList = [];

  // 搜索事件
  _search(String val) async {
    if (val.isEmpty) {
      loadStatus.value = LoadStatus.nil;
      _friendList.clear();
      setState(() {});
      return;
    }
    loadStatus.value = LoadStatus.loading;
    // var notifier = FriendListNotifier();
    // if (notifier.list.isEmpty) {
    //   await notifier.refresh();
    // }
    List<UserInfo> l = FriendListNotifier().search(_controller.text);
    loadStatus.value = l.isEmpty ? LoadStatus.no : LoadStatus.nil;
    setState(() {
      _friendList = l;
    });
  }

  // 输入改变事件
  _inputChange(String val) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () => _search(val));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      String keywords = args['keywords'] ?? '';
      if (keywords.isNotEmpty) {
        _controller.text = keywords;
        _search(keywords);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardBlur(
      child: Scaffold(
        body: SafeArea(
          child: ThemeBody(
            child: Column(
              children: [
                SearchInput(
                  hint: '查找联系人',
                  controller: _controller,
                  showButton: true,
                  sureStr: '取消',
                  buttonTap: () => Navigator.pop(context),
                  onChanged: _inputChange,
                  onSubmitted: _search,
                ),
                ValueListenableBuilder(
                  valueListenable: loadStatus,
                  builder: (context, value, _) {
                    if (value == LoadStatus.nil) return Container();
                    return UpLoading(value);
                  },
                ),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: _friendList.map((e) {
                      return SearchFriendItem(e, _controller.text);
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchFriendItem extends StatelessWidget {
  final UserInfo data;
  final String keywords;

  const SearchFriendItem(this.data, this.keywords, {super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    var e = data.toChatItem();
    var title = '${e.title}${e.mark.isNotEmpty ? '(${e.mark})' : ''}';
    return ChatItem(
      hasSlidable: false,
      onTap: () {
        var params = ChatTalkParams(
          name: e.title,
          mark: e.mark,
          userNumber: e.userNumber,
          circleGuarantee: e.circleGuarantee,
          remindId: e.atMessageId,
          readId: e.readId,
          onlyName: e.onlyName,
          vip: e.vip,
          vipLevel: e.vipLevel,
        );
        if (e.room) params.roomId = e.id ?? '';
        if (!e.room) params.receiver = e.id ?? '';
        Navigator.pushNamed(
          context,
          ChatTalk.path,
          arguments: params,
        );
        // Navigator.pushNamedAndRemoveUntil(
        //   context,
        //   ChatTalk.path,
        //   ModalRoute.withName(Tabs.path),
        //   arguments: args,
        // );
      },
      border: false,
      data: e,
      titleWidget: LightText(
        title,
        keywords,
        style: TextStyle(
          color: textColor,
          fontSize: 17,
        ),
      ),
    );
  }
}
