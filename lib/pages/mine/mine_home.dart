import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/help/circle/circle_my.dart';
import 'package:unionchat/pages/mine/customer_list.dart';
import 'package:unionchat/pages/mine/more_function.dart';
import 'package:unionchat/pages/mine/search_user.dart';
import 'package:unionchat/pages/setting/my_card.dart';
import 'package:unionchat/pages/vip/vip_buy.dart';
import 'package:unionchat/pages/wallet/wallet_home.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:provider/provider.dart';

import '../../widgets/user_name_tags.dart';
import '../collect/collect_home.dart';
import '../mall/mall_home.dart';
import '../note/note_home.dart';
import '../notice/notice_list.dart';
import '../photo_album/photo_home.dart';
import 'mine_setting.dart';

class MineHome extends StatefulWidget {
  const MineHome({super.key});

  static const String path = 'mine/mine_home';

  @override
  State<StatefulWidget> createState() {
    return _MineHomeState();
  }
}

class _MineHomeState extends State<MineHome> {
  bool showCount = false;
  bool showIntegral = false;

  double avatarSize = 83;
  double paddingSize = 16;
  double avatarFrameSizeHight = 40;
  double avatarFrameSizeWidth = 30;
  double avatarTopPadding = 12;
  double liangSize = 26;
  double integral = 0.0;
  String userNo = '';

  //获取用户信息
  getUserInfo() async {
    await Global.syncLoginUser();
    if (!mounted) return;
    if (!Global.im && FunctionConfig.integral) {
      integral = toDouble(Global.user?.integral ?? '');
    }
    if (Global.im) {
      final api = UserFundApi(apiClient());
      try {
        var res = await api.userFundInfo({});
        if (res == null || !mounted) return;
        logger.i(res);
        integral = toDouble(api2number(res.balance));
      } on ApiException catch (e) {
        onError(e);
      } catch (e) {
        logger.e(e);
      } finally {}
    }
    if (mounted) setState(() {});
    // logger.d(Global.user);
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    userNo = (Global.user?.account ?? '').isNotEmpty
        ? Global.user!.account!
        : '未设置'.tr();
    String userNumber = (Global.user?.userNumber ?? '').isNotEmpty
        ? Global.user!.userNumber!
        : '';
    String phone =
        (Global.user?.phone ?? '').isNotEmpty ? Global.user!.phone! : '';
    switch (Global.user?.userExtend?.showName) {
      case GShowNameType.ACCOUNT:
        break;
      case GShowNameType.PHONE:
        userNo = phone;
        break;
      case GShowNameType.NUMBER:
        userNo = userNumber;
        break;
      case GShowNameType.NIL:
        break;
    }
    return ThemeImage(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //tab功能条
                Container(
                  height: 56 - avatarFrameSizeHight / 2,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Adapter.navigatorTo(
                            MyCardPage.path,
                          );
                        },
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            assetPath('images/my/fengxiang.png'),
                            height: 18,
                            width: 18,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ),

                Container(
                  // margin: EdgeInsets.only(top: avatarFrameSizeHight / 2),
                  padding: EdgeInsets.symmetric(horizontal: paddingSize),
                  decoration: BoxDecoration(
                    color: myColors.themeBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      //预留头像组件高度
                      // _userWidget(),
                      // Container(
                      //   height: avatarSize + avatarFrameSizeHight / 2 + 5,
                      // ),
                      //头像、名称条
                      _userWidget(),
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
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
                          child: Column(
                            children: [
                              _appNoticeWidget(),
                              MenuUl(
                                marginTop: 0,
                                bottomBoder: true,
                                boxColor: Colors.transparent,
                                buttonColor: Colors.transparent,
                                // fontWeight: FontWeight.w500,
                                children: [
                                  MenuItemData(
                                    title: '派聊钱包'.tr(),
                                    needColor: myColors.isDark,
                                    onTap: () {
                                      Adapter.navigatorTo(WalletHome.path);
                                    },
                                  ),
                                  MenuItemData(
                                    title: '我的会员'.tr(),
                                    needColor: myColors.isDark,
                                    onTap: () {
                                      Adapter.navigatorTo(VipBuy.path).then(
                                        (value) async {
                                          await Global.syncLoginUser();
                                          if (!mounted) return;
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                  if (FunctionConfig.mall)
                                    MenuItemData(
                                      needColor: myColors.isDark,
                                      title: '派聊商城'.tr(),
                                      onTap: () {
                                        Adapter.navigatorTo(MallHome.path).then(
                                          (value) async {
                                            await Global.syncLoginUser();
                                            if (!mounted) return;
                                            setState(() {});
                                          },
                                        );
                                      },
                                    ),
                                  MenuItemData(
                                    needColor: myColors.isDark,
                                    title: '我的收藏'.tr(),
                                    onTap: () {
                                      Adapter.navigatorTo(CollectHome.path);
                                    },
                                  ),
                                  MenuItemData(
                                    needColor: myColors.isDark,
                                    title: '我的笔记'.tr(),
                                    onTap: () {
                                      Adapter.navigatorTo(NoteHome.path,
                                          arguments: {'share': true});
                                    },
                                  ),
                                  MenuItemData(
                                    title: '我的圈子'.tr(),
                                    needColor: myColors.isDark,
                                    onTap: () {
                                      Adapter.navigatorTo(CircleMy.path);
                                    },
                                  ),
                                  if (FunctionConfig.superAlbum)
                                    MenuItemData(
                                      needColor: myColors.isDark,
                                      title: '超级相册'.tr(),
                                      onTap: () {
                                        Adapter.navigatorTo(PhotoHome.path);
                                      },
                                    ),
                                  MenuItemData(
                                    needColor: myColors.isDark,
                                    title: '客服列表'.tr(),
                                    onTap: () {
                                      Adapter.navigatorTo(CustomerList.path);
                                    },
                                  ),
                                  MenuItemData(
                                    needColor: myColors.isDark,
                                    title: '智能助手'.tr(),
                                    onTap: () {
                                      Adapter.navigatorTo(SearchUser.path);
                                    },
                                  ),

                                  // MenuItemData(
                                  //   needColor: myColors.isDark,
                                  //   title: '隐私安全'.tr(),
                                  //   arrow: false,
                                  //   onTap: () {
                                  //     Adapter.navigatorTo(SettingHome.path);
                                  //   },
                                  // ),
                                  // MenuItemData(
                                  //   needColor: myColors.isDark,
                                  //   title: '问卷调查'.tr(),
                                  //   arrow: false,
                                  //   onTap: () {
                                  //     Adapter.navigatorTo(Surveys.path);
                                  //   },
                                  // ),
                                  // MenuItemData(
                                  //   needColor: myColors.isDark,
                                  //   title: '帮助中心'.tr(),
                                  //   arrow: false,
                                  //   onTap: () {
                                  //     Adapter.navigatorTo(QuestionList.path);
                                  //   },
                                  // ),
                                  // MenuItemData(
                                  //   needColor: myColors.isDark,
                                  //   title: '投诉建议'.tr(),
                                  //   arrow: false,
                                  //   onTap: () {
                                  //     Adapter.navigatorTo(Complain.path);
                                  //   },
                                  // ),

                                  MenuItemData(
                                    needColor: myColors.isDark,
                                    title: '更多功能'.tr(),
                                    onTap: () =>
                                        Adapter.navigatorTo(MoreFunction.path),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Container(
                //   color: myColors.themeBackgroundColor,
                //   alignment: Alignment.center,
                // )
                // //个人信息
                // Container(
                //   color: bgColor,
                //   child: Container(
                //     width: double.infinity,
                //     constraints: const BoxConstraints(
                //       minHeight: 175,
                //     ),
                //     padding: EdgeInsets.only(
                //       left: Global.userVip ? 25 - avatarFrameSize / 2 : 25,
                //       right: Global.userVip ? 25 - avatarFrameSize / 2 : 25,
                //       // top: 5,
                //       // bottom: 15,
                //     ),
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: ExactAssetImage(assetPath('images/myBg.png')),
                //         alignment: Alignment.topCenter,
                //         fit: BoxFit.fitWidth,
                //       ),
                //     ),
                //     child: SafeArea(
                //       bottom: false,
                //       child: Column(
                //         // mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         children: [
                //           //分享
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               GestureDetector(
                //                 onTap: () {
                //                   Adapter.navigatorTo(
                //                     MyCardPage.path,
                //                   );
                //                 },
                //                 child: Container(
                //                   alignment: Alignment.center,
                //                   child: Image.asset(
                //                     assetPath('images/my/fengxiang.png'),
                //                     height: 25,
                //                     width: 25,
                //                     color: topColor,
                //                   ),
                //                 ),
                //               ),
                //             ],
                //           ),
                //           GestureDetector(
                //             behavior: HitTestBehavior.opaque,
                //             onTap: () {
                //               Adapter.navigatorTo(MineSetting.path)
                //                   .then((value) async {
                //                 await Global.loginUser();
                //                 if (mounted) setState(() {});
                //               });
                //             },
                //             child: Row(
                //               children: [
                //                 //头像
                //                 AppAvatar(
                //                   list: [
                //                     Global.user?.avatar ?? '',
                //                   ],
                //                   userName: Global.user?.nickname ?? '',
                //                   userId: Global.user?.id ?? '',
                //                   size: avatarSize,
                //                   avatarFrameSize: avatarFrameSize,
                //                   vip: Global.userVip,
                //                   vipLevel: Global.userVipLevel,
                //                 ),
                //                 //名称账号
                //                 Expanded(
                //                   child: Container(
                //                     padding: const EdgeInsets.only(
                //                       left: 10,
                //                     ),
                //                     child: Column(
                //                       children: [
                //                         Row(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.start,
                //                           children: [
                //                             Flexible(
                //                               child: UserNameTags(
                //                                 color: Global.userVip
                //                                     ? myColors.vipName
                //                                     : myColors.white,
                //                                 userName:
                //                                     (Global.user?.nickname ?? '')
                //                                             .isNotEmpty
                //                                         ? Global.user!.nickname!
                //                                         : '未设置'.tr(),
                //                                 select: false,
                //                                 needMarqueeText: true,
                //                                 vip: Global.userVip,
                //                                 vipLevel: Global.userVipLevel,
                //                                 vipBadge: Global.user?.userExtend
                //                                         ?.vipBadge ??
                //                                     GBadge.NIL,
                //                                 onlyName: Global.userOnlyName,
                //                                 goodNumber: Global
                //                                             .user
                //                                             ?.userExtend
                //                                             ?.showName ==
                //                                         GShowNameType.NUMBER
                //                                     ? Global.userGoodNumber
                //                                     : false,
                //                                 numberType:
                //                                     Global.user?.userNumberType ??
                //                                         GUserNumberType.NIL,
                //                                 circleGuarantee: toBool(Global
                //                                     .user
                //                                     ?.userExtend
                //                                     ?.circleGuarantee),
                //                                 fontSize: 25,
                //                                 fontWeight: FontWeight.bold,
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         const SizedBox(height: 10),
                //                         //账号
                //                         Row(
                //                           mainAxisAlignment:
                //                               MainAxisAlignment.start,
                //                           children: [
                //                             Image.asset(
                //                               assetPath('images/my/logo.png'),
                //                               width: 18,
                //                               height: 18,
                //                               // color: myColors.im2CircleTitle,
                //                               fit: BoxFit.contain,
                //                             ),
                //                             const SizedBox(
                //                               width: 3,
                //                             ),
                //                             Flexible(
                //                               child: Text(
                //                                 '账号：'.tr(args: [userNo]),
                //                                 overflow: TextOverflow.ellipsis,
                //                                 style: TextStyle(
                //                                   color: Global.user!
                //                                                   .userNumber !=
                //                                               '' &&
                //                                           userNo == userNumber
                //                                       ? myColors.vipName
                //                                       : myColors.im2CircleTitle,
                //                                   fontSize: 15,
                //                                 ),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                         const SizedBox(height: 8),
                //                         Row(
                //                           // mainAxisAlignment:
                //                           //     MainAxisAlignment.center,
                //                           children: [
                //                             Image.asset(
                //                               assetPath('images/kaopu.png'),
                //                               width: 16,
                //                               height: 16,
                //                             ),
                //                             const SizedBox(
                //                               width: 3,
                //                             ),
                //                             Flexible(
                //                               child: Text(
                //                                 Global.user?.userExtend
                //                                         ?.reliable ??
                //                                     '0',
                //                                 // '靠谱草 * '.tr(args: [
                //                                 //   Global.user?.userExtend
                //                                 //           ?.reliable ??
                //                                 //       '0'
                //                                 // ]),
                //                                 style: TextStyle(
                //                                   color: myColors.im2CircleTitle,
                //                                   fontSize: 15,
                //                                 ),
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ),
                //                 Image.asset(
                //                   assetPath('images/my/sp_qiansejiantou.png'),
                //                   width: 25,
                //                   height: 25,
                //                   color: myColors.im2CircleTitle,
                //                   fit: BoxFit.contain,
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // Container(
                //   margin: const EdgeInsets.symmetric(
                //     horizontal: 20,
                //     vertical: 20,
                //   ),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(20),
                //     // color: myColors .mineBoxColor,
                //     boxShadow: myColors.isDark
                //         ? null
                //         : [
                //             BoxShadow(
                //               color: myColors.readBg,
                //               blurRadius: 10,
                //               offset: const Offset(0, 3),
                //             ),
                //           ],
                //   ),
                //   child: Container(
                //     padding: const EdgeInsets.only(
                //       top: 10,
                //       bottom: 25,
                //       right: 10,
                //       left: 5,
                //     ),
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(20),
                //       color: mineBoxColor,
                //     ),
                //     child: MenuUl(
                //       marginTop: 0,
                //       bottomBoder: true,
                //       boxColor: Colors.transparent,
                //       buttonColor: Colors.transparent,
                //       // fontWeight: FontWeight.w500,
                //       children: [
                //         // if (notice != null && toInt(notice?.id) > 0)
                //         MenuItemData(
                //           needColor: myColors.isDark,
                //           title: '系统公告'.tr(),
                //           icon: assetPath('images/my/gonggao.png'),
                //           onTap: () {
                //             // if (notice == null) return;
                //             notifier.noticeNotRead = 0;
                //             Adapter.navigatorTo(NoticeList.path);
                //           },
                //           arrow: false,
                //           content: badges.Badge(
                //             showBadge: notifier.noticeNotRead > 0,
                //             badgeContent: Text(
                //               notifier.noticeNotRead.toString(),
                //               style: TextStyle(
                //                 color: myColors.white,
                //                 fontSize: 12,
                //               ),
                //             ),
                //           ),
                //         ),
                //         MenuItemData(
                //           needColor: myColors.isDark,
                //           title: '智能助手'.tr(),
                //           icon: assetPath('images/my/sp_yinsianquani.png'),
                //           onTap: () {
                //             Adapter.navigatorTo(SearchUser.path);
                //           },
                //           arrow: false,
                //         ),
                //         MenuItemData(
                //           title: '我的圈子'.tr(),
                //           icon: assetPath('images/help/circle_name.png'),
                //           needColor: myColors.isDark,
                //           onTap: () {
                //             Adapter.navigatorTo(CircleMy.path);
                //           },
                //           arrow: false,
                //         ),
                //         //  if (Global.im || (!Global.im && FunctionConfig.integral))
                //         //   GestureDetector(
                //         //     onTap: () {
                //         //       if (!Global.im && FunctionConfig.integral) {
                //         //         Adapter.navigatorTo(WalletHome.path);
                //         //       }
                //         //       if (Global.im) {
                //         //         Adapter.navigatorTo(WalletNewHome.path);
                //         //       }
                //         //     },
                //         //     child: Container(
                //         //       width: 80,
                //         //       height: 30,
                //         //       alignment: Alignment.centerRight,
                //         //       decoration: BoxDecoration(
                //         //         image: DecorationImage(
                //         //           image: ExactAssetImage(
                //         //               assetPath('images/my/feioubinBg.png')),
                //         //           alignment: Alignment.topCenter,
                //         //           fit: BoxFit.contain,
                //         //         ),
                //         //       ),
                //         //     ),
                //         //   ),
                //         if (Global.im || (!Global.im && FunctionConfig.integral))
                //           MenuItemData(
                //             needColor: myColors.isDark,
                //             title: '派聊钱包'.tr(),
                //             icon: assetPath('images/my/sp_qianbao.png'),
                //             onTap: () {
                //               if (!Global.im && FunctionConfig.integral) {
                //                 Adapter.navigatorTo(WalletHome.path);
                //               }
                //               if (Global.im) {
                //                 Adapter.navigatorTo(WalletNewHome.path);
                //               }
                //             },
                //             arrow: false,
                //           ),
                //         // if (Global.im)
                //         //   MenuItemData(
                //         //     title: '我的钱包'.tr(),
                //         //     icon: assetPath('images/my/sp_qianbao.png'),
                //         //     onTap: () {
                //         //       Adapter.navigatorTo(WalletNewHome.path);
                //         //     },
                //         //     arrow: false,
                //         //   ),
                //         if (FunctionConfig.vip)
                //           MenuItemData(
                //             needColor: myColors.isDark,
                //             title: '我的会员'.tr(),
                //             icon: assetPath('images/my/sp_huiyuan.png'),
                //             onTap: () {
                //               Adapter.navigatorTo(VipBuy.path).then(
                //                 (value) async {
                //                   await Global.loginUser();
                //                   if (!mounted) return;
                //                   setState(() {});
                //                 },
                //               );
                //             },
                //             arrow: false,
                //           ),
                //         MenuItemData(
                //           needColor: myColors.isDark,
                //           title: '我的收藏'.tr(),
                //           arrow: false,
                //           icon: assetPath('images/my/sp_shouchang.png'),
                //           onTap: () {
                //             Adapter.navigatorTo(CollectHome.path);
                //           },
                //         ),
                //         if (FunctionConfig.superAlbum)
                //           MenuItemData(
                //             needColor: myColors.isDark,
                //             title: '超级相册'.tr(),
                //             arrow: false,
                //             icon: assetPath('images/my/btn_chaojixiangce.png'),
                //             onTap: () {
                //               Adapter.navigatorTo(PhotoHome.path);
                //             },
                //           ),
                //         if (FunctionConfig.mall)
                //           MenuItemData(
                //             needColor: myColors.isDark,
                //             title: '派聊商城'.tr(),
                //             arrow: false,
                //             icon: assetPath('images/my/sp_shangcheng.png'),
                //             onTap: () {
                //               Adapter.navigatorTo(MallHome.path).then(
                //                 (value) async {
                //                   await Global.loginUser();
                //                   if (!mounted) return;
                //                   setState(() {});
                //                 },
                //               );
                //             },
                //           ),
                //         MenuItemData(
                //           needColor: myColors.isDark,
                //           title: '我的笔记'.tr(),
                //           arrow: false,
                //           icon: assetPath('images/my/sp_biji.png'),
                //           onTap: () {
                //             Adapter.navigatorTo(NoteHome.path,
                //                 arguments: {'share': true});
                //           },
                //         ),
                //         // if (FunctionConfig.vip)
                //         //   MenuItemData(
                //         //     title: '等级信息'.tr(),
                //         //     icon: assetPath('images/my/sp_lianghaoduihuan.png'),
                //         //     onTap: () {
                //         //       Adapter.navigatorTo(LevelInfo.path);
                //         //     },
                //         //   ),
                //         // MenuItemData(
                //         //   title: '个人中心',
                //         //   icon: assetPath('images/my/sp_gerenzhongxin.png'),
                //         //   onTap: () {
                //         //     Adapter.navigatorTo(MineSetting.path).then((value) async {
                //         //       await Global.loginUser();
                //         //       if (!mounted) return;
                //         //       setState(() {});
                //         //     });
                //         //   },
                //         // ),
                //         // MenuItemData(
                //         //   title: '增值服务'.tr(),
                //         //   icon: assetPath('images/my/sp_lianghaoduihuan.png'),
                //         //   onTap: () {
                //         //     Adapter.navigatorTo(MineService.path);
                //         //   },
                //         //   arrow: false,
                //         // ),
                //         // if (platformPhone)
                //         //   MenuItemData(
                //         //     title: '朋友圈'.tr(),
                //         //     icon: assetPath('images/my/pengyouquan.png'),
                //         //     onTap: () {
                //         //       Adapter.navigatorTo(CommunityHome.path);
                //         //     },
                //         //   ),
                //         // if (FunctionConfig.goodNumber)
                //         //   MenuItemData(
                //         //     title: '兑换靓号'.tr(),
                //         //     icon: assetPath('images/my/sp_lianghaoduihuan.png'),
                //         //     onTap: () {
                //         //       Adapter.navigatorTo(GoodNumberCashPage.path).then(
                //         //         (value) async {
                //         //           if (value) {
                //         //             await Global.loginUser();
                //         //             setState(() {});
                //         //           }
                //         //         },
                //         //       );
                //         //     },
                //         //   ),
                //         MenuItemData(
                //           needColor: myColors.isDark,
                //           title: '更多功能'.tr(),
                //           icon: assetPath('images/my/help_question.png'),
                //           onTap: () => Adapter.navigatorTo(MoreFunction.path),
                //           arrow: false,
                //         ),
                //         // MenuItemData(
                //         //   needColor:
                //         //       context.read<ThemeNotifier>().switchSelected ==
                //         //           'dark',
                //         //   title: '帮助中心'.tr(),
                //         //   icon: assetPath('images/my/help_question.png'),
                //         //   onTap: () {
                //         //     Adapter.navigatorTo(QuestionList.path);
                //         //   },
                //         //   arrow: false,
                //         // ),
                //         // MenuItemData(
                //         //   needColor:
                //         //       context.read<ThemeNotifier>().switchSelected ==
                //         //           'dark',
                //         //   title: '问卷调查'.tr(),
                //         //   icon: assetPath('images/my/help_question.png'),
                //         //   onTap: () {
                //         //     Adapter.navigatorTo(Surveys.path);
                //         //   },
                //         //   arrow: false,
                //         // ),
                //         // MenuItemData(
                //         //   title: '关于我们'.tr(),
                //         //   icon: assetPath('images/my/sp_guanyuwomen.png'),
                //         //   onTap: () => Adapter.navigatorTo(AboutAppPage.path),
                //         //   arrow: false,
                //         // ),
                //       ],
                //     ),
                //   ),
                // ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
                //   child: CircleButton(
                //     theme: AppButtonTheme.red,
                //     onTap: () {
                //       confirm(
                //         context,
                //         content: '是否确定退出登录？'.tr(),
                //         onEnter: () async {
                //           await Global.loginOut();
                //         },
                //       );
                //     },
                //     fontSize: 15,
                //     height: 45,
                //     radius: 50,
                //     title: '退出登录'.tr(),
                //   ),
                // ),
                // const TabBottomHeight(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //用户列表
  Widget _userWidget() {
    var myColors = ThemeNotifier();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Adapter.navigatorTo(MineSetting.path).then((value) async {
          await Global.syncLoginUser();
          if (mounted) setState(() {});
        });
      },
      child: Container(
        padding: const EdgeInsets.only(
            //    left: 8,
            //   right: paddingSize,
            ),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: avatarSize + avatarFrameSizeWidth + 8,
              height: avatarSize + avatarFrameSizeHight + 5,
              alignment: Alignment.center,
              child: AppAvatar(
                list: [
                  Global.user?.avatar ?? '',
                ],
                userName: Global.user?.nickname ?? '',
                userId: Global.user?.id ?? '',
                size: avatarSize,
                avatarFrameHeightSize: avatarFrameSizeHight,
                avatarFrameWidthSize: avatarFrameSizeWidth,
                avatarTopPadding: avatarTopPadding,
                vip: Global.loginUser!.userVip,
                vipLevel: Global.loginUser!.userVipLevel,
              ),
            ),
            //名称账号
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //名称
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: UserNameTags(
                                  color: Global.loginUser!.userVip
                                      ? myColors.vipName
                                      : myColors.iconThemeColor,
                                  userName:
                                      (Global.user?.nickname ?? '').isNotEmpty
                                          ? Global.user!.nickname!
                                          : '未设置'.tr(),
                                  select: false,
                                  needMarqueeText: true,
                                  vip: Global.loginUser!.userVip,
                                  vipLevel: Global.loginUser!.userVipLevel,
                                  vipBadge: Global.user?.userExtend?.vipBadge ??
                                      GBadge.NIL,
                                  onlyName: Global.loginUser!.userOnlyName,
                                  goodNumber:
                                      Global.user?.userExtend?.showName ==
                                              GShowNameType.NUMBER
                                          ? Global.loginUser!.userGoodNumber
                                          : false,
                                  numberType: Global.user?.userNumberType ??
                                      GUserNumberType.NIL,
                                  circleGuarantee: toBool(
                                      Global.user?.userExtend?.circleGuarantee),
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          //账号
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: myColors.accountTagBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '账号：'.tr(args: [userNo]),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: myColors.accountTagTitle,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          //靠谱值
                          Row(
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
                                  Global.user?.userExtend?.reliable ?? '0',
                                  style: TextStyle(
                                    color: myColors.iconThemeColor,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.settings,
                      size: 25,
                      color: myColors.subIconThemeColor,
                    ),
                    // Image.asset(
                    //   assetPath('images/my/jiantou.png'),
                    //   width: 7,
                    //   height: 13,
                    //   fit: BoxFit.contain,
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 头部公告
  Widget _appNoticeWidget() {
    var myColors = ThemeNotifier();
    return ValueListenableBuilder(
      valueListenable: UnreadValue.notice,
      builder: (context, notice, _) {
        return ValueListenableBuilder(
          valueListenable: UnreadValue.noticeNotRead,
          builder: (context, noticeNotRead, _) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                noticeNotRead = 0;
                Adapter.navigatorTo(NoticeList.path);
              },
              child: Container(
                padding: const EdgeInsets.only(bottom: 5),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 0.5,
                      color: myColors.circleBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        assetPath('images/talk/gonggao.png'),
                        width: 16,
                        height: 16,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 35,
                        child: Marquee(
                          // text: '公告',
                          text: notice?.title ?? ' ',
                          blankSpace: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: myColors.iconThemeColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
