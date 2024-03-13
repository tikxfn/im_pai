import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/enum.dart';
import '../../common/func.dart';
import '../../widgets/avatar.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/photo_preview.dart';
import '../../widgets/search_input.dart';
import '../../widgets/up_loading.dart';
import '../../widgets/user_name_tags.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({super.key});

  static const path = 'mine/search/user';

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  Timer? timer;
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier(LoadStatus.nil);
  final TextEditingController _controller = TextEditingController();
  V1UserRelationResp? _info;
  GUserNumberType userNumberType = GUserNumberType.NIL;

  //靠谱值
  String reliable = '0';

  // 搜索
  _search() async {
    if (_controller.text.isEmpty) return;
    loadStatus.value = LoadStatus.loading;
    _info = null;
    setState(() {});
    var api = UserApi(apiClient());
    try {
      var res = await api.userRelation(V1UserRelationArgs(
        account: _controller.text,
      ));
      if (!mounted) return;
      if (res == null || toInt(res.user?.id) == 0) {
        _info = null;
        loadStatus.value = LoadStatus.no;
      } else {
        _info = res;
        loadStatus.value = LoadStatus.nil;
      }
      reliable = _info?.user?.userExtend?.reliable ?? '0';
      userNumberType = _info?.user?.userNumberType ?? GUserNumberType.NIL;

      setState(() {});
    } on ApiException catch (e) {
      onError(e);
      loadStatus.value = LoadStatus.failed;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return KeyboardBlur(
      child: Scaffold(
        appBar: AppBar(
          title: Text('智能助手'.tr()),
        ),
        body: ThemeBody(
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SearchInput(
                      controller: _controller,
                      hint: '输入账号/靓号/手机号搜索'.tr(),
                      autofocus: true,
                      onSubmitted: (val) => _search(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleButton(
                      title: '搜索'.tr(),
                      theme: AppButtonTheme.blue,
                      width: 70,
                      height: 40,
                      radius: 30,
                      fontSize: 15,
                      onTap: _search,
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: loadStatus,
                builder: (context, value, _) {
                  if (value != LoadStatus.loading && value != LoadStatus.no) {
                    return Container();
                  }
                  logger.d(value);
                  return UpLoading(value);
                },
              ),
              if (_info != null)
                shadowBox(
                  child: Column(
                    children: [
                      // 基本信息
                      Row(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoModalPopupRoute(
                                  builder: (context) {
                                    var avatar = _info?.user?.avatar ?? '';
                                    if (avatar == '@Zombie') {
                                      avatar =
                                          zombieAvatar(_info?.user?.id ?? '');
                                    }
                                    return PhotoPreview(
                                      list: [avatar],
                                      index: 0,
                                      showSave: false,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              width: 70 + 25 + 16,
                              height: 70 + 25 + 10,
                              alignment: Alignment.center,
                              child: AppAvatar(
                                list: [_info?.user?.avatar ?? ''],
                                size: 70,
                                avatarFrameHeightSize: 35,
                                avatarFrameWidthSize: 25,
                                avatarTopPadding: 10,
                                userName: _info?.user?.nickname ?? '',
                                userId: _info?.user?.id ?? '',
                                vip: toInt(_info
                                        ?.user?.userExtend?.vipExpireTime) >=
                                    toInt(date2time(null)),
                                vipLevel: _info?.user?.userExtend?.vipLevel ??
                                    GVipLevel.NIL,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 25,
                                    child: UserNameTags(
                                      userName: _info?.user?.nickname ?? '',
                                      fontSize: 16,
                                      goodNumber:
                                          (_info?.user?.userNumber ?? '')
                                              .isNotEmpty,
                                      numberType: _info?.user?.userNumberType ??
                                          GUserNumberType.NIL,
                                      circleGuarantee: toBool(_info
                                          ?.user?.userExtend?.circleGuarantee),
                                      onlyName: toBool(
                                          _info?.user?.useChangeNicknameCard),
                                      vip: toInt(_info?.user?.userExtend
                                              ?.vipExpireTime) >=
                                          toInt(date2time(null)),
                                      vipLevel:
                                          _info?.user?.userExtend?.vipLevel ??
                                              GVipLevel.NIL,
                                      vipBadge:
                                          _info?.user?.userExtend?.vipBadge ??
                                              GBadge.NIL,
                                      system: UserTypeExt.formMerchantType(
                                              _info?.user?.customerType) ==
                                          UserType.system,
                                      customer: UserTypeExt.formMerchantType(
                                              _info?.user?.customerType) ==
                                          UserType.customer,
                                    ),
                                  ),
                                  //靠谱值
                                  Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          assetPath('images/kaopu.png'),
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        Flexible(
                                          child: Text(
                                            reliable,
                                            style: TextStyle(
                                              color: myColors.iconThemeColor,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //账号
                                  Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: myColors.accountTagBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '账号：'.tr(
                                          args: [_info?.user?.account ?? '']),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: myColors.accountTagTitle,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),

                                  // if (onlineTime.isNotEmpty)
                                  // Container(
                                  //   height: 20,
                                  //   padding: const EdgeInsets.only(top: 2),
                                  //   child: Text(
                                  //     time2onlineDate(_info?.user?.lastOnlineTime,
                                  //         zeroStr: '在线'.tr()),
                                  //     style: TextStyle(
                                  //       fontSize: 12,
                                  //       color: myColors.textGrey,
                                  //     ),
                                  //   ),
                                  // )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      MenuUl(
                        marginTop: 0,
                        bottomBoder: true,
                        children: [
                          // MenuItemData(
                          //   title: '性别'.tr(),
                          //   arrow: false,
                          //   content: Text(sex2text(_info?.user?.sex)),
                          // ),
                          MenuItemData(
                            arrow: false,
                            title: '靓号'.tr(),
                            content: Text(
                              _info?.user?.userNumber ?? '',
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                          MenuItemData(
                            title: '靓号等级'.tr(),
                            arrow: false,
                            content: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Text(
                                //   goodNumberShowstring(userNumberType),
                                //   style: TextStyle(
                                //     color: myColors.textGrey,
                                //   ),
                                // ),
                                if (goodNumberImageString(userNumberType) != '')
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Image.asset(
                                      assetPath(goodNumberImageString(
                                          userNumberType)),
                                      width: 20,
                                      height: 20,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          MenuItemData(
                            arrow: false,
                            title: '注册时间'.tr(),
                            content: Text(
                              time2date(_info?.user?.createTime),
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                          MenuItemData(
                            arrow: false,
                            title: '群聊'.tr(),
                            content: Text(
                              '个'.tr(args: [_info?.rooms ?? '']),
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                          MenuItemData(
                            arrow: false,
                            title: '好友'.tr(),
                            content: Text(
                              '个'.tr(args: [_info?.friends ?? '']),
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              //圈子记录
              if (_info != null)
                shadowBox(
                  child: Column(
                    children: [
                      MenuUl(
                        marginTop: 0,
                        children: [
                          MenuItemData(
                            titleSize: 17,
                            arrow: false,
                            title: '圈子'.tr(),
                            content: Text(
                              '个'.tr(args: [_info!.circles.length.toString()]),
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var e in _info!.circles)
                        ChatItem(
                          data: ChatItemData(
                            icons: [e.image ?? ''],
                            title: e.name ?? '',
                            id: e.id,
                          ),
                        ),
                    ],
                  ),
                ),
              //靓号记录
              if (_info != null)
                shadowBox(
                  child: Column(
                    children: [
                      MenuUl(
                        marginTop: 0,
                        bottomBoder: true,
                        children: [
                          MenuItemData(
                            titleSize: 17,
                            arrow: false,
                            title: '靓号记录',
                          ),
                          for (var e in _info!.userNumberExchange.reversed)
                            MenuItemData(
                              titleColor: myColors.accountTagTitle,
                              arrow: false,
                              title: e.userNumberUid ?? '',
                              content: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: myColors.tagColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  toInt(e.effectiveTime) >
                                          toInt(date2time(null))
                                      ? '当前有效'
                                      : '已过期',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: toInt(e.effectiveTime) >
                                            toInt(date2time(null))
                                        ? myColors.blueTitle
                                        : myColors.redPacketdBg,
                                  ),
                                ),
                              ),
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

//阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: myColors.isDark
            ? null
            : [
                BoxShadow(
                  color: myColors.bottomShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
