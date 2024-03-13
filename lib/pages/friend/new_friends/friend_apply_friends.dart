import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';
import '../../chat/widgets/chat_talk_model.dart';

class FriendApplyFriends extends StatefulWidget {
  const FriendApplyFriends({super.key});

  static const String path = 'friend/new_friends';

  @override
  State<FriendApplyFriends> createState() => _FriendApplyFriendsState();
}

class _FriendApplyFriendsState extends State<FriendApplyFriends> {
  //朋友列表
  List<GUserFriendApplyModel> newFriends = [];
  int limit = 30;
  //已选列表
  List<String> ids = [];

  //获取列表
  Future<int> getList({bool init = true}) async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userApplyFriendList(
        GPagination(
          limit: limit.toString(),
          offset: newFriends.length.toString(),
        ),
      );
      if (res == null) return 0;
      if (init) {
        newFriends = res.list.toList();
        UnreadValue.friendNotRead.value = 0;
      } else {
        newFriends.addAll(res.list);
      }
      if (!mounted) return 0;
      setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  //修改状态
  _updateState(GUserFriendApplyModel v, GFriendApplyStatus status) async {
    loading();
    var id = v.id;
    final api = UserApi(apiClient());
    try {
      // newFriends = [];
      await api.userHandleApplyFriend(
        V1UserHandleApplyFriendArgs(
          id: id,
          status: status,
        ),
      );
      v.status = status;
      setState(() {});
      if (status == GFriendApplyStatus.PASS) {
        FriendListNotifier().add(UserInfo.fromModel(v.user!));
      }
      // newFriends = [];
      // getList();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //操作
  agreeRefuse(GUserFriendApplyModel v, GFriendApplyStatus status) async {
    if (status == GFriendApplyStatus.REJECT) {
      confirm(
        context,
        title: '确定要拒绝这条好友申请？'.tr(),
        onEnter: () {
          _updateState(v, status);
        },
      );
    } else {
      _updateState(v, status);
    }
  }

  // 是否全选
  bool checkAll() {
    var ck = true;
    for (var v in newFriends) {
      if (v.status != GFriendApplyStatus.APPLY) continue;
      if (!ids.contains(v.id)) {
        ck = false;
      }
    }
    return ids.isNotEmpty && ck;
  }

  //审核
  manage(List<String> ids, GFriendApplyStatus status) async {
    if (ids.isEmpty) return;
    confirm(
      context,
      content:
          '确认审核？'.tr(args: [status == GFriendApplyStatus.PASS ? '通过' : '拒绝']),
      onEnter: () async {
        loading();
        final api = UserApi(apiClient());
        try {
          var args = V1UserHandleApplyFriendsArgs(
            ids: ids,
            status: status,
          );
          // logger.d(args);
          await api.userHandleApplyFriends(args);
          for (var v in newFriends) {
            if (ids.contains(v.id)) {
              v.status = status;
            }
          }
          setState(() {});
          if (status == GFriendApplyStatus.PASS) {
            for (var v in newFriends) {
              if (ids.contains(v.id)) {
                FriendListNotifier().add(UserInfo.fromModel(v.user!));
              }
            }
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
      body: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (checkAll()) {
                    ids.clear();
                  } else {
                    for (var v in newFriends) {
                      if (v.status != GFriendApplyStatus.APPLY) continue;
                      if (!ids.contains(v.id)) {
                        ids.add(v.id!);
                      }
                    }
                  }
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      AppCheckbox(
                        value: checkAll(),
                        paddingRight: 10,
                      ),
                      Text(
                        '全选'.tr(),
                        style: TextStyle(
                          color: myColors.iconThemeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (ids.isNotEmpty)
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleButton(
                      onTap: () {
                        manage(ids, GFriendApplyStatus.REJECT);
                      },
                      width: 60,
                      radius: 4,
                      height: 26,
                      theme: AppButtonTheme.red,
                      title: '拒绝'.tr(),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CircleButton(
                      onTap: () {
                        manage(ids, GFriendApplyStatus.PASS);
                      },
                      width: 60,
                      radius: 4,
                      height: 26,
                      title: '同意'.tr(),
                      theme: AppButtonTheme.blue,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ))
            ],
          ),
          Expanded(
            flex: 1,
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
                return await getList();
              },
              children: newFriends.map((v) {
                var usermark = v.user?.mark ?? '';
                var status = '';
                var disabled = v.status != GFriendApplyStatus.APPLY;
                var active = ids.contains(v.id);
                switch (v.status) {
                  case GFriendApplyStatus.APPLY:
                    break;
                  case GFriendApplyStatus.NIL:
                    break;
                  case GFriendApplyStatus.PASS:
                    status = '已通过'.tr();
                    break;
                  case GFriendApplyStatus.REJECT:
                    status = '已拒绝'.tr();
                    break;
                }
                var from = '';
                switch (v.from) {
                  case GFriendFrom.ID:
                    from = '来自id查找'.tr();
                    break;
                  case GFriendFrom.QR:
                    from = '来自二维码查找'.tr();
                    break;
                  case GFriendFrom.PHONE:
                    from = '来自手机查找'.tr();
                    break;
                  case GFriendFrom.NIL:
                    from = '添加'.tr();
                    break;
                  case GFriendFrom.RECOMMEND:
                    from = '来自推荐添加'.tr();
                    break;
                  case GFriendFrom.ROOM:
                    from = '来自群添加'.tr();
                    break;
                  case GFriendFrom.ACCOUNT:
                    from = '来自账号添加'.tr();
                    break;
                  case GFriendFrom.NUMBER:
                    from = '来自靓号添加'.tr();
                    break;
                }
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: myColors.lineGrey,
                        width: .5,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (disabled) return;
                      setState(() {
                        if (active) ids.remove(v.id!);
                        if (!active) ids.add(v.id!);
                      });
                    },
                    child: Row(
                      children: [
                        AppCheckbox(
                          disabled: disabled,
                          value: active,
                          paddingLeft: 10,
                        ),
                        Expanded(
                          child: ChatItem(
                            onAvatarTap: () {
                              Navigator.pushNamed(
                                context,
                                ChatTalk.path,
                                arguments: ChatTalkParams(
                                  receiver: v.user?.id ?? '',
                                  name: v.user?.nickname ?? '',
                                ),
                              );
                            },
                            paddingVertical: 5,
                            hasSlidable: false,
                            border: false,
                            titleSize: 17,
                            data: ChatItemData(
                              icons: [v.user?.avatar ?? ''],
                              title: usermark.isNotEmpty
                                  ? usermark
                                  : v.user?.nickname ?? '',
                              id: v.user?.id,
                              goodNumber: v.user?.userNumber != null &&
                                  v.user!.userNumber!.isNotEmpty,
                              numberType:
                                  v.user?.userNumberType ?? GUserNumberType.NIL,
                              circleGuarantee:
                                  toBool(v.user?.userExtend?.circleGuarantee),
                              onlyName: toBool(v.user?.useChangeNicknameCard),
                              vip: toInt(v.user?.userExtend?.vipExpireTime) >=
                                  toInt(date2time(null)),
                              vipLevel:
                                  v.user?.userExtend?.vipLevel ?? GVipLevel.NIL,
                              vipBadge:
                                  v.user?.userExtend?.vipBadge ?? GBadge.NIL,
                              userType: UserTypeExt.formMerchantType(
                                  v.user?.customerType),
                              text: v.mark ?? '',
                            ),
                            end: v.status == GFriendApplyStatus.APPLY
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CircleButton(
                                        onTap: () => agreeRefuse(
                                            v, GFriendApplyStatus.REJECT),
                                        // fontSize: 14,
                                        width: 60,
                                        radius: 4,
                                        height: 26,
                                        theme: AppButtonTheme.red,
                                        title: '拒绝'.tr(),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      CircleButton(
                                        onTap: () => agreeRefuse(
                                            v, GFriendApplyStatus.PASS),
                                        theme: AppButtonTheme.blue,
                                        width: 60,
                                        radius: 4,
                                        height: 26,
                                        title: '同意'.tr(),
                                      ),
                                    ],
                                  )
                                : Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: myColors.subIconThemeColor,
                                    ),
                                  ),
                            child: Text(
                              '来自：'.tr(args: [from]),
                              style: TextStyle(
                                color: myColors.linkGrey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
