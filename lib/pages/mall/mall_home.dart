import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/mall/my_card/mall_my_card.dart';
import 'package:unionchat/pages/mall/vip/mall_growth_value.dart';
import 'package:unionchat/pages/mine/good_number_cash.dart';
import 'package:unionchat/pages/mine/good_number_renew.dart';
import 'package:unionchat/pages/vip/vip_buy.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class MallHome extends StatefulWidget {
  const MallHome({super.key});

  static const String path = 'mall/home';

  @override
  State<MallHome> createState() => _MallHomeState();
}

class _MallHomeState extends State<MallHome> {
  double integral = 0;
  static GProductServerModel? _onlyCard;
  static int _onlyCardNumber = 0; //唯名卡数量
  static int _groupExpansion = 0; //群扩容卡数量
  // static int _friendExpansion = 0; //好友扩容卡数量
  bool waitStatus = false;

  _init() async {
    List<Future> futures = [
      Global.syncLoginUser(),
      _getProduct(),
      _getList(),
    ];
    await Future.wait(futures);
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  //获取唯名卡所需积分
  _getProduct() async {
    var api = OrderApi(apiClient());
    try {
      var res = await api.orderListProductServer(
        V1ListProductServerArgs(
          type: GOrderType.CHANGE_NICKNAME_CARD,
        ),
      );
      if (res == null) return;
      for (var v in res.list) {
        if (v.type == GOrderType.CHANGE_NICKNAME_CARD) {
          _onlyCard = v;
        }
      }
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //兑换唯名卡
  _exchange() async {
    if (_onlyCard == null) return;
    loading();
    waitStatus = true;
    setState(() {});
    var api = OrderApi(apiClient());
    try {
      var args = V1OrderSubmitArgs(
        number: '1',
        payType: OrderSubmitArgsPayType.INTEGRAL,
        type: GOrderType.CHANGE_NICKNAME_CARD,
        shopId: _onlyCard!.id,
      );
      await api.orderSubmit(args);
      tipSuccess('兑换成功'.tr());
      _init();
      waitStatus = false;
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  //购买弹窗
  _openBuyModal({
    required String title,
    required String image,
    required double needIntegral,
    Function()? onEnter,
  }) {
    var myColors = ThemeNotifier();
    bool canBuy = needIntegral <= integral;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: ThemeNotifier().themeBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    '兑换卡券权益'.tr(),
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 19),
                  child: Text(
                    '(${'可用派币'.tr(args: [integral.toString()])})',
                    style: TextStyle(
                        fontSize: 12, color: myColors.subIconThemeColor),
                  ),
                ),
                Container(
                  height: 1,
                  color: myColors.circleBorder,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 24,
                    bottom: 14,
                  ),
                  child: Image.asset(
                    assetPath('images/mall/duihuanweimingka.png'),
                    height: 87,
                    width: 85,
                    fit: BoxFit.contain,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        // '兑换唯名卡:'.tr(),
                        '$title : ',
                        style: TextStyle(
                          height: 1,
                          fontSize: 17,
                          color: myColors.iconThemeColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      needIntegral.toString(),
                      style: TextStyle(
                        height: 1,
                        fontSize: 17,
                        color: myColors.blueTitle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: CircleButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          title: '取消'.tr(),
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
                          onTap: canBuy
                              ? () async {
                                  Navigator.pop(context);
                                  _exchange();
                                }
                              : null,
                          title: canBuy ? '确定兑换'.tr() : '可用飞欧币不足'.tr(),
                          theme: canBuy
                              ? AppButtonTheme.primary
                              : AppButtonTheme.grey,
                          waiting: waitStatus,
                          radius: 10,
                          fontSize: 16,
                          height: 47,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //获取卡券
  _getList() async {
    _groupExpansion = 0;
    var api = CardApi(apiClient());
    try {
      var res = await api.cardQuantity({});
      if (res == null || !mounted) return;
      for (var v in res.list) {
        logger.i(v);
        if (v.type == GOrderType.CHANGE_NICKNAME_CARD) {
          _onlyCardNumber = toInt(v.no);
        }
        if (v.type == GOrderType.rOOM500) {
          _groupExpansion = _groupExpansion + toInt(v.no);
        }
        if (v.type == GOrderType.rOOM1000) {
          _groupExpansion = _groupExpansion + toInt(v.no);
        }
        if (v.type == GOrderType.rOOM2000) {
          _groupExpansion = _groupExpansion + toInt(v.no);
        }
        if (v.type == GOrderType.rOOM5000) {
          _groupExpansion = _groupExpansion + toInt(v.no);
        }
      }
      setState(() {});
    } on ApiException catch (e) {
      tip('卡券数量获取失败'.tr());
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // //使用唯名卡
  // _useOnlyCard(String name, String id) {
  //   if (id.isEmpty) return;
  //   Navigator.push(
  //     context,
  //     CupertinoModalPopupRoute(builder: (context) {
  //       return SetNameInput(
  //         title: name,
  //         subTitle: '修改后的昵称不能重复'.tr(),
  //         value: Global.user?.nickname ?? '',
  //         onEnter: (val) async {
  //           return await _saveNickName(userName: val, cardId: id);
  //         },
  //       );
  //     }),
  //   );
  // }

  // //保存昵称
  // Future<bool> _saveNickName({
  //   String? userName,
  //   String? cardId,
  // }) async {
  //   loading();
  //   if (userName == null) return false;
  //   V1SetBasicInfoArgs args = V1SetBasicInfoArgs(
  //     nickname: V1SetBasicInfoArgsValue(value: userName),
  //     cardId: SetBasicInfoArgsCardId(cardId: cardId),
  //   );
  //   var api = UserApi(apiClient());
  //   try {
  //     await api.userSetBasicInfo(args);
  //     Global.loginUser();
  //     _getList();
  //     return true;
  //   } on ApiException catch (e) {
  //     onError(e);
  //     return false;
  //   } catch (e) {
  //     logger.e(e);
  //     return false;
  //   } finally {
  //     loadClose();
  //   }
  // }

  //跳转我的卡券
  gotoMyCard({
    required GOrderType type,
    required String image,
    required String titleName,
  }) {
    Navigator.pushNamed(context, MallMyCard.path, arguments: {
      'cardType': type,
      'image': image,
      'titleName': titleName,
    }).then((value) async {
      await _getList();
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商城'.tr()),
      ),
      body: ListView(
        children: [
          myCard(),
          box1(),
          box2(),
          box3(),
          // box4(),
        ],
      ),
    );
  }

  //商品列表
  Widget _mallItem({
    required String title,
    required String image,
    double? imageWidth,
    double? imageHeight,
    double marginRight = 0, //右边距
    Function()? onTap,
    bool disabled = true, //灰度
    int number = 0,
  }) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      margin: EdgeInsets.only(right: marginRight),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          children: [
            Badge(
              isLabelVisible: number > 0,
              backgroundColor: myColors.redTitle,
              label: Text(number.toString()),
              child: disabled
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Image.asset(
                        assetPath(image),
                        height: imageHeight ?? 30,
                        width: imageWidth,
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.asset(
                      alignment: Alignment.bottomCenter,
                      assetPath(image),
                      height: imageHeight ?? 30,
                      width: imageWidth,
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: disabled ? myColors.subIconThemeColor : null,
                fontSize: 12,
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }

  //我的卡券
  Widget myCard() {
    var myColors = context.watch<ThemeNotifier>();
    return shadowBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                margin: const EdgeInsets.only(right: 10, left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: myColors.vipBuySelectedBg,
                ),
              ),
              Text(
                '我的卡劵'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          RowList(
            rowNumber: 5,
            lineSpacing: 10,
            children: [
              _mallItem(
                image: 'images/mall/weimingka.png',
                imageWidth: 44,
                imageHeight: 35,
                title: '唯名卡',
                disabled: false,
                number: _onlyCardNumber,
                onTap: () {
                  if (_onlyCardNumber > 0) {
                    gotoMyCard(
                      type: GOrderType.CHANGE_NICKNAME_CARD,
                      image: 'images/mall/weimingka.png',
                      titleName: '唯名卡',
                    );
                    // if (_onlyCardIds.isNotEmpty &&
                    //     _onlyCardIds[0].isNotEmpty) {
                    //   _useOnlyCard('唯名卡', _onlyCardIds[0]);
                    // }
                  } else {
                    _openBuyModal(
                      image: 'images/sp_weimingka.png',
                      title: '唯名卡', // _onlyCard?.name ?? '',
                      needIntegral: toDouble(_onlyCard?.integral),
                      onEnter: () {},
                    );
                  }
                },
              ),
              _mallItem(
                image: 'images/mall/qunlianghaojuan.png',
                imageWidth: 38,
                imageHeight: 35,
                disabled: false,
                title: '群扩容劵',
                number: _groupExpansion,
                onTap: () {
                  gotoMyCard(
                    type: GOrderType.rOOM500,
                    image: 'images/mall/qunlianghaojuan.png',
                    titleName: '群扩容劵',
                  );
                },
              ),
              _mallItem(
                image: 'images/mall/cishujuan.png',
                imageWidth: 38,
                imageHeight: 35,
                title: '好友数量券',
                onTap: () {
                  // gotoMyCard(
                  //   type: GOrderType.NIL,
                  //   image: 'images/mall/cishujuan.png',
                  //   titleName: '好友数量券',
                  // );
                },
              ),
              _mallItem(
                image: 'images/mall/zhekoujuan.png',
                imageWidth: 38,
                imageHeight: 35,
                title: '折扣券',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/huiyuanjuan.png',
                imageWidth: 38,
                imageHeight: 35,
                title: '会员券',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/jingyanjuan.png',
                imageWidth: 38,
                imageHeight: 35,
                title: '经验券',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/lianghaojuan.png',
                imageWidth: 38,
                imageHeight: 35,
                title: '靓号券',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/jiejinka.png',
                imageWidth: 44,
                imageHeight: 35,
                title: '解禁卡',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/fubangka.png',
                imageWidth: 44,
                imageHeight: 35,
                title: '复榜券',
                onTap: () {},
              ),
              _mallItem(
                image: 'images/mall/xiugaika.png',
                imageWidth: 44,
                imageHeight: 35,
                title: '修改券',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  //会员专区
  Widget box1() {
    var myColors = ThemeNotifier();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '会员专区'.tr(),
                  style: TextStyle(
                    color: myColors.iconThemeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _mallItem(
                  image: 'images/mall/kaitonghuiyuan.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '开通会员',
                  marginRight: 20,
                  disabled: false,
                  onTap: () {
                    Navigator.pushNamed(context, VipBuy.path);
                  },
                ),
                _mallItem(
                  image: 'images/mall/dengjika.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '购买经验',
                  marginRight: 20,
                  disabled: false,
                  onTap: () {
                    Navigator.pushNamed(context, MallGrowthValue.path)
                        .then((value) async {
                      await _getList();
                    });
                  },
                ),
                _mallItem(
                  image: 'images/mall/huiyuanhecheng.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '会员合成',
                  marginRight: 20,
                  onTap: () {},
                ),
                _mallItem(
                  image: 'images/mall/yuechongzhi.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '余额充值',
                  marginRight: 20,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 5,
          color: myColors.circleBorder,
        )
      ],
    );
  }

  //靓号专区
  Widget box2() {
    var myColors = ThemeNotifier();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '靓号专区'.tr(),
                  style: TextStyle(
                    color: myColors.iconThemeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _mallItem(
                  image: 'images/mall/goumailianghao.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '购买靓号',
                  marginRight: 20,
                  disabled: false,
                  onTap: () {
                    Navigator.pushNamed(context, GoodNumberCashPage.path);
                  },
                ),
                _mallItem(
                  image: 'images/mall/lianghaofuwu.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '靓号服务',
                  disabled: false,
                  marginRight: 20,
                  onTap: () {
                    Navigator.pushNamed(context, GoodNumberRenew.path);
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 5,
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: myColors.circleBorder,
        )
      ],
    );
  }

  //积分专区
  Widget box3() {
    var myColors = ThemeNotifier();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  '积分专区'.tr(),
                  style: TextStyle(
                    color: myColors.iconThemeColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _mallItem(
                  image: 'images/mall/jifenchoujiang.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '积分抽奖',
                  marginRight: 20,
                  onTap: () {},
                ),
                _mallItem(
                  image: 'images/mall/jifenfanbei.png',
                  imageWidth: 51,
                  imageHeight: 51,
                  title: '积分翻倍赢',
                  marginRight: 20,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 5,
          color: myColors.circleBorder,
        )
      ],
    );
  }
}
