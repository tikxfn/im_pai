import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/chat/chat_management/group_apply_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_chat_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_clean_user.dart';
import 'package:unionchat/pages/chat/chat_management/group_log.dart';
import 'package:unionchat/pages/chat/chat_management/group_no_speaking_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_set_manage.dart';
import 'package:unionchat/pages/chat/chat_management/group_transfer_leader.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../../common/api_request.dart';
import '../../../common/enum.dart';
import '../../../function_config.dart';
import '../../../notifier/theme_notifier.dart';
import '../../../widgets/form_widget.dart';
import '../../../widgets/image_editor.dart';
import '../../tabs.dart';

class GroupManage extends StatefulWidget {
  const GroupManage({super.key});

  static const String path = 'chat/group_manage';

  @override
  State<StatefulWidget> createState() {
    return _GroupManageState();
  }
}

class _GroupManageState extends State<GroupManage> {
  String roomId = ''; //群聊id
  String roomAvatar = ''; //群头像
  double avatarSize = 100; //群头像大小
  GRoomModel? detail; //群信息
  GRoomMemberIdentity? identity; //群身份
  int destroyTime = 0;
  int groupApplyNotRead = 0;
  String pairId = '';
  static bool undoPower = UserPowerType.undo.hasPower;
  bool _review = false; //启用入群审核
  bool _setMark = false; //设置备注
  bool _vipJoin = false; //非VIP是否可入群
  bool _canLook = false; //能否查看好友
  bool _canAdd = false; //能否加好友
  bool _editMessage = false; // 能否编辑信息
  bool _canRevoke = false; //能否撤回信息
  bool _prohibition = false; //全体禁言
  //设置自毁时间
  setDestroyTime(int second) async {
    setState(() {
      destroyTime = second;
    });
    await ApiRequest.setTopicDestroyDuration(
      pairId,
      destroyTime,
    );
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

  //选择头像
  pickerAvatar() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file == null) return;
    photoCrop(file.path);
  }

  //图片裁剪
  photoCrop(String path) async {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) => AppImageEditor(
          File(path),
          avatar: true,
        ),
      ),
    ).then((res) async {
      if (res == null) return;
      // photoUpload(res['result']);

      final urls = await UploadFile(
        providers: [
          FileProvider.fromBytes(
              res['result'], V1FileUploadType.USER_AVATAR, 'png'),
        ],
      ).aliOSSUpload();

      roomAvatar = urls[0]!;
      saveRoomAvatar();
      setState(() {});
    });
  }

  //图片裁剪
  photoCrop1(String path) async {
    logger.d(path);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      // aspectRatioPresets: [],
      compressFormat: ImageCompressFormat.png,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '图片裁剪'.tr(),
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: '图片裁剪'.tr(),
          doneButtonTitle: '完成'.tr(),
          cancelButtonTitle: '取消'.tr(),
          aspectRatioLockEnabled: true,
        ),
        WebUiSettings(context: context),
      ],
    );
    if (croppedFile == null) return;
    final urls = await UploadFile(providers: [
      FileProvider.fromFilepath(croppedFile.path, V1FileUploadType.USER_AVATAR),
    ]).aliOSSUpload();
    roomAvatar = urls[0]!;
    saveRoomAvatar();
    setState(() {});
  }

  //获取详情
  getDetail() async {
    final api = RoomApi(apiClient());
    //获取群信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null || !mounted) return;
      setState(() {
        detail = res.room;
        roomAvatar = res.room?.roomAvatar ?? '';
        identity = res.my?.identity;
        groupApplyNotRead = toInt(res.room?.unreadCount);
        _review = toBool(detail?.enableVerify);
        _setMark = toBool(detail?.enableModifyRoomNickname);
        _canLook = toBool(detail?.enableVisit);
        _canAdd = toBool(detail?.enableFriend);
        _editMessage = toBool(detail?.enableEditMessage);
        _canRevoke = toBool(detail?.enableRevoke);
        _prohibition = toBool(detail?.enableProhibition);
        _vipJoin = !toBool(detail?.enableVipJoin);
      });
      logger.i(identity);
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //保存头像
  saveRoomAvatar() async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          roomAvatar: V1UpdateRoomInfoArgsValue(value: roomAvatar),
        ),
      );
      MessageUtil.updateChannelInfo(pairId, avatar: roomAvatar);
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //设置群名称
  Future<bool> saveRoomName(String str) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          roomName: V1UpdateRoomInfoArgsValue(value: str),
        ),
      );
      MessageUtil.updateChannelInfo(pairId, name: str);
      getDetail();
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
    return true;
  }

  //设置群欢迎语
  Future<bool> saveRoomWelcome(String str) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          welcomeMessage: V1UpdateRoomInfoArgsValue(value: str),
        ),
      );
      getDetail();
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
    return true;
  }

  //公开私密群聊
  roomPublic(bool val) async {
    var api = RoomApi(apiClient());
    loading();
    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          roomType: V1UpdateRoomInfoArgsRoomType(
              roomType: val ? GRoomType.PUBLIC : GRoomType.PRIVATE)));
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //启用入群审核
  setEnableVerify(bool val) async {
    var api = RoomApi(apiClient());
    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
        roomId: roomId,
        enableVerify: UpdateRoomInfoArgsEnableVerify(
            enableVerify: val ? GSure.YES : GSure.NO),
      ));
      // getDetail();
    } on ApiException catch (e) {
      _review = !_review;
      setState(() {});
      onError(e);
    } finally {}
  }

  //是否可以修改群内昵称
  enableModifyRoomNickname(bool val) async {
    var api = RoomApi(apiClient());
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableModifyRoomNickname: UpdateRoomInfoArgsEnableModifyRoomNickname(
              enableModifyRoomNickname: val ? GSure.YES : GSure.NO),
        ),
      );
      // getDetail();
    } on ApiException catch (e) {
      _setMark = !_setMark;
      setState(() {});
      onError(e);
    } finally {}
  }

  //非vip用户是否可入群
  enableVipJoin(bool val) async {
    var api = RoomApi(apiClient());
    try {
      await api.roomUpdateRoomInfo(
        V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableVipJoin: UpdateRoomInfoArgsEnableVipJoin(
            enableVipJoin: val ? GSure.NO : GSure.YES,
          ),
        ),
      );
      // getDetail();
    } on ApiException catch (e) {
      _vipJoin = !_vipJoin;
      setState(() {});
      onError(e);
    } finally {}
  }

  //启用可查看群成员信息
  enableVisit(bool val) async {
    var api = RoomApi(apiClient());
    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableVisit: UpdateRoomInfoArgsEnableVisit(
              enableVisit: val ? GSure.YES : GSure.NO)));
      // getDetail();
    } on ApiException catch (e) {
      _canLook = !_canLook;
      setState(() {});
      onError(e);
    } finally {}
  }

  //启用禁止添加好友
  enableFriend(bool val) async {
    var api = RoomApi(apiClient());
    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableFriend: UpdateRoomInfoArgsEnableFriend(
              enableFriend: val ? GSure.YES : GSure.NO)));
      // getDetail();
    } on ApiException catch (e) {
      _canAdd = !_canAdd;
      setState(() {});
      onError(e);
    } finally {}
  }

  //启用编辑信息
  enableEditMessage(bool val) async {
    var api = RoomApi(apiClient());

    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableEditMessage: UpdateRoomInfoArgsEnableEditMessage(
              enableEditMessage: val ? GSure.YES : GSure.NO)));
      // getDetail();
    } on ApiException catch (e) {
      _editMessage = !_editMessage;
      setState(() {});
      onError(e);
    } finally {}
  }

  //启用撤回消息
  enableRevoke(bool val) async {
    var api = RoomApi(apiClient());

    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableRevoke: UpdateRoomInfoArgsEnableRevoke(
            enableRevoke: val ? GSure.YES : GSure.NO,
          )));
      // getDetail();
    } on ApiException catch (e) {
      _canRevoke = !_canRevoke;
      setState(() {});
      onError(e);
    } finally {}
  }

  //全体禁言
  enableProhibition(bool val) async {
    logger.i(val);
    var api = RoomApi(apiClient());

    try {
      await api.roomUpdateRoomInfo(V1UpdateRoomInfoArgs(
          roomId: roomId,
          enableProhibition: UpdateRoomInfoArgsEnableProhibition(
            enableProhibition: val ? GSure.YES : GSure.NO,
          )));
      // getDetail();
    } on ApiException catch (e) {
      _prohibition = !_prohibition;
      setState(() {});
      onError(e);
    } finally {}
  }

  //解散群聊
  removeRoom() async {
    confirm(
      context,
      title: '确定要解散该群聊？'.tr(),
      onEnter: () async {
        var api = RoomApi(apiClient());
        loading();
        try {
          await api.roomDelRoom(GIdArgs(id: roomId));
          MessageUtil.deleteLocalChannel(pairId);
          if (mounted) {
            Navigator.popUntil(context, ModalRoute.withName(Tabs.path));
          }
        } on ApiException catch (e) {
          onError(e);
        }
        loadClose();
      },
    );
  }

  //获取用户设置
  getTopic() async {
    final api = ChannelApi(apiClient());
    try {
      final res = await api.channelDetail(GPairIdArgs(pairId: pairId));
      if (res == null) return;
      var dsd = toInt(res.messageDestroyDuration);
      setState(() {
        destroyTime = dsd;
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      roomId = args['roomId'] ?? '';
      pairId = generatePairId(0, toInt(roomId));
      getDetail();
      getTopic();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color primary = myColors.primary;
    int groupApplyNotRead = toInt(detail?.unreadCount);
    return Scaffold(
      appBar: AppBar(
        title: Text('群管理'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            //群头像
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: pickerAvatar,
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (roomAvatar.isNotEmpty)
                        AppNetworkImage(
                          roomAvatar,
                          avatar: true,
                          width: avatarSize,
                          height: avatarSize,
                          imageSpecification: ImageSpecification.w230,
                          borderRadius: BorderRadius.circular(avatarSize / 2),
                        ),
                      Icon(
                        Icons.camera_alt_outlined,
                        color: myColors.grey1,
                        size: 40,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            MenuUl(
              children: [
                MenuItemData(
                  title: '群聊名称'.tr(),
                  content: Text(
                    detail?.roomName ?? '',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return SetNameInput(
                          title: '设置群聊名称'.tr(),
                          value: detail?.roomName ?? '',
                          onEnter: saveRoomName,
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
            if (identity == GRoomMemberIdentity.OWNER)
              MenuUl(
                children: [
                  // MenuItemData(
                  //   title: '公开群聊'.tr(),
                  //   arrow: false,
                  //   content: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       // Text(detail?.roomType == GRoomType.PUBLIC ? '公开' : '私密'),
                  //       AppSwitch(
                  //         value:
                  //             detail?.roomType == GRoomType.PUBLIC ? true : false,
                  //         onChanged: (val) {
                  //           setState(() {
                  //             val = val;
                  //           });
                  //           roomPublic(val);
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                  title: '入群是否需要审核'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _review,
                    onChanged: (val) {
                      setState(() {
                        _review = val;
                      });
                      setEnableVerify(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '审核管理'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, GroupApplyManage.path,
                        arguments: {'roomId': roomId}).then((value) {
                      getDetail();
                    });
                  },
                  notReadNumber: groupApplyNotRead,
                ),
                MenuItemData(
                  title: '欢迎语'.tr(),
                  content: Text(
                    detail?.welcomeMessage ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return SetNameInput(
                          title: '设置新成员欢迎语'.tr(),
                          value: detail?.welcomeMessage ?? '',
                          onEnter: saveRoomWelcome,
                          isAppTextarea: true,
                        );
                      }),
                    );
                  },
                ),
                MenuItemData(
                  title: '非VIP用户是否可入群'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _vipJoin,
                    onChanged: (val) {
                      setState(() {
                        _vipJoin = val;
                      });
                      enableVipJoin(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '群成员是否能修改自己的群备注'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _setMark,
                    onChanged: (val) {
                      setState(() {
                        _setMark = val;
                      });
                      enableModifyRoomNickname(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '群成员是否可以查看其他成员信息'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _canLook,
                    onChanged: (val) {
                      setState(() {
                        _canLook = val;
                      });
                      enableVisit(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '群成员是否可以添加好友'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _canAdd,
                    onChanged: (val) {
                      setState(() {
                        _canAdd = val;
                      });
                      enableFriend(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '群成员是否可以编辑消息'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _editMessage,
                    onChanged: (val) {
                      setState(() {
                        _editMessage = val;
                      });
                      enableEditMessage(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '是否可撤回聊天记录'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _canRevoke,
                    onChanged: (val) {
                      setState(() {
                        _canRevoke = val;
                      });

                      enableRevoke(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '限制群成员发送消息类型'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, GroupChatManage.path,
                        arguments: {'roomId': roomId});
                  },
                ),
                MenuItemData(
                  title: '全体禁言'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: _prohibition,
                    onChanged: (val) {
                      setState(() {
                        _prohibition = val;
                      });
                      enableProhibition(val);
                    },
                  ),
                ),
                MenuItemData(
                  title: '管理禁言成员'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, GroupNoSpeaking.path,
                        arguments: {'roomId': roomId});
                  },
                ),
                MenuItemData(
                  title: '异常用户清理'.tr(),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      GroupCleanUser.path,
                      arguments: {'roomId': roomId},
                    );
                  },
                ),
                MenuItemData(
                  title: '群日志'.tr(),
                  onTap: () {
                    Navigator.pushNamed(context, GroupLog.path, arguments: {
                      'roomId': roomId,
                    });
                  },
                ),
                if (identity == GRoomMemberIdentity.OWNER)
                  MenuItemData(
                    title: '设置群管理员'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, GroupSetManage.path,
                          arguments: {'roomId': roomId});
                    },
                  ),
                if (identity == GRoomMemberIdentity.OWNER)
                  MenuItemData(
                    title: '转让群主'.tr(),
                    onTap: () {
                      Navigator.pushNamed(context, GroupTransferLeader.path,
                          arguments: {'roomId': roomId}).then((value) {
                        getDetail();
                      });
                    },
                  ),
              ],
            ),
            if (identity == GRoomMemberIdentity.OWNER)
              MenuUl(
                children: [
                  MenuItemData(
                    arrow: false,
                    title: '解散群聊'.tr(),
                    titleColor: myColors.red,
                    onTap: removeRoom,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
