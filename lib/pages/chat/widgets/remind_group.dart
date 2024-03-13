import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../common/func.dart';
import '../../../notifier/theme_notifier.dart';
import '../../../widgets/pager_box.dart';

class RemindGroup extends StatefulWidget {
  final String roomId;
  final Function(List<ChatItemData>)? onConfirm;

  const RemindGroup({
    required this.roomId,
    this.onConfirm,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _RemindGroupState();
}

class _RemindGroupState extends State<RemindGroup> {
  String keywords = '';
  List<ChatItemData> list = [];
  List<ChatItemData> choice = [];
  bool check = false;
  int limit = 30;
  bool hasEveryone = false; //是否显示所有人

  //通过id判断@列表是否存该用户
  bool remindContainsId(String id) {
    for (var v in choice) {
      if (v.id == id) return true;
    }
    return false;
  }

  //获取群详情
  getDetail() async {
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: widget.roomId));
      if (res == null) return;
      setState(() {
        //获取自己在群里的身份
        hasEveryone = res.my!.identity == GRoomMemberIdentity.ADMIN ||
            res.my!.identity == GRoomMemberIdentity.OWNER;
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListMember(V1ListMemberRoomArgs(
        keywords: keywords,
        roomId: widget.roomId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : list.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<ChatItemData> l = [];
      for (var v in res?.list ?? []) {
        if (v.userId == Global.user!.id) continue;
        l.add(ChatItemData(
          icons: [v.avatar ?? ''],
          id: v.userId,
          title: v.nickname ?? '',
          mark: v.roomNickname ?? '',
        ));
      }
      // List<GRoomMemberModel> l = res.list.toList();
      setState(() {
        if (init) {
          list = l;
        } else {
          list.addAll(l);
        }
      });
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  //发送
  choiceOver(List<ChatItemData> sendList) async {
    if (widget.onConfirm != null) {
      widget.onConfirm!(sendList);
    }
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    getDetail();
    // choice = widget.choice;
    // getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return ThemeImage(
      child: KeyboardBlur(
        child: Scaffold(
          appBar: AppBar(
            leading: check
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        check = false;
                        choice = [];
                      });
                    },
                    child: Text(
                      '取消'.tr(),
                      style: TextStyle(
                        color: myColors.red,
                      ),
                    ),
                  )
                : null,
            title: const Text('选择提醒的人'),
            actions: [
              if (check)
                TextButton(
                  onPressed: () {
                    choiceOver(choice);
                  },
                  child: Text('发送'.tr()),
                ),
              if (!check)
                TextButton(
                  onPressed: () {
                    setState(() {
                      check = true;
                    });
                  },
                  child: Text('多选'.tr()),
                ),
            ],
          ),
          body: Column(
            children: [
              SearchInput(
                onChanged: (str) {
                  // setState(() {
                  //   keywords = str;
                  // });
                },
                onSubmitted: (str) {
                  keywords = str;
                  _getList(init: true, load: true);
                },
              ),
              if (hasEveryone)
                MenuUl(
                  marginTop: 0,
                  marginBottom: 10,
                  children: [
                    MenuItemData(
                      title: '@所有人'.tr(),
                      onTap: () {
                        check = false;
                        choice = [];
                        choiceOver([
                          ChatItemData(
                            icons: [''],
                            id: '-1',
                            title: '所有人'.tr(),
                            mark: '所有人'.tr(),
                          )
                        ]);
                      },
                      arrow: false,
                    ),
                  ],
                ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  pullBottom: 40,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  limit: limit,
                  onInit: () async {
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    for (var e in list)
                      if (e.title.toLowerCase().contains(keywords) ||
                          e.mark.toLowerCase().contains(keywords))
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!check) {
                              choiceOver([e]);
                              return;
                            }
                            setState(() {
                              if (remindContainsId(e.id!)) {
                                choice.remove(e);
                              } else {
                                choice.add(e);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              if (check)
                                AppCheckbox(
                                  paddingLeft: 10,
                                  value: remindContainsId(e.id!),
                                ),
                              Expanded(
                                flex: 1,
                                child: ChatItem(
                                  titleSize: 16,
                                  avatarSize: 38,
                                  paddingLeft: 10,
                                  hasSlidable: false,
                                  data: e,
                                ),
                              ),
                            ],
                          ),
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
