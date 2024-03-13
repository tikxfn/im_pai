import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class CircleSetManageUpdate extends StatefulWidget {
  const CircleSetManageUpdate({super.key});

  static const String path = 'help/circle/circle_set_manage_update';

  @override
  State<StatefulWidget> createState() {
    return _CircleSetManageUpdateState();
  }
}

class _CircleSetManageUpdateState extends State<CircleSetManageUpdate> {
  int limit = 50;
  String keywords = '';
  String circleId = ''; //群聊id
  bool isSetManage = false; //设置管理员或取消管理员

  List<GCircleJoinModel> userList = [];
  //勾选列表
  List<GCircleJoinModel> activeIds = [];

  //选择用户
  onChoose(GCircleJoinModel e) {
    if (activeIds.contains(e)) {
      activeIds.remove(e);
    } else {
      activeIds.add(e);
    }
    setState(() {});
  }

  //获取用户列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = CircleApi(apiClient());
    List<GCircleJoinModel> l = [];
    try {
      if (isSetManage) {
        final res = await api.circleListMember(V1ListMemberCircleArgs(
          keywords: keywords,
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : userList.length.toString(),
          ),
        ));
        if (!mounted) return 0;
        for (var v in res?.list ?? []) {
          if (v.role == GRole.LEADER || v.role == GRole.ADMIN) {
            continue;
          } else {
            l.add(v);
          }
        }
        setState(() {
          if (init) {
            userList = l;
          } else {
            userList.addAll(l);
          }
        });
        if (res == null) return 0;
        return res.list.length;
      }
      if (!isSetManage) {
        final res = await api.circleListMember(V1ListMemberCircleArgs(
          keywords: keywords,
          isAdmin: GSure.YES,
          circleId: circleId,
          pager: GPagination(
            limit: limit.toString(),
            offset: init ? '0' : userList.length.toString(),
          ),
        ));
        if (!mounted) return 0;
        for (var v in res?.list ?? []) {
          if (v.role == GRole.LEADER) {
            continue;
          } else {
            l.add(v);
          }
        }
        setState(() {
          if (init) {
            userList = l;
          } else {
            userList.addAll(l);
          }
        });
        if (res == null) return 0;
        return res.list.length;
      }
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  //设置管理员取消管理员
  setManage(GRole identity) async {
    String title = '';
    if (identity == GRole.MEMBER) title = '确定取消勾选用户的管理员身份'.tr();
    if (identity == GRole.ADMIN) title = '确定将勾选用户设置为管理员'.tr();
    confirm(
      context,
      title: title,
      onEnter: () async {
        List<String> userIds = [];
        for (var v in activeIds) {
          userIds.add(v.userId.toString());
        }
        logger.i(userIds);
        final api = CircleApi(apiClient());
        loading();
        try {
          final res =
              await api.circleUpdateCircleMember(V1UpdateCircleMemberArgs(
            circleId: circleId,
            memberIds: userIds,
            role: V1UpdateCircleMemberArgsRole(role: identity),
          ));
          // if (res == null) return;
          logger.i(res);
          if (mounted) {
            activeIds = [];
            _getList(init: true);
          }
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(isSetManage ? '设置管理员'.tr() : '取消管理员'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
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
                if (activeIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var i = 0; i < activeIds.length; i++)
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    child: AppAvatar(
                                      list: [activeIds[i].avatar ?? ''],
                                      size: 41,
                                      userName: activeIds[i].nickname ?? '',
                                      userId: activeIds[i].userId ?? '',
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        onChoose(activeIds[i]);
                                      },
                                      child: Image.asset(
                                        assetPath(
                                            'images/talk/group_close.png'),
                                        height: 19,
                                        width: 19,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: PagerBox(
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    limit: limit,
                    onInit: () async {
                      if (!mounted) return 0;
                      dynamic args = ModalRoute.of(context)!.settings.arguments;
                      if (args == null) return 0;
                      if (args['circleId'] != null) circleId = args['circleId'];
                      if (args['isSetManage'] != null) {
                        isSetManage = args['isSetManage'];
                      }
                      logger.i(isSetManage);
                      return await _getList(init: true);
                    },
                    onPullDown: () async {
                      return await _getList(init: true);
                    },
                    onPullUp: () async {
                      return await _getList();
                    },
                    children: [
                      for (var e in userList)
                        GestureDetector(
                          onTap: () => onChoose(e),
                          child: Row(
                            children: [
                              AppCheckbox(
                                value: activeIds.contains(e),
                                size: 25,
                                paddingLeft: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: ChatItem(
                                  avatarSize: 46,
                                  titleSize: 16,
                                  hasSlidable: false,
                                  data: ChatItemData(
                                    icons: [e.avatar ?? ''],
                                    title: e.nickname ?? '',
                                    id: e.userId,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                BottomButton(
                  title: '完成'.tr(),
                  onTap: activeIds.isEmpty
                      ? null
                      : () {
                          setManage(
                            isSetManage ? GRole.ADMIN : GRole.MEMBER,
                          );
                        },
                  disabled: activeIds.isEmpty,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
