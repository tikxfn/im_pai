import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/pages/chat/search_self_messaged.dart';
import 'package:unionchat/pages/friend/friend_setting_label.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../common/api_request.dart';
import '../../common/enum.dart';
import '../../common/interceptor.dart';
import '../../function_config.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/form_widget.dart';
import '../../widgets/undo_dialog.dart';
import '../share/share_home.dart';
import '../tabs.dart';

class FriendSetting extends StatefulWidget {
  const FriendSetting({super.key});

  static const path = 'friend/setting';

  @override
  State<StatefulWidget> createState() {
    return _FriendSettingState();
  }
}

class _FriendSettingState extends State<FriendSetting> {
  double size = 60;
  String userId = '';
  String pairId = '';
  GUserModel? detail; //用户详情
  GUserFriendModel? detailSetting; //用户详情设置
  //是否已加朋友
  bool _isFriend = false;

  //是否已经拉黑
  bool isBlack = false;
  bool isTop = false;
  bool doNotDisturb = false;
  bool undoPower = UserPowerType.undo.hasPower;
  int destroyTime = 0;

  //设置自毁时间
  setDestroyTime(int second) async {
    setState(() {
      destroyTime = second;
    });
    await ApiRequest.setTopicDestroyDuration(pairId, destroyTime);
  }

  //选择自毁时间
  _chooseDestroyTime() {
    var index = 0;
    for (var v in DestroyTime.values) {
      if (v.toSecond == destroyTime) {
        index = DestroyTime.values.indexOf(v);
      }
    }
    openSelect(
      context,
      index: index,
      list: DestroyTime.values.map((e) {
        return e.toChar;
      }).toList(),
      onEnter: (i) {
        setDestroyTime(DestroyTime.values[i].toSecond);
      },
    );
  }

  //清空聊天记录提示
  removeHistoryConfirm() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return UndoDialog(
          // showUndo: false,
          tip: '双向清空需好友 "确定授权" 才会清空对方消息记录',
          onEnter: (undo) {
            removeHistory();
          },
        );
      },
    );
  }

  //清空聊天记录
  removeHistory() async {
    loading();
    try {
      await MessageUtil.deleteChannel([pairId]);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //获取详情
  getDetail() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userUserDetail(GIdArgs(id: userId));
      if (res == null || !mounted) return;
      setState(() {
        isBlack = res.blackStatus == V1RelationStatus.ME ||
            res.blackStatus == V1RelationStatus.BOTH;
        _isFriend = res.frienStatus == V1RelationStatus.OTHER ||
            res.frienStatus == V1RelationStatus.BOTH;
        detail = res.user;
      });
      if (_isFriend) getSetting();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //获取用户设置
  getSetting() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userGetUserFriendSetting(GIdArgs(id: userId));
      if (res == null) return;
      detailSetting = res;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //获取channel设置
  getChannel() async {
    final api = ChannelApi(apiClient());
    try {
      final res = await api.channelDetail(
        GPairIdArgs(
          pairId: generatePairId(
            toInt(Global.user!.id),
            toInt(userId),
          ),
        ),
      );
      if (res == null || !mounted) return;
      setState(() {
        isTop = toInt(res.topTime) > 0;
        doNotDisturb = res.doNotDisturb ?? false;
        destroyTime = toInt(res.messageDestroyDuration);
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //保存备注
  Future<bool> saveNickName(String str) async {
    loading();
    var success = await FriendListNotifier().updateMark(
      pairId,
      toInt(userId),
      str,
    );
    loadClose();
    if (success) {
      getSetting();
    }
    return success;
  }

  //启用置顶
  setTop(bool val) async {
    MessageUtil.top(pairId, val);
  }

  // 移除黑名单
  removeBlack() async {
    final api = UserApi(apiClient());
    try {
      await api.userRemoveBlackFriend(GIdArgs(id: userId));
      FriendListNotifier().add(UserInfo.fromModel(detail!));
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //拉黑
  black() async {
    var api = UserApi(apiClient());
    try {
      await api.userBlackFriend(GIdArgs(id: userId));
      MessageUtil.deleteLocalChannel(pairId);
      FriendListNotifier().removeById(toInt(userId));
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //删除
  delete() async {
    var api = UserApi(apiClient());
    loading();
    try {
      await api.userDeleteFriend(GIdArgs(id: userId));
      MessageUtil.deleteLocalChannel(pairId);
      FriendListNotifier().removeById(toInt(userId));
      if (mounted) {
        Navigator.popUntil(context, ModalRoute.withName(Tabs.path));
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  bool _firstIn = false;

  // 数据初始化
  _dataInit({bool build = false}) {
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
    pairId = args['pairId'] ?? '';
    userId = args['id'] ?? '';
    if (build) {
      _firstIn = true;
      if (args['detail'] != null) detail = args['detail'];
      if (args['detailSetting'] != null) {
        detailSetting = args['detailSetting'];
      }
      if (args['isBlack'] != null) isBlack = args['isBlack'];
      if (args['_isFriend'] != null) _isFriend = args['_isFriend'];
      if (args['doNotDisturb'] != null) doNotDisturb = args['doNotDisturb'];
      if (args['isTop'] != null) isTop = args['isTop'];
    } else {
      if (userId.isEmpty) return;
      futureDelayFunction(() {
        getDetail();
        getChannel();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _dataInit());
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    if (!_firstIn) _dataInit(build: true);
    return Scaffold(
      appBar: AppBar(
        title: Text('资料设置'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            // if (_isFriend)
            //   Container(
            //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //     // padding: const EdgeInsets.only(left: 10),
            //     decoration: const BoxDecoration(
            //       color: myColors.white,
            //     ),
            //     child: Column(
            //       children: [
            //         //成员列表
            //         Row(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             GestureDetector(
            //               onTap: () {
            //                 Navigator.pushNamed(context, FriendDetails.path,
            //                     arguments: {'id': userId});
            //               },
            //               child: AvatarName(
            //                 avatars: [detail?.avatar ?? ''],
            //                 name: detail?.nickname ?? 'null',
            //                 size: size,
            //                 nameColor: myColors.textBlack,
            //               ),
            //             ),
            //             const SizedBox(width: 10),
            //             GestureDetector(
            //               onTap: () {
            //                 Navigator.pushNamed(context, FriendAddGroup.path,
            //                     arguments: {'Id': userId});
            //               },
            //               child: Container(
            //                 width: size,
            //                 height: size,
            //                 decoration: BoxDecoration(
            //                   // color: myColors.textGrey,
            //                   border: Border.all(
            //                     color: myColors.lineGrey,
            //                     width: .5,
            //                   ),
            //                   borderRadius: BorderRadius.circular(size),
            //                 ),
            //                 child: const Icon(
            //                   Icons.add,
            //                   color: myColors.lineGrey,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            MenuUl(
              marginTop: 0,
              children: [
                MenuItemData(
                    title: '查找聊天记录'.tr(),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        SearchSelfMessagesPage.path,
                        arguments: {
                          'id': userId,
                          'pairId': pairId,
                        },
                      );
                    }),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '设置备注'.tr(),
                  content: Text(
                    detailSetting?.mark ?? '',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        var mark = detailSetting?.mark ?? '';
                        var name = detailSetting?.nickname ?? '';
                        return SetNameInput(
                          title: '设置备注'.tr(),
                          subTitle: '修改备注后，仅自己可见'.tr(),
                          value: mark.isEmpty ? name : mark,
                          onEnter: (val) {
                            if (val == name) return Future.value(true);
                            return saveNickName(val);
                          },
                        );
                      }),
                    );
                  },
                ),
                MenuItemData(
                  title: '标签'.tr(),
                  content: Text(
                    detailSetting?.label ?? '',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      FriendSettingLabel.path,
                      arguments: {'userId': userId},
                    ).then((value) {
                      getSetting();
                    });
                  },
                ),
                MenuItemData(
                  title: '置顶聊天'.tr(),
                  arrow: false,
                  content: AppSwitch(
                      value: isTop,
                      onChanged: (val) {
                        setState(() {
                          isTop = val;
                        });
                        setTop(val);
                      }),
                ),
                MenuItemData(
                  title: '消息免打扰'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: doNotDisturb,
                    onChanged: (val) {
                      setState(() {
                        doNotDisturb = val;
                      });
                      MessageUtil.silence(pairId, val);
                    },
                  ),
                ),
                if (undoPower && FunctionConfig.messageDestroy)
                  MenuItemData(
                    title: '消息自毁'.tr(),
                    content: Text(
                      DestroyTimeExt.fromSecond(destroyTime)?.toChar ?? '',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    onTap: _chooseDestroyTime,
                  ),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '把他推荐给朋友'.tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) {
                          var msg = Message()
                            ..senderUser = getSenderUser()
                            ..type = GMessageType.USER_CARD
                            ..content = detail?.nickname
                            ..fileUrl = detail?.avatar
                            ..contentId = toInt(userId);
                          return ShareHome(
                            shareText:
                                '[个人名片]'.tr(args: [detail?.nickname ?? '']),
                            list: [msg],
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '加入黑名单'.tr(),
                  // onTap: !isBlack ? black : null,
                  content: AppSwitch(
                    value: isBlack,
                    onChanged: (val) {
                      setState(() {
                        isBlack = val;
                      });
                      if (val) {
                        black();
                      } else {
                        removeBlack();
                      }
                      // black(val);
                    },
                  ),
                  // content: !isBlack ? null : Text('已加入黑名单'.tr()),
                  arrow: false,
                  // arrow: !isBlack ? true : false,
                ),
                // MenuItemData(
                //   title: '共同群聊',
                //   arrow: false,
                //   content: const Text('个'),
                // ),
              ],
            ),
            if (pairId.isNotEmpty && FunctionConfig.cleanTalkHistory)
              MenuUl(
                children: [
                  MenuItemData(
                    title: '清空聊天记录'.tr(),
                    onTap: removeHistoryConfirm,
                  ),
                ],
              ),
            if (_isFriend)
              MenuUl(
                children: [
                  MenuItemData(
                    title: '删除联系人'.tr(),
                    titleColor: myColors.red,
                    onTap: () {
                      confirm(
                        context,
                        content: '是否删除此联系人？'.tr(),
                        onEnter: delete,
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
