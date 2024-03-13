import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/chat/chat_management/group_card.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class FriendSearch extends StatefulWidget {
  const FriendSearch({super.key});

  static const String path = 'friends/search';

  @override
  State<FriendSearch> createState() => _FriendSearchState();
}

class _FriendSearchState extends State<FriendSearch> {
  //文本控制器
  final TextEditingController _textController = TextEditingController();

  //是否进行搜索
  bool _isSearch = false;

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

//搜索用户
  searchUser() async {
    final api = UserApi(apiClient());
    loading();
    try {
      final res = await api.userFindUserByKeyword(
        V1FindUserByKeywordArgs(
          keyword: _textController.text,
        ),
      );
      if (res == null) return;
      if (res.user == null) {
        setState(() {
          _isSearch = true;
        });
      }
      if (res.user != null && mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
        String friendFrom = '';
        switch (res.from) {
          case GFriendFrom.ID:
            friendFrom = 'ID';
            break;
          case GFriendFrom.QR:
            friendFrom = 'QR';
            break;
          case GFriendFrom.PHONE:
            friendFrom = 'PHONE';
            break;
          case GFriendFrom.RECOMMEND:
            friendFrom = 'RECOMMEND';
            break;
          case GFriendFrom.ROOM:
            friendFrom = 'ROOM';
            break;
          case GFriendFrom.NIL:
            break;
          case GFriendFrom.ACCOUNT:
            friendFrom = 'ACCOUNT';
            break;
          case GFriendFrom.NUMBER:
            friendFrom = 'NUMBER';
            break;
        }
        if (mounted) {
          Navigator.pushNamed(
            context,
            FriendDetails.path,
            arguments: {
              'id': res.user!.id,
              'friendFrom': friendFrom,
              'detail': res.user,
            },
          );
        }
      }
    } on ApiException catch (e) {
      setState(() {
        _isSearch = true;
      });
      onError(e);
    } finally {
      loadClose();
    }
  }

//搜索群
  searchRoom() async {
    final api = RoomApi(apiClient());
    loading();
    try {
      final res = await api.roomFindRoomById(
        V1FindRoomByIdArgs(
          roomId: _textController.text,
          roomFrom: GRoomFrom.ID,
        ),
      );
      if (res == null) return;
      if (res.room == null) {
        setState(() {
          _isSearch = true;
        });
      }
      if (res.room != null && mounted) {
        FocusManager.instance.primaryFocus?.unfocus();
        Navigator.pushNamed(context, GroupCard.path, arguments: {
          'roomId': res.room!.roomId,
          'isCard': false,
          'roomFrom': 'ID'
        });
      }
    } on ApiException catch (e) {
      setState(() {
        _isSearch = true;
      });
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: KeyboardBlur(
        child: Column(
          children: [
            Container(
              color: bgColor,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: SearchInput(
                        autofocus: true,
                        controller: _textController,
                        onChanged: (value) {
                          setState(() {
                            _isSearch = false;
                          });
                        },
                        onSubmitted: (val) => searchUser(),
                        hint: '账号/手机号'.tr(),
                      ),
                    ),
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text('取消'.tr()),
                    ),
                  ],
                ),
              ),
            ),
            if (_textController.text.isEmpty)
              Container(color: myColors.pageBackground),
            if (_textController.text.isNotEmpty && !_isSearch)
              searchBar(textColor),
            if (_textController.text.isNotEmpty && _isSearch)
              searchResult(textColor),
          ],
        ),
      ),
    );
  }

//搜索列
  searchBar(Color textColor) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            searchUser();
          },
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: Row(
              children: [
                Image.asset(
                  assetPath('images/search_friend.png'),
                  height: 30,
                  width: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  '搜索好友:'.tr(
                    args: [_textController.text],
                  ),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        // GestureDetector(
        //   onTap: () {
        //     searchRoom();
        //   },
        //   child: ChatItem(
        //     hasSlidable: false,
        //     data: ChatItemData(
        //       icons: [''],
        //       title: '搜索群id:'.tr(args: [_textController.text]),
        //     ),
        //   ),
        // ),
      ],
    );
  }

//无内容列
  Widget searchResult(textColor) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        '暂无搜索结果'.tr(),
        style: TextStyle(
          color: textColor,
        ),
      ),
    );
  }
}
