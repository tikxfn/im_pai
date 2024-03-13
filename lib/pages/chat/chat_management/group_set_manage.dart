import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/chat/chat_management/group_set_manage_update.dart';
import 'package:unionchat/widgets/avatar_name.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class GroupSetManage extends StatefulWidget {
  const GroupSetManage({super.key});

  static const String path = 'chat/chat_management/group_set_manage';

  @override
  State<StatefulWidget> createState() {
    return _GroupSetManageState();
  }
}

class _GroupSetManageState extends State<GroupSetManage> {
  String keywords = '';
  String roomId = ''; //群id
  int limit = 50;
  double size = 44; //头像大小

  List<GRoomMemberModel> userList = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomListMember(V1ListMemberRoomArgs(
        keywords: keywords,
        isAdmin: GSure.YES,
        roomId: roomId,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : userList.length.toString(),
        ),
      ));
      if (!mounted) return 0;
      List<GRoomMemberModel> l = res?.list.toList() ?? [];
      setState(() {
        if (init) {
          userList = l;
        } else {
          userList.addAll(l);
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

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('管理员()'.tr(args: [userList.length.toString()])),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SearchInput(
                      onChanged: (str) {
                        setState(() {
                          keywords = str;
                          if (keywords == '') {
                            _getList(init: true);
                          }
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: keywords != ''
                        ? () {
                            _getList(init: true);
                          }
                        : null,
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        fontSize: 16,
                        color: keywords != ''
                            ? myColors.primary
                            : myColors.textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                flex: 1,
                child: PagerBox(
                  pullBottom: 40,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  limit: limit,
                  onInit: () async {
                    if (!mounted) return 0;
                    dynamic args = ModalRoute.of(context)!.settings.arguments;
                    if (args == null) return 0;
                    if (args['roomId'] != null) roomId = args['roomId'];
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList();
                  },
                  children: [
                    RowList(
                      lineSpacing: 10,
                      rowNumber: 5,
                      children: [
                        //添加成员
                        CircularButton(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              GroupSetManageUpdate.path,
                              arguments: {
                                'roomId': roomId,
                                'isSetManage': true,
                              },
                            ).then((value) {
                              _getList(init: true);
                            });
                          },
                          title: '添加管理员'.tr(),
                          size: size,
                          nameColor: textColor,
                          child: Icon(
                            Icons.add,
                            color: myColors.lineGrey,
                          ),
                        ),
                        //移除成员
                        CircularButton(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              GroupSetManageUpdate.path,
                              arguments: {
                                'roomId': roomId,
                                'isSetManage': false,
                              },
                            ).then((value) {
                              _getList(init: true);
                            });
                          },
                          title: '移除管理员'.tr(),
                          size: size,
                          nameColor: textColor,
                          child: Icon(
                            Icons.remove,
                            color: myColors.lineGrey,
                          ),
                        ),
                        for (var v in userList)
                          AvatarName(
                            // avatars: userList[i].avatar!,
                            avatars: [v.avatar ?? ''],
                            name: v.roomNickname ?? '',
                            userName: v.nickname ?? '',
                            userId: v.userId ?? '',
                            size: size,
                            nameColor: textColor,
                            onlineTime: time2onlineDate(v.lastOnlineTime,
                                zeroStr: '当前在线'.tr()),
                          ),
                      ],
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
