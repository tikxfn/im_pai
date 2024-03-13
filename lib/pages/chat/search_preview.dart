import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/search_all_message.dart';
import 'package:unionchat/pages/chat/search_friend.dart';
import 'package:unionchat/pages/collect/collect_home.dart';
import 'package:unionchat/pages/friend/friend_detail.dart';
import 'package:unionchat/pages/friend/friend_group.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/note/note_home.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:unionchat/widgets/up_loading.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/friend_list_notifier.dart';
import '../../widgets/chat_item.dart';

class SearchPreview extends StatefulWidget {
  const SearchPreview({super.key});

  static const String path = 'search/preview';

  @override
  State<SearchPreview> createState() => _SearchPreviewState();
}

class _SearchPreviewState extends State<SearchPreview> {
  String _keywords = '';
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier(LoadStatus.nil);
  Timer? timer;
  List<UserInfo> _friendList = [];

  List<SearchResultItem> _topicList = [];
  List<Notes> _noteList = [];
  List<GFavoritesModel> _collectList = [];
  List<GRoomModel> _roomList = [];
  bool _noSearch = false;

  //搜索用户
  searchUser() async {
    final api = UserApi(apiClient());
    loading();
    try {
      final res = await api.userFindUserByKeyword(
        V1FindUserByKeywordArgs(
          keyword: _keywords,
        ),
      );
      if (res == null) return;
      if (res.user == null) {
        setState(() {
          _noSearch = true;
        });
        return;
      }
      String friendFrom = 'ACCOUNT';
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
    } on ApiException catch (e) {
      setState(() {
        _noSearch = true;
      });
      onError(e);
    } finally {
      loadClose();
    }
  }

  //搜索群聊
  _searchGroup() async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomList({});
      if (res == null) return;
      List<GRoomModel> l = [];
      for (var v in res.list) {
        var name = (v.roomName ?? '').toLowerCase();
        var mark = (v.roomMark ?? '').toLowerCase();
        if (name.contains(_keywords) || mark.contains(_keywords)) {
          l.add(v);
        }
      }
      setState(() {
        _roomList = l;
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //搜索收藏
  _searchCollect() async {
    final api = UserFavoritesApi(apiClient());
    try {
      var args = V1ListUserFavoritesArgs(
        keyword: _keywords,
        pager: GPagination(
          limit: '3',
          offset: '0',
        ),
      );
      final res = await api.userFavoritesListFavorites(args);
      if (res == null || !mounted) return 0;
      setState(() {
        _collectList = res.list.toList();
      });
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // 搜索笔记
  _searchNote() async {
    _noteList = await NotesUtils.listNotes(3, keywords: _keywords, offset: 0);
  }

  // 搜索聊天列表
  _searchTopic() async {
    _topicList = await MessageUtil.searchMessage(_keywords);
    setState(() {});
  }

  // 搜索好友
  _searchFriend() async {
    setState(() {
      _friendList = FriendListNotifier().search(_keywords, need: 3);
    });
  }

  // 搜索事件
  _search(String val) async {
    _keywords = val;
    _noSearch = false;
    if (val.isEmpty) {
      _friendList.clear();
      _noteList.clear();
      _topicList.clear();
      _collectList.clear();
      _roomList.clear();
      loadStatus.value = LoadStatus.nil;
      setState(() {});
      return;
    }
    loadStatus.value = LoadStatus.loading;
    List<Future> futures = [
      _searchFriend(),
      _searchTopic(),
      _searchNote(),
      _searchCollect(),
      _searchGroup(),
    ];
    await Future.wait(futures);
    loadStatus.value = LoadStatus.nil;
  }

  // 输入改变事件
  _inputChange(String val) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 500), () => _search(val));
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return KeyboardBlur(
      child: ThemeImage(
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                SearchInput(
                  inputColor: myColors.white,
                  autofocus: true,
                  showButton: true,
                  sureStr: '取消',
                  sureStrColor: myColors.iconThemeColor,
                  buttonTap: () => Navigator.pop(context),
                  onChanged: _inputChange,
                  onSubmitted: _search,
                ),
                Expanded(
                  flex: 1,
                  child: ThemeBody(
                    topPadding: 16,
                    child: ListView(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: loadStatus,
                          builder: (context, value, _) {
                            if (value != LoadStatus.loading) return Container();
                            return UpLoading(value);
                          },
                        ),
                        if (_friendList.isEmpty &&
                            _roomList.isEmpty &&
                            _topicList.isEmpty &&
                            _noteList.isEmpty &&
                            _collectList.isEmpty &&
                            _keywords.isNotEmpty)
                          InkWell(
                            onTap: _noSearch ? null : searchUser,
                            child: tagWidget(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '网络查找:${_noSearch ? '暂无搜索结果'.tr() : _keywords}',
                                      // _noSearch
                                      //     ? '网络查找:'.tr(
                                      //         args: ['暂无搜索结果'.tr()],
                                      //       )
                                      //     : '网络查找:'.tr(
                                      //         args: [_keywords],
                                      //       ),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _noSearch
                                            ? myColors.textGrey
                                            : myColors.blueTitle,
                                      ),
                                    ),
                                  ),
                                  if (!_noSearch)
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: myColors.blueTitle,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),

                        // 搜索联系人
                        if (_friendList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _friendList.map((e) {
                                    return SearchFriendItem(e, _keywords);
                                  }).toList(),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // if (_friendList.length >= 3)
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      SearchFriend.path,
                                      arguments: {
                                        'keywords': _keywords,
                                      },
                                    );
                                  },
                                  child: tagWidget(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '查找更多联系人',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: myColors.blueTitle,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 搜索群聊
                        if (_roomList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _roomList.map((e) {
                                    return FriendGroupItem(e, _keywords);
                                  }).toList(),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // if (_friendList.length >= 3)
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      FriendGroup.path,
                                      arguments: {
                                        'keywords': _keywords,
                                      },
                                    );
                                  },
                                  child: tagWidget(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '查找更多群组',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: myColors.blueTitle,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 搜索聊天列表
                        if (_topicList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _topicList.map((e) {
                                    return SearchTopicItem(e, _keywords);
                                  }).toList(),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // if (_topicList.length >= 3)
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      SearchAllMessagePage.path,
                                      arguments: {
                                        'keywords': _keywords,
                                      },
                                    );
                                  },
                                  child: tagWidget(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '查找更多聊天记录',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: myColors.blueTitle,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 搜索笔记
                        if (_noteList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _noteList.map((e) {
                                    var data = notes2noteItem(e);
                                    return ChatItem(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          // NoteDetail.path,
                                          NoteDetailPro.path,
                                          arguments: {'id': e.id},
                                        );
                                      },
                                      hasSlidable: false,
                                      border: false,
                                      titleSize: 17,
                                      data: ChatItemData(
                                        icons: [data.image],
                                        title: data.title
                                            .replaceAll(' ', '')
                                            .replaceAll('\n', ''),
                                        mark: data.meta,
                                        text: data.text
                                            .replaceAll(' ', '')
                                            .replaceAll('\n', ''),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                // if (_noteList.length >= 3)
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      NoteHome.path,
                                      arguments: {
                                        'keywords': _keywords,
                                        'share': true,
                                      },
                                    );
                                  },
                                  child: tagWidget(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '查找更多笔记',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: myColors.blueTitle,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: myColors.blueTitle,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 搜索收藏
                        if (_collectList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: _collectList.map((e) {
                                //     // var data = json2note(e.content!);
                                //     return ChatItem(
                                //       onTap: (){
                                //         Navigator.pushNamed(
                                //           context,
                                //           NoteDetail.path,
                                //           arguments: {'id': e.id},
                                //         );
                                //       },
                                //       hasSlidable: false,
                                //       border: true,
                                //       data: ChatItemData(
                                //         icons: [e.chat?.senderAvatar??''],
                                //         title: e.chat?.senderNickname ?? '',
                                //         mark: e.chat?.senderRoomNickname ?? '',
                                //         text: data.text,
                                //       ),
                                //     );
                                //   }).toList(),
                                // ),
                                // if (_noteList.length >= 3)
                                const SizedBox(
                                  height: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      CollectHome.path,
                                      arguments: {'keywords': _keywords},
                                    );
                                  },
                                  child: tagWidget(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            style: TextStyle(
                                              color: myColors.green,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '我的收藏有 ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: myColors.blueTitle,
                                                ),
                                              ),
                                              TextSpan(
                                                text: _collectList.length == 1
                                                    ? '1'
                                                    : '多',
                                                style: TextStyle(
                                                  color: myColors.red,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ' 条匹配，前往查看详情',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: myColors.blueTitle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Text(
                                        //   '有 ${_collectList.length == 1 ? '1' : '多'} 条匹配，前往查看详情',
                                        //   style: const TextStyle(
                                        //     color: myColors .green,
                                        //   ),
                                        // ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: myColors.blueTitle,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tagWidget({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: myColors.chatInputColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
