import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/help/circle/circle_set_manage_update.dart';
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

class CircleSetManage extends StatefulWidget {
  const CircleSetManage({super.key});

  static const String path = 'help/circle/circle_set_manage';

  @override
  State<StatefulWidget> createState() {
    return _CircleSetManageState();
  }
}

class _CircleSetManageState extends State<CircleSetManage> {
  String keywords = '';
  String circleId = ''; //圈子id
  double size = 44; //头像大小
  int limit = 50;
  Color nameColor = ThemeNotifier().textBlack; //文字颜色
  List<GCircleJoinModel> userList = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListMember(
        V1ListMemberCircleArgs(
          keywords: keywords,
          isAdmin: GSure.YES,
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : userList.length.toString(),
          ),
        ),
      );
      if (!mounted) return 0;
      List<GCircleJoinModel> l = res?.list.toList() ?? [];
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
                    onPressed: () {
                      _getList(init: true);
                    },
                    child: Text(
                      '搜索'.tr(),
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
                    if (args['circleId'] != null) circleId = args['circleId'];
                    return await _getList(init: true);
                  },
                  onPullDown: () async {
                    return await _getList(init: true);
                  },
                  onPullUp: () async {
                    return await _getList(init: true);
                  },
                  children: [
                    RowList(
                      lineSpacing: 10,
                      rowNumber: 5,
                      children: [
                        //添加管理员
                        CircularButton(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              CircleSetManageUpdate.path,
                              arguments: {
                                'circleId': circleId,
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
                              CircleSetManageUpdate.path,
                              arguments: {
                                'circleId': circleId,
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
                            avatars: [v.avatar ?? ''],
                            name: v.nickname ?? '',
                            userName: v.nickname ?? '',
                            userId: v.userId ?? '',
                            nameColor: textColor,
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
