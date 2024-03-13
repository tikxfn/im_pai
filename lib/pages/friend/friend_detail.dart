import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/api_request.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/user_info.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/friend_list_notifier.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/call/mini_talk_overlay.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/community/community_my.dart';
import 'package:unionchat/pages/friend/friend_detail_setting.dart';
import 'package:unionchat/pages/friend/friend_setting_label.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/dialog_widget.dart';
import 'package:unionchat/widgets/marquee_text.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../widgets/form_widget.dart';
import '../../widgets/menu_ul.dart';
import '../../widgets/user_name_tags.dart';
import '../chat/widgets/chat_talk_model.dart';
import 'friend_setting.dart';

class FriendDetails extends StatefulWidget {
  const FriendDetails({super.key});

  static const String path = 'friends/details';

  @override
  State<StatefulWidget> createState() {
    return _FriendDetailsState();
  }
}

class _FriendDetailsState extends State<FriendDetails> {
  bool isTitleJump = false; //是否是聊天title跳转的
  TextEditingController ctr = TextEditingController();
  double avatarSize = 75;
  double avatarFrameSizeHight = 38;
  double avatarFrameSizeWidth = 26;
  double avatarTopPadding = 10;

  //是否添加朋友
  bool _isFriend = false;
  bool firstLoadSuccess = false;
  static bool isBlack = false;

  //对方是否允许陌生人对话
  bool _strangerMessage = true;

  //朋友来源
  String friendFrom = '';

  //添加方式
  String addMethod = '';

  String userId = '';
  String pairId = '';
  bool isTop = false;
  bool doNotDisturb = false;
  GUserModel? detail; //用户详情
  GUserFriendModel? detailSetting; //用户详情设置
  bool enableFriend = false; //是否可以添加朋友
  // bool hasPhone = false; //是否绑定手机

  String roomId = '';
  String onlineTime = ''; //最后在线时间
  UserType userType = UserType.nil;
  bool roomManage = false; //是否群管理
  bool silence = false; //是否禁言
  bool roomMember = false; //是否在群聊
  bool removeToTabs = false; //是否跳转到首页再进入对话
  //靠谱值
  String reliable = '0';

  //派聊币
  double integral = 0;

  //备注
  String mark = '';

  //获取详情
  getDetail() async {
    if (userId.isEmpty) return;
    final api = UserApi(apiClient());
    try {
      final res = await api.userUserDetail(GIdArgs(id: userId));
      if (res == null) return;
      onlineTime =
          time2onlineDate(res.user?.lastOnlineTime, zeroStr: '在线'.tr());
      firstLoadSuccess = true;
      _isFriend = res.frienStatus == V1RelationStatus.OTHER ||
          res.frienStatus == V1RelationStatus.BOTH;
      if (_isFriend) {
        isBlack =
            (res.blackStatus ?? V1RelationStatus.NIL) != V1RelationStatus.NIL;
      }
      var privacy = UserPrivacy(toInt(res.user?.privacy));
      _strangerMessage = privacy.contains(UserPrivacy.strangerMessage);
      // hasPhone = res.user?.isHavePhone ?? false;
      reliable = res.user?.userExtend?.reliable ?? '0';
      detail = res.user;
      logger.i(detail?.useChangeNicknameCard);
      if (detail != null) {
        userType = UserTypeExt.formMerchantType(detail?.customerType);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
    getSetting();
    getTopic();
  }

  //获取用户设置
  getSetting() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userGetUserFriendSetting(GIdArgs(id: userId));
      if (res == null) return;
      detailSetting = res;
      mark = detailSetting?.mark ?? '';

      switch (detailSetting?.from) {
        case GFriendFrom.ID:
          addMethod = '通过ID添加'.tr();
          break;
        case GFriendFrom.QR:
          addMethod = '通过二维码名片添加'.tr();
          break;
        case GFriendFrom.PHONE:
          addMethod = '通过手机添加'.tr();
          break;
        case GFriendFrom.RECOMMEND:
          addMethod = '通过推荐添加'.tr();
          break;
        case GFriendFrom.ROOM:
          addMethod = '通过群添加'.tr();
          break;
        case GFriendFrom.NIL:
          break;
        case GFriendFrom.ACCOUNT:
          addMethod = '通过账号添加'.tr();
          break;
        case GFriendFrom.NUMBER:
          addMethod = '通过靓号添加'.tr();
          break;
      }
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //获取用户设置
  getTopic() async {
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
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //添加好友
  Future<bool> addFriend(String str) async {
    GFriendFrom status = GFriendFrom.NIL;
    switch (friendFrom) {
      case 'ID':
        status = GFriendFrom.ID;
        break;
      case 'QR':
        status = GFriendFrom.QR;
        break;
      case 'PHONE':
        status = GFriendFrom.PHONE;
        break;
      case 'RECOMMEND':
        status = GFriendFrom.RECOMMEND;
        break;
      case 'ROOM':
        status = GFriendFrom.ROOM;
        break;
      case 'ACCOUNT':
        status = GFriendFrom.ACCOUNT;
        break;
      case 'NUMBER':
        status = GFriendFrom.NUMBER;
        break;
    }
    final api = UserApi(apiClient());
    loading();
    try {
      var args = V1UserAddFriendArgs(
        friendId: userId,
        friendFrom: status,
        mark: str,
      );
      await api.userAddFriend(args);
      // if (res == null) return;
      await getDetail();
      if (_isFriend) {
        FriendListNotifier().add(UserInfo.fromModel(detail!));
      }
      tipSuccess('发送成功'.tr());
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
    return true;
  }

  //获取群信息
  getRoomInfo() async {
    if (roomId.isEmpty) {
      enableFriend = true;
      return;
    }
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null) return;
      var identity = res.my!.identity;
      roomManage = identity == GRoomMemberIdentity.ADMIN ||
          identity == GRoomMemberIdentity.OWNER;
      if (roomManage) {
        enableFriend = true;
      } else {
        enableFriend = toBool(res.room!.enableFriend);
      }
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

  //赠送靠谱草
  giveReliable() async {
    if (!isDouble(ctr.text)) {
      tip('请输入正确的数字'.tr());
      return;
    }
    loading();
    var api = UserApi(apiClient());
    try {
      await api.userGiveReliable(
        V1UserGiveReliableArgs(
          userId: userId,
          reliable: ctr.text.toString(),
        ),
      );
      tip('赠送成功'.tr());
      reliable = (toInt(reliable) + toInt(ctr.text)).toString();
      ctr.text = '';
      setState(() {});
      if (mounted) {
        Navigator.pop(context);
        getIntegral();
      }
    } on ApiException catch (e) {
      onError(e);
      setState(() {
        doNotDisturb = false;
      });
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //拉黑
  black() async {
    confirm(
      context,
      title: '确定要拉黑该联系人？'.tr(),
      onEnter: () async {
        var api = UserApi(apiClient());
        loading();
        try {
          await api.userBlackFriend(GIdArgs(id: userId));
          FriendListNotifier().removeById(toInt(userId));
          if (mounted) {
            Navigator.popUntil(context, ModalRoute.withName(Tabs.path));
          }
          // getDetail();
        } on ApiException catch (e) {
          onError(e);
        } catch (e) {
          logger.e(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  // 通知查看消息
  noticeFriend(int i) async {
    var cfm = await confirm(
      context,
      title: i == 0 ? '确认短信通知对方查看消息？'.tr() : '确认电话通知对方查看消息？',
    );
    if (cfm != true) return;
    var api = UserApi(apiClient());
    loading();
    try {
      if (i == 0) {
        await api.userSmsNotify(GIdArgs(id: userId));
      } else {
        await api.userVoiceNotify(GIdArgs(id: userId));
      }
      if (mounted) {
        tip('已通知对方'.tr());
      }
    } on ApiException catch (e) {
      tipError('发送失败'.tr());
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //短信通知
  message() async {
    if (!(detail?.isHavePhone ?? false) == true) {
      tipError('好友未绑定手机');
      return;
    }
    openSheetMenu(
      context,
      list: ['短信通知', '电话通知'],
      onTap: noticeFriend,
    );
  }

  //禁言
  silenceEnabled() async {
    final api = RoomApi(apiClient());
    loading();
    try {
      if (silence) {
        await ApiRequest.apiUserSilence([userId], roomId);
      } else {
        var args = V1ChannelMemberProhibitionArgs(
          roomId: roomId,
          ids: [userId],
        );
        await api.roomChannelMemberProhibition(args);
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  //踢出群成员
  kickOut() async {
    var cfm = await confirm(
      context,
      title: '确定要从群聊删除该成员？',
    );
    if (cfm == null || !cfm) return;
    final api = RoomApi(apiClient());
    loading();
    try {
      var args = V1ExitRoomMemberArgs(roomId: roomId, userIds: [userId]);
      await api.roomExitRoomMember(args);
      if (mounted) _init();
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
    }
  }

  // 获取成员信息
  _getMemberInfo() async {
    if (roomId.isEmpty || !roomManage) return;
    final api = RoomApi(apiClient());
    try {
      var args = V1GetMemberJoinRoomArgs(
        roomId: roomId,
        userId: userId,
      );
      final res = await api.roomGetMemberJoinRoom(args);
      if (res == null) return;
      logger.d(res);
      roomMember = toBool(res.isRoom);
      var pt = toInt(res.prohibitionTime);
      silence = pt > toInt(date2time(null)) || toBool(res.isProhibition);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //获取自己的派聊币
  getIntegral() async {
    await Global.syncLoginUser();
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  // 发送视频通话消息
  sendCall(bool isVideo) async {
    List<Permission> permission = [Permission.microphone];
    if (isVideo) {
      permission.add(Permission.camera);
    }
    if (!await devicePermission(permission)) return;
    if (!mounted) return;
    MiniTalk.open(
      context,
      nickname: detail!.mark!.isNotEmpty ? detail!.mark! : detail!.nickname!,
      avatar: detail!.avatar!,
      isVideo: isVideo,
    );
  }

  //赠送靠谱值
  _sendBox({
    double? imageWidth,
    double? imageHeight,
  }) {
    integral = toDouble(Global.user?.integral ?? '');
    var myColors = ThemeNotifier();
    showDialogWidget(
      context: context,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: myColors.themeBackgroundColor,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //标题
            Container(
              padding: const EdgeInsets.only(left: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: myColors.lineGrey,
                    width: .5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '赠送靠谱草'.tr(),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' (1靠谱草 = 1派聊币)'.tr(),
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: myColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: myColors.iconThemeColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 20),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Image.asset(
                      assetPath('images/kaopu.png'),
                      width: imageWidth,
                      height: imageHeight ?? 30,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: AppInputBox(
                        controller: ctr,
                        color: myColors.chatInputColor,
                        fontColor: myColors.iconThemeColor,
                        hintColor: myColors.textGrey,
                        keyboardType: TextInputType.number,
                        hintText: '请输入数量'.tr(),
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                '我的余额：'.tr(args: [integral.toString()]),
                style: TextStyle(
                  fontSize: 13,
                  color: myColors.tagGrey,
                ),
              ),
            ),

            //按钮
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: CircleButton(
                theme: AppButtonTheme.primary,
                title: '确定'.tr(),
                height: 40,
                fontSize: 14,
                onTap: () {
                  giveReliable();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    await Future.wait(<Future>[
      getDetail(),
      getRoomInfo(),
      _getMemberInfo(),
    ]);
    if (mounted) setState(() {});
  }

  bool _firstIn = false;

  // 数据初始化
  _dataInit({bool build = false}) {
    if (!mounted) return;
    dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
    userId = toStr(args['id']);
    friendFrom = args['friendFrom'] ?? '';
    roomId = args['roomId'] ?? '';
    roomManage = args['roomManage'] ?? false;
    removeToTabs = args['removeToTabs'] ?? false;
    isTitleJump = args['isTitleJump'] ?? false;
    if (roomId.isNotEmpty) {
      pairId = generatePairId(0, toInt(roomId));
    } else if (userId.isNotEmpty) {
      pairId = generatePairId(toInt(userId), toInt(Global.user!.id));
    }
    if (build) {
      _firstIn = true;
      if (args['detail'] == null) return;
      _isFriend = args['isFriend'] ?? false;
      detail = args['detail'];
      onlineTime = time2onlineDate(detail?.lastOnlineTime, zeroStr: '在线'.tr());
      logger.i(detail?.useChangeNicknameCard);
      reliable = detail?.userExtend?.reliable ?? '0';
      mark = detail?.mark ?? '';
      userType = UserTypeExt.formMerchantType(detail?.customerType);
    } else {
      futureDelayFunction(_init);
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
        title: Text('个人信息'.tr()),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                FriendSetting.path,
                arguments: {
                  'id': userId,
                  'pairId': pairId,
                  'detail': detail,
                  'detailSetting': detailSetting,
                  'isBlack': isBlack,
                  '_isFriend': _isFriend,
                  'doNotDisturb': doNotDisturb,
                  'isTop': isTop,
                },
              ).then((value) => getDetail());
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: ThemeBody(
        topPadding: 0,
        bodyColor: myColors.circleBorder,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  //头部
                  avatarContainer(),
                  MenuUl(
                    marginTop: 5,
                    children: [
                      if (platformPhone)
                        MenuItemData(
                          onTap: () => Navigator
                              .pushNamed(context, CommunityMy.path, arguments: {
                            'userId': userId,
                            'trendsBackground': detail?.trendsBackground ?? '',
                            'avatar': detail?.avatar ?? '',
                            'name': detailSetting?.mark ??
                                detailSetting?.nickname ??
                                '',
                            'userNumber': detail?.userNumber ?? '',
                            'numberType':
                                detail?.userNumberType ?? GUserNumberType.NIL,
                            'circleGuarantee':
                                toBool(detail?.userExtend?.circleGuarantee),
                            'system': userType == UserType.system,
                            'customer': userType == UserType.customer,
                            'userVip':
                                toInt(detail?.userExtend?.vipExpireTime) >=
                                    toInt(date2time(null)),
                            'userVipLevel':
                                detail?.userExtend?.vipLevel ?? GVipLevel.NIL,
                            'vipBadge':
                                detail?.userExtend?.vipBadge ?? GBadge.NIL,
                            'userOnlyName':
                                toBool(detail?.useChangeNicknameCard),
                          }),
                          title: '朋友圈'.tr(),
                        ),
                      MenuItemData(
                        title: '设置备注'.tr(),
                        content: Text(
                          mark,
                          style: TextStyle(
                            color: textColor,
                          ),
                        ),
                        onTap: () {
                          var mark = detailSetting?.mark ?? '';
                          var name = detailSetting?.nickname ?? '';
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
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
                      // MenuItemData(
                      //   title: '消息免打扰'.tr(),
                      //   arrow: false,
                      //   content: AppSwitch(
                      //     value: isTip,
                      //     onChanged: (val) {
                      //       setState(() {
                      //         isTip = val;
                      //       });
                      //       isDoNotDisturb(val);
                      //     },
                      //   ),
                      // ),
                      // MenuItemData(
                      //   title: '把他推荐给朋友'.tr(),
                      //   onTap: () {
                      //     Navigator.push(
                      //       context,
                      //       CupertinoModalPopupRoute(
                      //         builder: (context) {
                      //           return ShareHome(
                      //             shareText:
                      //                 '[个人名片]'.tr(args: [detail?.nickname ?? '']),
                      //             contentIds: [userId],
                      //             type: MessageType.userCard,
                      //           );
                      //         },
                      //       ),
                      //     );
                      //   },
                      // ),
                      // MenuItemData(
                      //   title: '加入黑名单',
                      //   onTap: black,
                      // ),
                    ],
                  ),
                  MenuUl(
                    marginTop: 5,
                    children: [
                      MenuItemData(
                        title: '更多信息'.tr(),
                        onTap: () {
                          Navigator.pushNamed(context, FriendDetailSetting.path,
                              arguments: {
                                'id': userId,
                              }).then((value) async {
                            setState(() {
                              getDetail();
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  if (roomManage && roomMember)
                    MenuUl(
                      marginTop: 5,
                      children: [
                        MenuItemData(
                          title: '禁言',
                          arrow: false,
                          content: AppSwitch(
                            value: silence,
                            onChanged: (val) {
                              setState(() {
                                silence = val;
                              });
                              silenceEnabled();
                            },
                          ),
                        ),
                        MenuItemData(
                          title: '移除该成员',
                          titleColor: myColors.red,
                          onTap: kickOut,
                        ),
                      ],
                    ),
                  if (_isFriend || UserPowerType.talk.hasPower)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppBlockButton(
                            text: '发起聊天'.tr(),
                            height: 64,
                            margin: const EdgeInsets.only(top: 0),
                            icon: 'images/talk/message.png',
                            color: (!_isFriend && !_strangerMessage) || isBlack
                                ? myColors.grey
                                : myColors.blueTitle,
                            onTap: () {
                              if (isTitleJump) {
                                Navigator.pop(context);
                                return;
                              }
                              if (detail == null || isBlack) return;
                              if (!_isFriend && !_strangerMessage) {
                                tip('对方未开启陌生人对话权限');
                                return;
                              }
                              var params = ChatTalkParams(
                                receiver: userId,
                                name: detail?.nickname ?? '',
                                mark: detailSetting?.mark ?? '',
                                userNumber: detail?.userNumber ?? '',
                                numberType: detail?.userNumberType,
                                circleGuarantee:
                                    toBool(detail?.userExtend?.circleGuarantee),
                                vip: toInt(detail?.userExtend?.vipExpireTime) >=
                                    toInt(date2time(null)),
                                vipLevel: detail?.userExtend?.vipLevel ??
                                    GVipLevel.NIL,
                                vipBadge:
                                    detail?.userExtend?.vipBadge ?? GBadge.NIL,
                                onlyName: toBool(detail?.useChangeNicknameCard),
                              );
                              if (removeToTabs) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  ChatTalk.path,
                                  ModalRoute.withName(Tabs.path),
                                  arguments: params,
                                );
                              } else {
                                Navigator.pushNamed(
                                  context,
                                  ChatTalk.path,
                                  arguments: params,
                                );
                              }
                            },
                          ),
                          if (platformPhone && FunctionConfig.sendCall)
                            AppBlockButton(
                              height: 64,
                              text: '音视频通话'.tr(),
                              margin: const EdgeInsets.all(0),
                              icon: 'images/talk/video.png',
                              iconSize: 22,
                              borderTop: false,
                              color:
                                  (!_isFriend && !_strangerMessage) || isBlack
                                      ? myColors.grey
                                      : myColors.blueTitle,
                              onTap: () {
                                if (detail == null || isBlack) return;
                                if (!_isFriend && !_strangerMessage) {
                                  tip('对方未开启陌生人对话权限');
                                  return;
                                }
                                openSheetMenu(
                                  context,
                                  list: ['视频通话'.tr(), '语音通话'.tr()],
                                  onTap: (i) {
                                    sendCall(i == 0);
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (!_isFriend &&
                enableFriend &&
                UserPowerType.addFriend.hasPower &&
                firstLoadSuccess)
              BottomButton(
                title: '加为好友'.tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SetNameInput(
                        title: '申请备注信息'.tr(),
                        isAppTextarea: true,
                        onEnter: addFriend,
                      );
                    }),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  //头像列
  Widget avatarContainer() {
    var myColors = context.watch<ThemeNotifier>();
    bool isVip =
        toInt(detail?.userExtend?.vipExpireTime) >= toInt(date2time(null));
    return Container(
      padding: const EdgeInsets.only(
        bottom: 27,
        top: 15,
      ),
      color: myColors.themeBackgroundColor,
      child: Column(
        children: [
          //头像
          Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  width: avatarSize + avatarFrameSizeWidth + 16,
                  height: avatarSize + avatarFrameSizeWidth + 10,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      AppAvatar(
                        list: [detail?.avatar ?? ''],
                        size: avatarSize,
                        avatarFrameHeightSize: avatarFrameSizeHight,
                        avatarFrameWidthSize: avatarFrameSizeWidth,
                        avatarTopPadding: avatarTopPadding,
                        userName: detail?.nickname ?? '',
                        userId: detail?.id ?? '',
                        vip: toInt(detail?.userExtend?.vipExpireTime) >=
                            toInt(date2time(null)),
                        vipLevel: detail?.userExtend?.vipLevel ?? GVipLevel.NIL,
                      ),
                      //是否在线
                      Positioned(
                        right: isVip ? 15 : 5,
                        bottom: isVip ? 8 : 0,
                        child: Image.asset(
                          assetPath(
                              'images/talk/${onlineTime == '在线'.tr() ? 'online' : 'offline'}.png'),
                          width: 16,
                          height: 16,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //靠普草
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: myColors.accountTagBg,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Image.asset(
                          assetPath('images/kaopu.png'),
                          height: 18,
                          width: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 6,
                          top: 3,
                          bottom: 3,
                        ),
                        child: Text(
                          reliable,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 5,
                        ),
                        child: CircleButton(
                          onTap: () {
                            _sendBox();
                          },
                          width: 45,
                          fontSize: 14,
                          radius: 13,
                          theme: AppButtonTheme.greenWhite,
                          title: '赠送',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          //姓名
          Container(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: MarqueeText(
              text: detail?.nickname ?? '',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: toInt(detail?.userExtend?.vipExpireTime) >=
                          toInt(date2time(null))
                      ? myColors.vipName
                      : myColors.iconThemeColor),
            ),
          ),
          const SizedBox(height: 6),
          //姓名
          Container(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: UserNameTags(
              userName: '',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              goodNumber: (detail?.userExtend?.userNumber ?? '').isNotEmpty,
              numberType:
                  detail?.userExtend?.userNumberType ?? GUserNumberType.NIL,
              circleGuarantee: toBool(detail?.userExtend?.circleGuarantee),
              onlyName: toBool(detail?.useChangeNicknameCard),
              vip: isVip,
              vipLevel: detail?.userExtend?.vipLevel ?? GVipLevel.NIL,
              vipBadge: detail?.userExtend?.vipBadge ?? GBadge.NIL,
              system: userType == UserType.system,
              customer: userType == UserType.customer,
            ),
          ),
          const SizedBox(height: 12),
          //账号
          Container(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      ClipboardData data = ClipboardData(
                          text: detail?.userNumber ??
                              detail?.account ??
                              detail?.phone ??
                              '');
                      Clipboard.setData(data);
                      tipSuccess('账号已复制到粘贴板'.tr());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: myColors.accountTagBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              '账号：'.tr(
                                args: [
                                  detail?.userNumber ??
                                      ((detail?.userExtend?.userNumber ?? '')
                                              .isNotEmpty
                                          ? detail?.userExtend?.userNumber ?? ''
                                          : detail?.account ??
                                              detail?.phone ??
                                              detail?.email ??
                                              '')
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: myColors.accountTagTitle,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Image.asset(
                              assetPath('images/talk/copy.png'),
                              width: 13,
                              height: 13,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: message,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.message,
                      size: 23,
                      color: (detail?.isHavePhone ?? false) == true
                          ? myColors.imGreen1
                          : myColors.grey,
                    ),
                  ),
                )
              ],
            ),
          ),
          //个性签名
          if ((detail?.slogan ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(60, 16, 60, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'个性签名'.tr()} : ',
                    style: TextStyle(
                      height: 1,
                      fontSize: 13,
                      color: myColors.accountTagTitle,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      detail?.slogan ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: myColors.iconThemeColor,
                        height: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // // 个人标签
          // Container(
          //   padding: const EdgeInsets.fromLTRB(60, 16, 60, 0),
          //   child: Wrap(
          //     spacing: 10,
          //     runSpacing: 10,
          //     children: [
          //       Container(
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 15,
          //           vertical: 2,
          //         ),
          //         decoration: BoxDecoration(
          //           color: myColors.accountTagBg,
          //           borderRadius: BorderRadius.circular(5),
          //         ),
          //         child: Text(
          //           '助理：9809809',
          //           overflow: TextOverflow.ellipsis,
          //           style: TextStyle(
          //             color: myColors.blueTitle,
          //             fontSize: 12,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
