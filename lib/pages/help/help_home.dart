import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/help/circle/circle_my.dart';
import 'package:unionchat/pages/help/help_create.dart';
import 'package:unionchat/pages/help/help_home_select.dart';
import 'package:unionchat/widgets/animation_fade_out.dart';
import 'package:unionchat/widgets/community_item.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class HelpHome extends StatefulWidget {
  const HelpHome({super.key});

  static const String path = 'help/home';

  @override
  State<StatefulWidget> createState() {
    return _HelpHomeState();
  }
}

class _HelpHomeState extends State<HelpHome> {
  //多选列圈子id
  List<String> circleIdList = [];

  //多选列圈子id
  List<String> areaCodeList = [];

  // 顶部推荐列标题颜色
  Color titleColor = ThemeNotifier().white;

  // List<String> _banner = [];

  //动态数据
  static List<CommunityItemData> circleData = [];
  int rowLimit = 5;
  int limit = 20;

  //需要显示初始加载
  bool listInit = true;

  //初始加载后数据为空
  bool noList = false;

// //圈子消息提醒开关
//   bool notificationsSelect = false;
  //圈子消息提醒加载状态
  bool loadingStatus = false;

  // //获取banner
  // getBanner() async {
  //   final api = BannerApi(apiClient());
  //   try {
  //     // _banner = [];
  //     final res = await api
  //         .bannerList(V1ListBannerArgs(bannerType: GBannerType.CIRCLE));
  //     if (res == null) return;
  //     List<String> a = [];
  //     for (var v in res.list) {
  //       a.add(v.image!);
  //     }
  //     _banner = a;
  //     if (!mounted) return;
  //     setState(() {});
  //   } on ApiException catch (e) {
  //     onError(e);
  //   } finally {}
  // }

  //获取动态列表
  Future<int> getList({bool init = false}) async {
    // if (circleData.isNotEmpty && listInit) {
    //   listInit = false;
    //   if (mounted) setState(() {});
    // }
    final api = CircleApi(apiClient());
    try {
      var args = V1ListCircleArticleArgs(
        areaCode: areaCodeList,
        circleId: circleIdList,
        isMe: GSure.NO,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : circleData.length.toString(),
        ),
      );
      // logger.d(args);
      final res = await api.circleListCircleArticle(args);
      if (res == null) return 0;
      List<CommunityItemData> newCirlceData = [];
      for (var v in res.list) {
        newCirlceData.add(
          CommunityItemData(
            userInfo: v.userInfo,
            id: v.id ?? '',
            userId: v.userId ?? '',
            avatar: v.userInfo?.avatar ?? '',
            nickName: v.userInfo?.nickname ?? '',
            text: v.content,
            photos: v.images,
            photosType: v.articleType,
            date: v.createTime ?? '',
            targetId: v.circleId,
            target: v.circleName,
            areaName: v.areaName,
            userNumber: v.userInfo?.userNumber,
            numberType: v.userInfo?.userNumberType,
            circleGuarantee: toBool(v.userInfo?.userExtend?.circleGuarantee),
            userVip: toInt(v.userInfo?.userExtend?.vipExpireTime) >=
                toInt(date2time(null)),
            userVipLevel: v.userInfo?.userExtend?.vipLevel ?? GVipLevel.NIL,
            vipBadge: v.userInfo?.userExtend?.vipBadge ?? GBadge.NIL,
            userOnlyName: toBool(v.userInfo?.useChangeNicknameCard),
          ),
        );
      }
      if (!mounted) return 0;
      if (init) {
        circleData = newCirlceData;

        UnreadValue.circleNotRead.value.circleTrendsNotRead = 0;

        if (circleData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleData.addAll(newCirlceData);
      }

      if (listInit) listInit = false;
      setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

//获取首页用户筛选
  getUserSelect() async {
    circleIdList = [];
    areaCodeList = [];
    try {
      final api = CircleApi(apiClient());
      final res = await api.circleGetUserCircleSet({});
      if (res == null) return;
      if ((res.circleId ?? '').isNotEmpty) {
        circleIdList = res.circleId!.split(',');
      }
      if ((res.areaCode ?? '').isNotEmpty) {
        areaCodeList = res.areaCode!.split(',');
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //更新圈子声音提醒
  saveCircleNotice() async {
    loadingStatus = true;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 200))
        .then((_) => setState(() => loadingStatus = false));
    logger.i(circleNoticeOpen);
    if (circleNoticeOpen) {
      await settingsBox.delete('circleNotice');
    } else {
      await settingsBox.put('circleNotice', '1');
    }
    setState(() {});
    // GSure status;
    // notificationsSelect == true ? status = GSure.YES : status = GSure.NO;
    // var api = UserApi(apiClient());
    // try {
    //   await api.userSetBasicInfo(
    //       V1SetBasicInfoArgs(isCircleSound: SetBasicInfoArgsIs(is_: status)));
    //   await Global.loginUser();
    //   if (!mounted) return;
    //   setState(() {});
    // } on ApiException catch (e) {
    //   if (notificationsSelect) {
    //     notificationsSelect = false;
    //   } else {
    //     notificationsSelect = true;
    //   }
    //   setState(() {});
    //   tip('设置失败'.tr());
    //   onError(e);
    // } finally {}
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    //圈子消息提醒开关
    // notificationsSelect =
    //     Global.user?.userExtend?.isCircleSound == GSure.YES ? true : false;
    return ThemeImage(
      child: Scaffold(
        appBar: AppBar(
          titleTextStyle: TextStyle(
            color: myColors.iconThemeColor,
            fontWeight: FontWeight.normal,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Text(
                '圈子广场',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 28,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, CircleMy.path);
                },
                child: ValueListenableBuilder(
                  valueListenable: UnreadValue.circleMyApplyNotRead,
                  builder: (context, myApply, _) {
                    return ValueListenableBuilder(
                      valueListenable: UnreadValue.circleApplyNotRead,
                      builder: (context, value, _) {
                        final int circleNotRead =
                            value.applicationNotRead + myApply;
                        return Badge(
                          offset: const Offset(5, 0),
                          largeSize: 8,
                          isLabelVisible: circleNotRead > 0,
                          backgroundColor: myColors.redTitle,
                          label: const Text(
                            '',
                          ),
                          child: const Text(
                            '我的圈子',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: saveCircleNotice,
                  child: loadingStatus
                      ? const CupertinoActivityIndicator(radius: 7)
                      : Icon(circleNoticeOpen
                          ? Icons.notifications_active
                          : Icons.notifications_off),
                ),
                const SizedBox(
                  width: 9,
                ),
                IconButton(
                  onPressed: () {
                    circleData = [];
                    Navigator.pushNamed(context, HelpHomeSelect.path)
                        .then((value) async {
                      await getUserSelect();
                      await getList(init: true);
                    });
                  },
                  icon: Image.asset(
                    assetPath('images/help/saixuan.png'),
                    width: 18,
                    height: 18,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
          ],
        ),

        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: PagerBox(
                    limit: limit,
                    needInitBox: listInit,
                    showStateText: !listInit && !noList,
                    onInit: () async {
                      //初始化

                      await getUserSelect();
                      return await getList(init: true);
                    },
                    onPullDown: () async {
                      //下拉刷新

                      await getUserSelect();
                      return await getList(init: true);
                    },
                    onPullUp: () async {
                      //上拉加载
                      return await getList();
                    },
                    children: [
                      // //轮播图
                      // AppSwiper(
                      //   list: _banner,
                      //   height: bannerWidth * 3 / 5,
                      //   appNetworkImageHeight: bannerWidth * 3 / 5,
                      //   appNetworkImageWidth: bannerWidth,
                      //   onTap: (index) {
                      //     Navigator.pushNamed(context, NoticeDetail.path);
                      //   },
                      // ),
                      // //更多圈子
                      // Container(
                      //   padding: const EdgeInsets.only(
                      //     right: 6,
                      //     bottom: 10,
                      //   ),
                      //   alignment: Alignment.centerRight,
                      //   color: myColors .white,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       Navigator.pushNamed(
                      //         context,
                      //         CircleMore.path,
                      //       );
                      //     },
                      //     child: const Text(
                      //       '更多圈子》',
                      //       style: TextStyle(fontSize: 12),
                      //     ),
                      //   ),
                      // ),
                      // //圈子推荐项
                      // Container(
                      //   // margin: const EdgeInsets.only(bottom: 15),
                      //   // padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                      //   decoration: const BoxDecoration(
                      //     color: myColors .white,
                      //   ),
                      //   child: RowList(
                      //     rowNumber: 5,
                      //     lineSpacing: 10,
                      //     children: [
                      //       for (var i = 0; i < circle.length; i++)
                      //         GroupItem(
                      //           imageSize: 53,
                      //           fontSize: 10,
                      //           circleId: circle[i].circleId,
                      //           icon: circle[i].icon,
                      //           title: circle[i].title,
                      //           onTap: () => Navigator.pushNamed(
                      //               context, GroupHome.path,
                      //               arguments: {'circleId': circle[i].circleId}),
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      // //推荐圈子
                      // Padding(
                      //   padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                      //   child: Container(
                      //     alignment: Alignment.centerLeft,
                      //     // color: myColors .white,
                      //     child: SingleChildScrollView(
                      //       scrollDirection: Axis.horizontal,
                      //       child: Row(
                      //         children: [
                      //           for (var i = 0; i < circle.length; i++)
                      //             GestureDetector(
                      //               onTap: () {
                      //                 Navigator.pushNamed(
                      //                     context, GroupHome.path,
                      //                     arguments: {
                      //                       'circleId': circle[i].circleId
                      //                     });
                      //               },
                      //               child: Stack(
                      //                 children: [
                      //                   AppNetworkImage(
                      //                     circle[i].icon,
                      //                     backgroundColor:
                      //                         Colors.transparent,
                      //                     width: bannerWidth,
                      //                     height: bannerWidth * 0.5,
                      //                     marginLeft: 6,
                      //                     marginRight: 6,
                      //                     borderRadius:
                      //                         BorderRadius.circular(15),
                      //                     fit: BoxFit.cover,
                      //                     imageSpecification:
                      //                         ImageSpecification.w230,
                      //                   ),
                      //                   Positioned(
                      //                     left: 15,
                      //                     bottom: 15,
                      //                     child: Container(
                      //                       // color: Colors.red,
                      //                       alignment: Alignment.center,
                      //                       child: Row(
                      //                         children: [
                      //                           Container(
                      //                             height: 20,
                      //                             width: 20,
                      //                             alignment:
                      //                                 Alignment.center,
                      //                             child: Image.asset(
                      //                               assetPath(
                      //                                   'images/help/sp_quanzo2.png'),
                      //                               fit: BoxFit.contain,
                      //                             ),
                      //                           ),
                      //                           Padding(
                      //                             padding:
                      //                                 const EdgeInsets.only(
                      //                                     left: 5.0),
                      //                             child: Text(
                      //                               circle[i].title,
                      //                               style: TextStyle(
                      //                                 color: titleColor,
                      //                                 fontSize: 18,
                      //                                 fontWeight:
                      //                                     FontWeight.w600,
                      //                               ),
                      //                             ),
                      //                           ),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   if (i == circle.length - 1 &&
                      //                       circle.length == 5)
                      //                     Positioned(
                      //                       right: 6,
                      //                       child: GestureDetector(
                      //                         onTap: () {
                      //                           Navigator.pushNamed(
                      //                             context,
                      //                             CircleMore.path,
                      //                           );
                      //                         },
                      //                         child: Stack(
                      //                           children: [
                      //                             Opacity(
                      //                               opacity: 0.5,
                      //                               child: Container(
                      //                                 width: bannerWidth *
                      //                                     2 /
                      //                                     5,
                      //                                 height: bannerWidth *
                      //                                     2 /
                      //                                     3,
                      //                                 alignment:
                      //                                     Alignment.center,
                      //                                 decoration:
                      //                                     const BoxDecoration(
                      //                                   color: Colors.black,
                      //                                   borderRadius:
                      //                                       BorderRadius
                      //                                           .only(
                      //                                     topRight: Radius
                      //                                         .circular(15),
                      //                                     bottomRight:
                      //                                         Radius
                      //                                             .circular(
                      //                                                 15),
                      //                                   ),
                      //                                 ),
                      //                                 child: Image.asset(
                      //                                   assetPath(
                      //                                       'images/help/sp_baijiantou.png'),
                      //                                   width: 25,
                      //                                   height: 25,
                      //                                   fit: BoxFit.contain,
                      //                                 ),
                      //                               ),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                 ],
                      //               ),
                      //             ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      if (!listInit && noList)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.8,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                assetPath('images/help/sp_zanwuneirong2.png'),
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '暂无动态'.tr(),
                                style: TextStyle(
                                  color: myColors.textGrey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (circleData.isNotEmpty)
                        //圈子动态列表
                        for (var i = 0; i < circleData.length; i++)
                          GestureDetector(
                            onTap: () {
                              // Navigator.pushNamed(context, HelpDetail.path,
                              //     arguments: {'trendsId': circleData[i].id});
                            },
                            child: CommunityItem(
                              id: circleData[i].id,
                              data: circleData[i],
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: //发布动态
            platformPhone
                ? AnimatedFadeOut(
                    animatedTime: 500,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          HelpCreate.path,
                        ).then((value) {
                          getList(init: true);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: 53,
                        height: 53,
                        child: Image.asset(
                          assetPath('images/help/btn_tianjia.png'),
                          width: 53,
                          height: 53,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  )
                : Container(),
        // floatingActionButton: GestureDetector(
        //   onTap: () {
        //     Navigator.pushNamed(
        //       context,
        //       HelpCreate.path,
        //     ).then((value) {
        //       getList(init: true);
        //     });
        //     // showModalBottomSheet(
        //     //     backgroundColor: Colors.transparent,
        //     //     context: context,
        //     //     builder: (context) {
        //     //       return CommentButton(
        //     //         data: [
        //     //           CommunityButtonData(
        //     //             avatar: assetPath('images/help/btn_fabubangban.png'),
        //     //             title: '发布动态'.tr(),
        //     //             onTap: () {
        //     //               Navigator.pushReplacementNamed(
        //     //                 context,
        //     //                 HelpCreate.path,
        //     //               ).then((value) {
        //     //                 getList(init: true);
        //     //               });
        //     //             },
        //     //           ),
        //     //           CommunityButtonData(
        //     //             avatar: assetPath('images/help/btn_chuangjianquanzi.png'),
        //     //             title: '创建圈子'.tr(),
        //     //             onTap: () {
        //     //               Navigator.pushReplacementNamed(
        //     //                   context, CircleCreate.path);
        //     //             },
        //     //           )
        //     //         ],
        //     //         imageSize: 55,
        //     //         fontSize: 15,
        //     //       );
        //     //     });
        //   },
        //   child: SizedBox(
        //     width: 77,
        //     height: 77,
        //     child: Image.asset(
        //       assetPath('images/help/btn_tianjia.png'),
        //       fit: BoxFit.contain,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}

//圈子列表组件
class GroupItem extends StatelessWidget {
  final String circleId;
  final String icon;
  final String title;
  final double imageSize;
  final double fontSize;
  final Function()? onTap;

  const GroupItem({
    required this.circleId,
    required this.icon,
    required this.title,
    this.onTap,
    this.imageSize = 53,
    this.fontSize = 14,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          AppNetworkImage(
            icon,
            width: imageSize,
            height: imageSize,
            imageSpecification: ImageSpecification.w230,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(50),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

//底部弹出Button Model
class CommunityButtonData {
  //图片
  String avatar;

  //标题
  String title;

  Function()? onTap;

  CommunityButtonData({
    required this.avatar,
    required this.title,
    required this.onTap,
  });
}
