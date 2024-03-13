import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class FriendApplyGroup extends StatefulWidget {
  const FriendApplyGroup({super.key});

  static const String path = 'friend/apply_group';

  @override
  State<FriendApplyGroup> createState() => _FriendApplyGroupState();
}

class _FriendApplyGroupState extends State<FriendApplyGroup> {
  //群组列表
  static List<GRoomMemberModel> newGroups = [];
  int limit = 30;
  final TextEditingController _controller = TextEditingController();
  String keywords = '';

  //获取列表
  Future<int> getList({bool init = true}) async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListUserApplyRoomJoin(
        V1ListUserApplyRoomJoinArgs(
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : newGroups.length.toString(),
          ),
        ),
      );
      if (res == null) return 0;
      if (init) {
        newGroups = res.list.toList();
        UnreadValue.groupMyApplyNotRead.value = 0;
      } else {
        newGroups.addAll(res.list);
      }

      if (!mounted) return 0;
      setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    // getList();
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
      body: Column(
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
            child: PagerBox(
              onInit: () async {
                //初始化

                return await getList();
              },
              onPullDown: () async {
                //下拉刷新

                return await getList();
              },
              onPullUp: () async {
                //上拉加载
                return await getList(init: false);
              },
              children: newGroups.map((v) {
                var name = v.roomName ?? '';
                var status = '';
                switch (v.applyStatus) {
                  case GApplyStatus.APPLY:
                    status = '申请中'.tr();
                    break;
                  case GApplyStatus.BAN:
                    break;
                  case GApplyStatus.NIL:
                    break;
                  case GApplyStatus.REFUSE:
                    status = '已拒绝'.tr();
                    break;
                  case GApplyStatus.SUCCESS:
                    status = '已通过'.tr();
                    break;
                }
                return name.contains(keywords)
                    ? ChatItem(
                        paddingVertical: 5,
                        hasSlidable: false,
                        titleSize: 17,
                        data: ChatItemData(
                          icons: [v.roomAvatar ?? ''],
                          title: v.roomName ?? '',
                          text: v.refuseContent ?? '',
                          room: true,
                        ),
                        end: Text(
                          status,
                          style: TextStyle(
                            fontSize: 16,
                            color: myColors.subIconThemeColor,
                          ),
                        ),
                      )
                    : Container();
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
