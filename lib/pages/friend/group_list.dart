import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import '../../widgets/search_input.dart';

class GroupList extends StatefulWidget {
  const GroupList({super.key});

  static const String path = 'friends/group_list';

  @override
  State<StatefulWidget> createState() {
    return _GroupListState();
  }
}

class _GroupListState extends State<GroupList> {
  final TextEditingController _controller = TextEditingController();
  String keywords = '';
  static List<GRoomModel> groupData = [];

  //获取列表
  getList() async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomList({});
      if (!mounted) return;
      List<GRoomModel> newGroupData = [];
      for (var v in res?.list ?? []) {
        if (v.identity == GRoomMemberIdentity.OWNER) newGroupData.add(v);
      }
      groupData = newGroupData;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Scaffold(
      appBar: AppBar(
        title: Text('我的群组'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                controller: _controller,
                onChanged: (str) {
                  setState(() {
                    keywords = str;
                  });
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await getList();
                  },
                  child: ListView(
                    children: [
                      for (var e in groupData)
                        if (e.roomName!.toLowerCase().contains(keywords) ||
                            (e.roomMark ?? '').toLowerCase().contains(keywords))
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context, e);
                            },
                            child: ChatItem(
                              titleSize: 16,
                              avatarSize: 46,
                              paddingLeft: 16,
                              hasSlidable: false,
                              data: ChatItemData(
                                icons: [e.roomAvatar ?? ''],
                                id: e.roomId,
                                title: e.roomName ?? '',
                                room: true,
                              ),
                              end: Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Text(
                                  '${e.totalCount ?? ''} / ${e.peopleLimit} 人',
                                  style: TextStyle(
                                    color: myColors.subIconThemeColor,
                                  ),
                                ),
                              ),
                            ),
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
