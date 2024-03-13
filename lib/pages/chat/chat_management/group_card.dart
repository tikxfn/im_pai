import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/about_image.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/share/share_home.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/set_name_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../notifier/theme_notifier.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({super.key});

  static const path = 'chat/chat_management/group_card';

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  String roomId = ''; //群id
  GRoomModel? detail; //群信息
  String avatar = ''; //头像
  double avatarSize = 100; //头像大小
  String roomName = ''; //群名称
  GRoomMemberIdentity identity = GRoomMemberIdentity.NIL; //群身份
  GApplyStatus applyStatus = GApplyStatus.NIL; //申请状态
  bool isCard = true; //是群名片
  String roomFrom = ''; //群添加来源
  final GlobalKey _globalKey1 = GlobalKey();
  bool _initLoad = false; //初始化载入
  bool _loadFail = false; // 载入失败
  String shareUserId = '0'; //分享人用户id
  String url = '';

  //获取详情
  getDetail() async {
    GRoomFrom from = GRoomFrom.NIL;
    switch (roomFrom) {
      case 'QR':
        from = GRoomFrom.QR;
        break;
      case 'ID':
        from = GRoomFrom.ID;
        break;
    }
    //获取群信息
    final api = RoomApi(apiClient());
    try {
      final res = await api.roomGetRoom(
        V1GetRoomArgs(
          roomId: roomId,
          roomFrom: from,
        ),
      );
      if (res == null || !mounted) return;
      detail = res.room;
      avatar = detail?.roomAvatar ?? '';
      roomName = detail?.roomName ?? '';
      identity = res.my?.identity ?? GRoomMemberIdentity.NIL;
      applyStatus = res.my?.applyStatus ?? GApplyStatus.NIL;
      logger.i(applyStatus);
      if (detail?.id == null) {
        _loadFail = true;
        setState(() {});
        return;
      }
      _initLoad = true;
      setState(() {});
    } on ApiException catch (e) {
      _loadFail = true;
      onError(e);
    } finally {}
  }

  //加入群
  addGroup() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SetNameInput(
          title: '申请备注信息'.tr(),
          onEnter: applySend,
          isAppTextarea: true,
        );
      }),
    );
  }

  //发送申请
  Future<bool> applySend(String str) async {
    final api = RoomApi(apiClient());
    loading();
    try {
      await api.roomJoinRoom(V1JoinRoomArgs(
        roomId: roomId,
        applyContent: str,
        inviteUserId: shareUserId,
      ));
      if (mounted) {
        tip('申请成功，等待管理员审核'.tr());
        getDetail();
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['roomId'] != null) roomId = args['roomId'];
      if (args['isCard'] != null) isCard = args['isCard'];
      if (args['roomFrom'] != null) roomFrom = args['roomFrom'] ?? '';
      if (args['shareUserId'] != null) shareUserId = args['shareUserId'] ?? '';
      logger.i(shareUserId);
      getDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    url = createScanUrl(data: roomId, type: 'imRoom');
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      // extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '群名片'.tr(),
        ),
      ),
      body: ThemeBody(
        bodyColor: myColors.tagColor,
        child: RepaintBoundary(
          key: _globalKey1,
          child: Container(
            alignment: Alignment.center,
            color: myColors.tagColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _initLoad
                    ? createBody()
                    : Text(
                        _loadFail ? '加载失败或卡片失效' : '',
                      ),
                if (!isCard && _initLoad)
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: CircleButton(
                      onTap: applyStatus == GApplyStatus.APPLY
                          ? null
                          : (applyStatus == GApplyStatus.REFUSE ||
                                  applyStatus == GApplyStatus.NIL)
                              ? addGroup
                              : null,
                      height: 45,
                      fontSize: 17,
                      disabled: applyStatus == GApplyStatus.APPLY
                          ? true
                          : (applyStatus == GApplyStatus.REFUSE ||
                                  applyStatus == GApplyStatus.NIL)
                              ? false
                              : true,
                      title: applyStatus == GApplyStatus.APPLY
                          ? '申请中'.tr()
                          : (applyStatus == GApplyStatus.REFUSE ||
                                  applyStatus == GApplyStatus.NIL)
                              ? '加入群聊'.tr()
                              : '已在此群'.tr(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isCard && _initLoad
          ? Container(
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                color: myColors.bottom,
                boxShadow: [
                  BoxShadow(
                    color: myColors.bottomShadow,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CircleButton(
                        onTap: () async {
                          Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) {
                                var msg = Message()
                                  ..senderUser = getSenderUser()
                                  ..type = GMessageType.ROOM_CARD
                                  ..content = detail?.roomName
                                  ..fileUrl = detail?.roomAvatar
                                  ..contentId = toInt(roomId)
                                  ..location =
                                      (Global.user?.id ?? '').isNotEmpty
                                          ? Global.user!.id!
                                          : ''; //分享人id
                                logger.i(msg);
                                return ShareHome(
                                  list: [msg],
                                  shareText: '[群名片]'.tr(args: [roomName]),
                                );
                              },
                            ),
                          );
                        },
                        title: '分享给好友'.tr(),
                        icon: 'images/my/scan_share.png',
                        radius: 10,
                        theme: AppButtonTheme.blue0,
                        fontSize: 16,
                        height: 47,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: CircleButton(
                        onTap: () {
                          globSaveImageToGallery(_globalKey1);
                        },
                        icon: 'images/my/scan_save.png',
                        title: '保存二维码'.tr(),
                        radius: 10,
                        theme: AppButtonTheme.blue,
                        fontSize: 16,
                        height: 47,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // 97 115 150
  Widget createBody() {
    var myColors = ThemeNotifier();
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.fromLTRB(31, 41, 31, 0),
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: myColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 9),
                child: Text(
                  '群聊：$roomName',
                  style: TextStyle(
                    color: myColors.iconThemeColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              //二维码
              Container(
                width: 230,
                height: 230,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: myColors.white,
                ),
                child: CustomPaint(
                  size: const Size.square(100),
                  painter: QrPainter(
                    data: Uri.decodeFull(url),
                    version: QrVersions.auto,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: myColors.black,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: myColors.black,
                    ),
                    // size: 320.0,
                  ),
                ),
              ),
              if (isCard)
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Text(
                    '扫一扫上面的二维码图案，即可加入群聊。'.tr(),
                    style: TextStyle(
                      color: myColors.accountTagTitle,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            border: Border.all(
              width: 2,
              color: myColors.white,
            ),
          ),
          child: AppAvatar(
            list: [avatar],
            size: 80,
            userName: roomName,
            userId: roomId,
          ),
        ),
      ],
    );
  }
}
