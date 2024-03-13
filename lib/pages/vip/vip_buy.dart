import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/mine/level_info.dart';
import 'package:unionchat/pages/vip/vip_history.dart';
import 'package:unionchat/widgets/animation_fade_out.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../global.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/avatar.dart';
import '../../widgets/button.dart';
import '../../widgets/user_name_tags.dart';

class VipBuy extends StatefulWidget {
  const VipBuy({super.key});

  static const String path = 'vip/buy';

  @override
  State<VipBuy> createState() => _VipBuyState();
}

class _VipBuyState extends State<VipBuy> {
  List<GProductServerModel> vipList = [];
  int vipIndex1 = 0;
  double integral = 0;
  double avatarFrameHeightSize = 25;
  double avatarFrameWidthSize = 18;
  bool waitStatus = false;

  List<VipPayType> payList = [
    VipPayType(title: '微信'.tr(), image: 'images/wechat.png'),
    VipPayType(title: '支付宝'.tr(), image: 'images/alipay.png'),
    VipPayType(title: '余额'.tr(), image: 'images/avatar.png'),
  ];

  _init() async {
    List<Future> futures = [
      Global.syncLoginUser(),
      _getVipPrice(),
    ];

    await Future.wait(futures);
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  //获取vip价格
  _getVipPrice() async {
    var api = OrderApi(apiClient());
    try {
      var res = await api.orderListProductServer(
        V1ListProductServerArgs(
          type: GOrderType.VIP,
        ),
      );
      if (res == null) return;
      List<GProductServerModel> l = [];
      for (var v in res.list) {
        if (v.type == GOrderType.VIP) {
          l.add(v);
          // logger.d(v);
          // _onlyCard = v;
        }
      }
      vipList = l;
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // // 支付弹窗
  // _payModal() {
  //   var vipOption = vipList[vipIndex];
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setModalState) {
  //         return Center(
  //           child: Container(
  //             width: 280,
  //             padding: const EdgeInsets.only(bottom: 15),
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(5),
  //               color: myColors.white,
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.only(left: 15),
  //                       child: Text.rich(
  //                         TextSpan(
  //                           children: [
  //                             TextSpan(
  //                               text: '确定支付：'.tr(),
  //                             ),
  //                             // TextSpan(
  //                             //   text: '￥${vipOption.price}',
  //                             //   style: const TextStyle(
  //                             //     fontSize: 18,
  //                             //     color: myColors.primary,
  //                             //   ),
  //                             // ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       icon: const Icon(Icons.close),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(height: 1, color: myColors.lineGrey),
  //                 for (var v in payList)
  //                   _payItem(
  //                     data: v,
  //                     active: v == payList[payIndex],
  //                     onTap: () {
  //                       setModalState(() {
  //                         payIndex = payList.indexOf(v);
  //                       });
  //                     },
  //                   ),
  //                 Padding(
  //                   padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
  //                   child: CircleButton(
  //                     title: '确定支付'.tr(),
  //                     height: 45,
  //                     fontSize: 15,
  //                     radius: 5,
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  // // 支付列表组件
  // Widget _payItem({
  //   required VipPayType data,
  //   bool active = false,
  //   Function()? onTap,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 15,
  //       vertical: 10,
  //     ),
  //     child: GestureDetector(
  //       behavior: HitTestBehavior.opaque,
  //       onTap: onTap,
  //       child: Row(
  //         children: [
  //           ClipRRect(
  //             borderRadius: BorderRadius.circular(7),
  //             child: Image.asset(assetPath(data.image), width: 35),
  //           ),
  //           const SizedBox(width: 5),
  //           Expanded(
  //             flex: 1,
  //             child: Text(data.title),
  //           ),
  //           AppCheckbox(value: active),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //兑换
  Future<bool> _exchangeVip() async {
    loading();
    waitStatus = true;
    setState(() {});
    var api = OrderApi(apiClient());
    try {
      var args = V1OrderSubmitArgs(
        number: '1',
        payType: OrderSubmitArgsPayType.INTEGRAL,
        type: GOrderType.VIP,
        shopId: vipList[vipIndex1].id,
      );
      logger.d(args);
      await api.orderSubmit(args);
      _init();
      tipSuccess('兑换成功'.tr());
      waitStatus = false;
      setState(() {});
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  // //购买时长弹窗
  // _buyTimeChooseModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setModalState) {
  //           // bool canBuy = integral >= toDouble(vipList[vipIndex].integral);
  //           bool canBuy = true;
  //           return SafeArea(
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 //标题
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.only(left: 15),
  //                       child: Text.rich(
  //                         TextSpan(
  //                           children: [
  //                             TextSpan(
  //                               text: '购买会员'.tr(),
  //                               style: const TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                             TextSpan(
  //                               text: '可用积分'.tr(args: [integral.toString()]),
  //                               style: const TextStyle(
  //                                 color: myColors.primary,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     IconButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       icon: const Icon(Icons.close),
  //                     ),
  //                   ],
  //                 ),
  //                 //时长列表
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 15),
  //                   child: RowList(
  //                     rowNumber: 2,
  //                     spacing: 15,
  //                     lineSpacing: 15,
  //                     children: vipList.map((e) {
  //                       var i = vipList.indexOf(e);
  //                       return _buyItem(
  //                         data: e,
  //                         active: i == vipIndex,
  //                         onTap: () {
  //                           setModalState(() {
  //                             vipIndex = i;
  //                           });
  //                         },
  //                       );
  //                     }).toList(),
  //                   ),
  //                 ),
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 15),
  //                   child: CircleButton(
  //                     theme: canBuy
  //                         ? AppButtonTheme.greenBlack
  //                         : AppButtonTheme.grey,
  //                     title: canBuy ? '确定购买'.tr() : '可用积分不足',
  //                     height: 50,
  //                     fontSize: 14,
  //                     onTap: () async {
  //                       if (canBuy) {
  //                         var success = await _exchangeVip();
  //                         if (success && mounted) Navigator.pop(context);
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  // //购买列表组件
  // Widget _buyItem({
  //   required GProductServerModel data,
  //   bool active = false,
  //   Function()? onTap,
  // }) {
  //   return GestureDetector(
  //     behavior: HitTestBehavior.opaque,
  //     onTap: onTap,
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(vertical: 10),
  //       decoration: BoxDecoration(
  //         color: active ? myColors.blueOpacity : null,
  //         borderRadius: BorderRadius.circular(5),
  //         border: Border.all(
  //           color: active ? myColors.primary : myColors.lineGrey,
  //           width: 2,
  //         ),
  //       ),
  //       child: Column(
  //         children: [
  //           Text(
  //             (data.name ?? '').toUpperCase(),
  //             style: const TextStyle(
  //               fontSize: 12,
  //             ),
  //           ),
  //           const SizedBox(height: 5),
  //           Text(
  //             data.integral ?? '0',
  //             style: const TextStyle(
  //               fontSize: 20,
  //               color: myColors.primary,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  //介绍组件
  Widget _vipItem({
    required String title,
    required String image,
    double? imageWidth,
    double? imageHeight,
  }) {
    var myColors = ThemeNotifier();
    Color textColor = myColors.iconThemeColor;
    return Container(
      // height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      // decoration: BoxDecoration(
      //   // color: myColors.vipBg,
      //   borderRadius: BorderRadius.circular(4),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            assetPath(image),
            height: imageHeight ?? 50,
            width: imageWidth,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  //购买选择组件
  Widget _vipSelect(int i, GProductServerModel e) {
    var myColors = ThemeNotifier();
    logger.i(e);
    return GestureDetector(
      onTap: () {
        vipIndex1 = i;
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.fromLTRB(
          35,
          19,
          35,
          18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 2,
            color: i == vipIndex1 ? myColors.vipBuySelectedBg : myColors.grey0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              e.name ?? '',
              style: TextStyle(
                color: i == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.accountTagTitle,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Text(
              e.integral ?? '',
              style: TextStyle(
                color: i == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.iconThemeColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              '派币'.tr(),
              style: TextStyle(
                color: i == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.subIconThemeColor,
                fontSize: 15,
                // fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color textColor = myColors.iconThemeColor;

    String userName = (Global.user?.nickname ?? '').isNotEmpty
        ? Global.user!.nickname!
        : '未设置'.tr();
    String expireTime = time2date(
      Global.user?.userExtend?.vipExpireTime,
      format: 'yyyy-MM-dd',
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '会员中心'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, VipHistory.path);
            },
            child: Image.asset(
              assetPath('images/vip/history.png'),
              width: 23,
              height: 23,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          //个人信息
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                LevelInfo.path,
              );
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                // boxShadow: myColors.isDark
                //     ? null
                //     : [
                //         BoxShadow(
                //           color: myColors.bottomShadow,
                //           blurRadius: 20,
                //           offset: const Offset(0, 0),
                //         ),
                //       ],
                image: DecorationImage(
                  image:
                      ExactAssetImage(assetPath('images/vip/sp_huiyuanbg.png')),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 55 + avatarFrameWidthSize + 10,
                    width: 55 + avatarFrameWidthSize + 16,
                    child: AppAvatar(
                      list: [Global.user?.avatar ?? ''],
                      userName: userName,
                      userId: Global.user?.id ?? '',
                      vip: Global.loginUser!.userVip,
                      vipLevel: Global.loginUser!.userVipLevel,
                      size: 55,
                      avatarFrameHeightSize: avatarFrameHeightSize,
                      avatarFrameWidthSize: avatarFrameWidthSize,
                      avatarTopPadding: 10,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //名字、等级
                            Flexible(
                              flex: 1,
                              child: UserNameTags(
                                userName: userName,
                                color: myColors.vipBuyTitle,
                                vip: Global.loginUser!.userVip,
                                vipLevel: Global.loginUser!.userVipLevel,
                                vipBadge: Global.user?.userExtend?.vipBadge ??
                                    GBadge.NIL,
                                // onlyName: Global.userOnlyName,
                                // goodNumber: Global.userGoodNumber &&
                                //     Global.user?.userExtend?.showName ==
                                //         GShowNameType.NUMBER,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                select: false,
                                needMarqueeText: true,
                              ),
                            ),
                            // Flexible(
                            //   child: Text(
                            //     '(派币)'.tr(args: [integral.toString()]),
                            //     overflow: TextOverflow.ellipsis,
                            //     style: TextStyle(
                            //       color: myColors.vipBuySubtitle,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          !Global.loginUser!.userVip || expireTime.isEmpty
                              ? '开通vip会员，尊享会员权益'.tr()
                              : '到期时间：'.tr(args: [expireTime]),
                          style: TextStyle(
                            fontSize: 15,
                            color: myColors.vipBuySubtitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: myColors.vipBuySubtitle,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              color: bgColor,
              child: ListView(
                children: [
                  shadowBox(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 3,
                                height: 16,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: myColors.vipBuySelectedBg,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '会员VIP特权'.tr(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // InkWell(
                              //   onTap: () {
                              //     Navigator.pushNamed(context, VipSetting.path);
                              //   },
                              //   child: const Row(
                              //     children: [
                              //       Text(
                              //         '会员功能',
                              //         style: TextStyle(
                              //           fontSize: 12,
                              //           fontWeight: FontWeight.bold,
                              //           color: myColors.primary,
                              //         ),
                              //       ),
                              //       Icon(
                              //         Icons.arrow_forward_ios,
                              //         color: myColors.primary,
                              //         size: 12,
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                          margin: const EdgeInsets.only(top: 10),
                          child: RowList(
                            rowNumber: 3,
                            spacing: 10,
                            lineSpacing: 10,
                            children: [
                              _vipItem(
                                title: '个性昵称',
                                image: 'images/vip/sp_gexingnicheng.png',
                              ),
                              _vipItem(
                                title: '昵称高亮',
                                image: 'images/vip/sp_nichenggaoliang.png',
                              ),
                              _vipItem(
                                title: '会员铭牌',
                                image: 'images/vip/sp_huiyuanmingpai.png',
                              ),
                              _vipItem(
                                title: '超级大群',
                                image: 'images/vip/sp_chaojidaqun.png',
                              ),
                              _vipItem(
                                title: '等级加速',
                                image: 'images/vip/sp_dengjijiasu.png',
                              ),
                              _vipItem(
                                title: '好友上限',
                                image: 'images/vip/sp_haoyoushangxian.png',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vipList.isNotEmpty)
                    AnimatedFadeOut(
                      animatedTime: 300,
                      child: shadowBox(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 10,
                                left: 10,
                                bottom: 20,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 16,
                                    margin: const EdgeInsets.only(
                                      right: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color: myColors.vipBuySelectedBg,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '兑换会员'.tr(),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var i = 0; i < vipList.length; i++)
                                    _vipSelect(i, vipList[i]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // AppButtonBottomBox(
          //   child: Row(
          //     children: [
          //       // CircleButton(
          //       //   title: '卡密兑换'.tr(),
          //       //   height: 50,
          //       //   width: 100,
          //       //   fontSize: 14,
          //       //   radius: 50,
          //       //   theme: AppButtonTheme.grey,
          //       //   onTap: _goBuy,
          //       // ),
          //       // const SizedBox(width: 10),
          //       Expanded(
          //         flex: 1,
          //         child: CircleButton(
          //           title: '确定兑换'.tr(),
          //           height: 50,
          //           fontSize: 14,
          //           radius: 50,
          //           theme: vipList.isEmpty
          //               ? AppButtonTheme.grey
          //               : AppButtonTheme.greenBlack,
          //           onTap: vipList.isEmpty
          //               ? null
          //               : () {
          //                   confirm(context, title: '确定购买'.tr(),
          //                       onEnter: () async {
          //                     _exchangeVip();
          //                   });
          //                 },
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          if (vipList.isNotEmpty)
            AnimatedFadeOut(
              animatedTime: 300,
              child: BottomButton(
                waiting: waitStatus,
                title: '确定兑换'.tr(),
                onTap: vipList.isEmpty
                    ? null
                    : () {
                        confirm(
                          context,
                          title: '确定购买'.tr(),
                          onEnter: () async {
                            _exchangeVip();
                          },
                        );
                      },
                theme:
                    vipList.isEmpty ? AppButtonTheme.grey : AppButtonTheme.blue,
              ),
            )
        ],
      ),
    );
  }

  //阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

//vip时长类型
class VipOption {
  String title;
  double price;

  VipOption({
    required this.title,
    required this.price,
  });
}

//支付类型
class VipPayType {
  String title;
  String image;

  VipPayType({
    required this.title,
    required this.image,
  });
}
