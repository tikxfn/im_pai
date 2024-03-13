import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/pages/friend/friend_common_circle.dart';
import 'package:unionchat/pages/friend/friend_common_friend.dart';
import 'package:unionchat/pages/friend/friend_common_group.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';

class FriendDetailSetting extends StatefulWidget {
  const FriendDetailSetting({super.key});

  static const path = 'friend/detail_setting';

  @override
  State<StatefulWidget> createState() {
    return _FriendDetailSettingState();
  }
}

class _FriendDetailSettingState extends State<FriendDetailSetting> {
  double size = 60;
  String userId = '';
  String pairId = '';

  bool mineVip = (Global.user?.userNumber ?? '').isNotEmpty; //我自己是否是vip

  //用户详情
  GUserModel? detail;

  //添加方式
  String addMethod = '';

  //用户详情设置
  GUserFriendModel? detailSetting;

  //是否已加朋友
  bool _isFriend = false;

  //是否已经拉黑
  bool isBlack = false;

  int commonFriend = 0;
  int commonGroup = 0;
  int commonCircle = 0;

  // //清空聊天记录提示
  // removeHistoryConfirm() {
  //   confirm(
  //     context,
  //     content: '确定要清空聊天记录？',
  //     onEnter: () => removeHistory(),
  //   );
  // }

  // //清空聊天记录
  // removeHistory() async {
  //   var api = ChatApi(apiClient());
  //   try {
  //     var args = V1CleanMessageArgs(
  //       pairId: pairId,
  //     );
  //     await api.chatCleanMessage(args);
  //     await DatabaseOperator.clearTopic(pairId);
  //   } on ApiException catch (e) {
  //     onError(e);
  //   }
  // }

  //获取详情
  getDetail() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userUserDetail(GIdArgs(id: userId));
      if (res == null) return;
      setState(() {
        isBlack = res.blackStatus == V1RelationStatus.NIL;
        _isFriend = res.frienStatus == V1RelationStatus.OTHER ||
            res.frienStatus == V1RelationStatus.BOTH;
        detail = res.user;
        commonFriend = toInt(res.user!.commonFriend);
        commonGroup = toInt(res.user!.commonRoom);
        commonCircle = toInt(res.user!.commonCircle);
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
    if (_isFriend) {
      getSetting();
    }
  }

  //获取用户设置
  getSetting() async {
    final api = UserApi(apiClient());
    try {
      final res = await api.userGetUserFriendSetting(GIdArgs(id: userId));
      if (res == null) return;
      setState(() {
        // isTop = res.isTop == GSure.YES;
        // isTip = res.doNotDisturb == GSure.YES;
        detailSetting = res;
        if (detailSetting?.from == GFriendFrom.ID) addMethod = '通过ID添加'.tr();
        if (detailSetting?.from == GFriendFrom.QR) addMethod = '通过二维码添加'.tr();
        if (detailSetting?.from == GFriendFrom.PHONE) addMethod = '通过手机添加'.tr();
        if (detailSetting?.from == GFriendFrom.RECOMMEND) {
          addMethod = '通过推荐添加'.tr();
        }
        if (detailSetting?.from == GFriendFrom.ROOM) addMethod = '通过群添加'.tr();
      });
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      userId = args['id'] ?? '';
      pairId = args['pairId'] ?? '';
      if (userId.isNotEmpty) {
        getDetail();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('更多信息'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            if (FunctionConfig.commonFriend || mineVip)
              MenuUl(
                marginTop: 0,
                children: [
                  MenuItemData(
                    title: '共同群聊'.tr(),
                    content: Text(
                      '个'.tr(args: [commonGroup.toString()]),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FriendCommonGroup.path,
                        arguments: {
                          'userId': userId,
                        },
                      );
                    },
                  ),
                  MenuItemData(
                    title: '共同好友'.tr(),
                    content: Text(
                      '个'.tr(args: [commonFriend.toString()]),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FriendCommonFriend.path,
                        arguments: {
                          'userId': userId,
                        },
                      );
                    },
                  ),
                  MenuItemData(
                    title: '共同圈子'.tr(),
                    content: Text(
                      '个'.tr(args: [commonCircle.toString()]),
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        FriendCommonCircle.path,
                        arguments: {
                          'userId': userId,
                        },
                      );
                    },
                  ),
                ],
              ),
            MenuUl(
              children: [
                MenuItemData(
                  onTap: () {},
                  title: '性别'.tr(),
                  arrow: false,
                  content: Text(
                    detail != null ? sex2text(detail!.sex) : '',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
                MenuItemData(
                  onTap: () {},
                  title: '个性签名'.tr(),
                  arrow: false,
                  content: Text(
                    detail?.slogan ?? '',
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
                MenuItemData(
                  arrow: false,
                  title: '朋友来源'.tr(),
                  content: Text(
                    addMethod,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
