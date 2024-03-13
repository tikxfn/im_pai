import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';
import '../group/group_home.dart';

class CircleCard extends StatefulWidget {
  const CircleCard({super.key});

  static const String path = 'circle/card';

  @override
  State<CircleCard> createState() => _CircleCardState();
}

class _CircleCardState extends State<CircleCard> {
  //圈子id
  String circleId = '';

  //分享圈子名片人的id
  String shareUserId = '0';

  //邀请用户的id
  String invitedUserId = '';

  //圈子详情
  GCircleModel? detail;

  //圈子名称
  String circleName = '';

  //圈子描述
  String describe = '';

  //加入进度中
  bool joinIng = false;

  //所需要邀请的人数
  String needInviteNum = '0';

  //邀请人列表
  List<GCircleShareModel> inviteList = [];

  //是否已经接受了的邀请
  bool accepted = false;

  //是否加入
  bool isJoin = false;

  bool _initLoad = false; //初始化载入
  bool _loadFail = false; // 载入失败
  GApplyStatus applyStatus = GApplyStatus.NIL; //申请状态

  //获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleDetailCircle(GIdArgs(id: circleId));
      if (res == null) return;
      detail = res;
      circleName = res.name ?? '';
      describe = res.describe ?? '';
      isJoin = toBool(res.isJoin);
      needInviteNum = res.inviteUser ?? '0';
      if (isJoin && mounted) {
        Navigator.pushNamed(
          context,
          GroupHome.path,
          arguments: {
            'circleId': res.id,
          },
        );
      }
      if (res.id == null) {
        _loadFail = true;
        setState(() {});
        return;
      }
      getMyStatus();
      logger.i(toInt(needInviteNum));
      if (toInt(needInviteNum) > 0) getInvite();
      _initLoad = true;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      _loadFail = true;
      onError(e);
    } finally {}
  }

  //获取我在圈子的信息
  getMyStatus() async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleGetCircleMemberInfo(GIdArgs(id: circleId));
      if (res == null) return;
      applyStatus = res.status!;
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //获取邀请列表
  getInvite() async {
    inviteList = [];
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircleShare(GIdArgs(id: circleId));
      if (!mounted) return;
      inviteList = res?.list ?? [];
      joinIng = inviteList.length < toInt(needInviteNum);
      for (var v in inviteList) {
        if (v.fromId == invitedUserId) accepted = true;
      }

      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //接受邀请
  accept() async {
    logger.i(circleId);
    logger.i(invitedUserId);
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleConfirmCircleShare(V1ConfirmCircleShareArgs(
        circleId: circleId,
        fromUserId: invitedUserId,
      ));
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //加入圈子
  join() async {
    logger.i(shareUserId);
    var api = CircleApi(apiClient());
    loading();
    try {
      await api.circleJoinCircle(V1JoinCircleArgs(
        id: circleId,
        inviterUserId: toInt(needInviteNum) > 0 ? '-1' : shareUserId,
      ));
      tipSuccess('申请成功'.tr());
      getDetail();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
    if (args['circleId'] == null) {
      _loadFail = true;
      setState(() {});
      return;
    }
    circleId = args['circleId'];
    if (args['invitedUserId'] != null) {
      invitedUserId = args['invitedUserId'] ?? '';
    }
    if (args['shareUserId'] != null) shareUserId = args['shareUserId'];
    logger.i(shareUserId);
    logger.i(invitedUserId);
    if (circleId.isNotEmpty) {
      logger.i(args);
      getDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(),
      body: ThemeBody(
        child: Center(
          child: _initLoad
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppAvatar(
                          list: [
                            detail?.image ?? '',
                          ],
                          userName: circleName,
                          userId: circleId,
                          size: 76,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          circleName,
                          style: TextStyle(
                            color: myColors.iconThemeColor,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          // '简介:  $describe',
                          '快来加入我们吧'.tr(),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: myColors.iconThemeColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 60),
                        buttonWidget(),
                        process(),
                      ],
                    ),
                  ),
                )
              : Text(_loadFail ? '加载失败或卡片失效' : ''.tr()),
        ),
      ),
    );
  }

  Widget buttonWidget() {
    return isJoin
        ? CircleButton(
            onTap: null,
            title: '已加入'.tr(),
            disabled: true,
            width: 224,
            // color: myColors.grey,
            height: 41,
            radius: 20,
          )
        : applyStatus == GApplyStatus.APPLY
            ? CircleButton(
                onTap: null,
                title: '申请中'.tr(),
                disabled: true,
                width: 224,
                height: 41,
                radius: 20,
              )
            : joinIng
                ? accepted
                    ? CircleButton(
                        onTap: null,
                        title: '已接受'.tr(),
                        disabled: true,
                        width: 224,
                        height: 41,
                        radius: 20,
                      )
                    : CircleButton(
                        onTap: accept,
                        title: '接受邀请'.tr(),
                        theme: AppButtonTheme.blue,
                        width: 224,
                        height: 41,
                        radius: 20,
                      )
                : CircleButton(
                    onTap: () {
                      confirm(
                        context,
                        content: '是否加入此圈子？'.tr(),
                        onEnter: join,
                      );
                    },
                    title: '加入'.tr(),
                    theme: AppButtonTheme.blue,
                    width: 224,
                    height: 41,
                    radius: 20,
                  );
  }

  //进程
  Widget process() {
    var myColors = context.watch<ThemeNotifier>();
    return Column(
      children: [
        toInt(needInviteNum) > 0 && !isJoin
            ? Container(
                margin: const EdgeInsets.only(top: 80),
                child: Text('已接受邀请进度 /'.tr(
                    args: [inviteList.length.toString(), needInviteNum]).tr()),
              )
            : Container(),
        toInt(needInviteNum) > 0 && !isJoin
            ? Container(
                constraints:
                    BoxConstraints(maxWidth: toInt(needInviteNum) * 45 + 10),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: myColors.chatInputColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < inviteList.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: AppAvatar(
                            list: [inviteList[i].fromAvatar ?? ''],
                            size: 40,
                            userName: inviteList[i].fromNickname ?? '',
                            userId: inviteList[i].fromId ?? '',
                          ),
                        ),
                      for (var i = 0;
                          i < (toInt(needInviteNum) - inviteList.length);
                          i++)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: const AppAvatar(
                            list: [''],
                            size: 40,
                            userName: '?',
                            userId: '?',
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
