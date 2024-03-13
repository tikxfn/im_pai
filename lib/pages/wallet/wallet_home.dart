import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/pages/wallet/pay_page.dart';
import 'package:unionchat/pages/wallet/wallet_usage_record.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/dialog_widget.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../global.dart';
import '../../notifier/theme_notifier.dart';

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  static const String path = 'wallet/home';

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> with WidgetsBindingObserver {
  TextEditingController ctr = TextEditingController();
  int vipIndex1 = 0;
  int limit = 20;

  // List<GUserIntegralModel> _list = [];
  double integral = 0;
  List<GProductServerModel> vipList = [];

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

  //获取价格
  _getVipPrice() async {
    var api = OrderApi(apiClient());
    try {
      var res = await api.orderListProductServer(
        V1ListProductServerArgs(
          type: GOrderType.INTEGRAL,
        ),
      );
      if (res == null) return;
      List<GProductServerModel> l = [];
      for (var v in res.list) {
        if (v.type == GOrderType.INTEGRAL) {
          l.add(v);
        }
      }
      vipList = l;
    } on ApiException catch (e) {
      onError(e);
    }
  }

  // //兑换
  // Future<bool> _exchangeVip(String str) async {
  //   loading();
  //   var api = VipCardApi(apiClient());
  //   try {
  //     var args = V1UseCardArgs(cardNumber: str);
  //     await api.vipCardUseCard(args);
  //     // _getList(init: true);
  //     tipSuccess('兑换成功'.tr());
  //     return true;
  //   } on ApiException catch (e) {
  //     onError(e);
  //     return false;
  //   } finally {
  //     loadClose();
  //   }
  // }

  // //跳转兑换卡密
  // _goBuy() {
  //   Navigator.push(
  //     context,
  //     CupertinoModalPopupRoute(builder: (context) {
  //       return SetNameInput(
  //         title: '充值派币'.tr(),
  //         subTitle: '请输入购买的卡密'.tr(),
  //         onEnter: (val) async {
  //           return await _exchangeVip(val);
  //         },
  //       );
  //     }),
  //   ).then((value) => _init());
  // }

  //立即购买
  _buyNow(GProductServerModel e) async {
    openSheetMenu(
      context,
      list: ['立即购买'.tr(), '卡密兑换'.tr()],
      onTap: (i) {
        if (i == 0) {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) {
                return PayPage(
                  amount: e.amount ?? '',
                  over: () {
                    Navigator.pop(context);
                    if (mounted) _init();
                  },
                );
              },
            ),
          );
        } else {
          _sendBox();
        }
      },
    );
  }

  //卡密
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
                    child: Text(
                      '兑换卡密'.tr(),
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
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
                      assetPath('images/vip/sp_kamizhifu.png'),
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
                        hintText: '请输入在卡密平台购买的卡密'.tr(),
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            //按钮
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: CircleButton(
                theme: AppButtonTheme.primary,
                title: '确认兑换'.tr(),
                height: 40,
                fontSize: 14,
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  //购买选择组件
  Widget _vipSelect(int index, GProductServerModel e) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        vipIndex1 = index;
        if (mounted) setState(() {});
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.fromLTRB(
          10,
          15,
          10,
          30,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 2,
            color:
                index == vipIndex1 ? myColors.vipBuySelectedBg : myColors.grey0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              e.integral ?? '',
              style: TextStyle(
                color: index == vipIndex1
                    ? myColors.vipBuySelectedBg
                    : myColors.iconThemeColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: index == vipIndex1
                      ? myColors.vipBuySelectedBg
                      : myColors.iconThemeColor,
                ),
                children: [
                  const TextSpan(text: '￥'),
                  TextSpan(
                    text: api2number(e.amount),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
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

    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '我的钱包'.tr(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, WalletUsage.path);
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
      body: ThemeBody(
        topPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 36,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage(assetPath('images/my/yu_e.png')),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '派币'.tr(),
                            style: TextStyle(
                              color: myColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      integral.toString(),
                      style: TextStyle(
                        color: myColors.white,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 16,
                bottom: 10,
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
                      '购买派币'.tr(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                // margin: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      for (var i = 0; i < vipList.length; i++)
                        _vipSelect(i, vipList[i]),
                    ],
                  ),
                ),
              ),
            ),

            BottomButton(
              title: '立即购买'.tr(),
              disabled: vipList.isEmpty,
              onTap: vipList.isEmpty
                  ? null
                  : () {
                      _buyNow(vipList[vipIndex1]);
                    },
            ),

            // SafeArea(
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            //     child: Row(
            //       children: [
            //         // Expanded(
            //         //   flex: 1,
            //         //   child: CircleButton(
            //         //     onTap: _goBuy,
            //         //     title: '卡密兑换'.tr(),
            //         //     height: 40,
            //         //     radius: 20,
            //         //     fontSize: 14,
            //         //     theme: AppButtonTheme.greenWhite,
            //         //   ),
            //         // ),
            //         // const SizedBox(width: 15),
            //         Expanded(
            //           flex: 1,
            //           child: CircleButton(
            //             onTap: vipList.isEmpty
            //                 ? null
            //                 : () {
            //                     _buyNow(vipList[vipIndex1]);
            //                   },
            //             title: '立即购买'.tr(),
            //             height: 40,
            //             radius: 20,
            //             fontSize: 14,
            //             theme: vipList.isEmpty
            //                 ? AppButtonTheme.grey
            //                 : AppButtonTheme.greenBlack,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
