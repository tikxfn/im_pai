import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/mine/good_number_buy.dart';
import 'package:unionchat/pages/mine/good_number_cash_more.dart';
import 'package:unionchat/widgets/animation_fade_out.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class GoodNumberCashPage extends StatefulWidget {
  const GoodNumberCashPage({super.key});

  static const String path = 'GoodNumberCashPage/page';

  @override
  State<GoodNumberCashPage> createState() => _GoodNumberCashPageState();
}

class _GoodNumberCashPageState extends State<GoodNumberCashPage> {
  List<GUserNumberModel> list = [];

  List<GUserNumberModel> leopardList = [];
  List<GUserNumberModel> honorableList = [];
  List<GUserNumberModel> shortList = [];
  List<GUserNumberModel> straightList = [];
  List<GUserNumberModel> excellentList = [];
  List<GUserNumberModel> otherList = [];
  int limit = 102;
  var _currentTitle = '';
  GUserNumberModel? data;
  double integral = 0;
  double _selectPay = 0;
  String userNumber = ''; //用户靓号
  bool loadSuccess = false; //加载完成

  List<GUserNumberType> typeList = [
    GUserNumberType.LEOPARD,
    GUserNumberType.HONORABLE,
    GUserNumberType.SHORT,
    GUserNumberType.STRAIGHT,
    GUserNumberType.EXCELLENT,
    GUserNumberType.OTHER,
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    List<Future> futures = [
      Global.syncLoginUser(),
    ];
    await Future.wait(futures);
    // NumberConditionNotifier().clean();
    userNumber = (Global.user?.userNumber ?? '').isNotEmpty
        ? Global.user!.userNumber!
        : '';
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    loadSuccess = true;
    setState(() {});
  }

  //获取靓号的接口
  Future<int> getList({bool init = false}) async {
    try {
      // var notifier = NumberConditionNotifier();
      var args = V1ListUserNumberArgs(
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : list.length.toString(),
        ),
      );

      // if (notifier.numberLength > 0) {
      //   args.userNumberLen = notifier.numberLength.toString();
      // }
      // if (notifier.endNumber > 0) {
      //   args.rightNumber = notifier.endNumber.toString();
      // }
      // if (notifier.notContain > 0) {
      //   args.notContain = notifier.notContain.toString();
      // }
      // if (notifier.amount.isNotEmpty) {
      //   args.amount = notifier.amount.map((e) => e.toString()).toList();
      // }
      // List<GUserNumberType> type = [notifier.rule];

      // if (notifier.leftRule.isNotEmpty) {
      //   type.add(notifier.string2left());
      // }
      // if (notifier.middleRule.isNotEmpty) {
      //   type.add(notifier.string2center());
      // }
      // if (notifier.rightRule.isNotEmpty) {
      //   type.add(notifier.string2right());
      // }
      // if (type.isNotEmpty) args.type = type;
      var res = await UserNumberApi(apiClient()).userNumberListUserNumber(args);
      if (!mounted) return 0;
      List<GUserNumberModel> newleopardList = [];
      List<GUserNumberModel> newhonorableList = [];
      List<GUserNumberModel> newshortList = [];
      List<GUserNumberModel> newstraightList = [];
      List<GUserNumberModel> newexcellentList = [];
      List<GUserNumberModel> newotherList = [];
      for (var v in res?.list ?? []) {
        if (v.type == typeList[0]) {
          newleopardList.add(v);
        } else if (v.type == typeList[1]) {
          newhonorableList.add(v);
        } else if (v.type == typeList[2]) {
          newshortList.add(v);
        } else if (v.type == typeList[3]) {
          newstraightList.add(v);
        } else if (v.type == typeList[4]) {
          newexcellentList.add(v);
        } else {
          newotherList.add(v);
        }
      }
      setState(() {
        if (init) {
          leopardList = newleopardList;
          honorableList = newhonorableList;
          shortList = newshortList;
          straightList = newstraightList;
          excellentList = newexcellentList;
          otherList = newotherList;
          // list = res.list.toList();
        } else {
          leopardList.addAll(newleopardList);
          honorableList.addAll(newhonorableList);
          shortList.addAll(newshortList);
          straightList.addAll(newstraightList);
          excellentList.addAll(newexcellentList);
          otherList.addAll(newotherList);
          // list.addAll(res.list.toList());
        }
      });
      if (res == null) return 0;
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    }
  }

  //兑换靓号的接口
  // _requestDataToExchange() async {
  // try {
  //   await UserNumberApi(apiClient()).userNumberSetUserNumber(
  //       V1SetUserNumberArgs(userNumberId: _currentTitle));
  //   tipSuccess('兑换成功'.tr());
  //   if (mounted) {
  //     Navigator.pop(context, true);
  //   }
  // } on ApiException catch (e) {
  //   onError(e);
  // } finally {}
  // }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('兑换靓号'.tr()),
        // actions: [
        //   if (loadSuccess)
        //     GestureDetector(
        //       child: Padding(
        //         padding: const EdgeInsets.all(15.0),
        //         child: Image.asset(
        //           assetPath('images/help/sp_saixuan.png'),
        //           color: textColor,
        //           height: 20,
        //           width: 20.0,
        //         ),
        //       ),
        //       onTap: () {
        //         Navigator.pushNamed(context, ChangeCondition.path)
        //             .then((value) {
        //           if (value == true) {
        //             getList(init: true);
        //           }
        //         });
        //       },
        //     )
        // ],
      ),
      body: loadSuccess
          ? buyInterface(textColor)
          : Container(
              alignment: Alignment.center,
              child: Text(''.tr()),
            ),
    );
  }

  //购买界面
  Widget buyInterface(Color textColor) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: PagerBox(
            // padding: const EdgeInsets.all(15),
            limit: limit,
            onInit: () async {
              return await getList(init: true);
            },
            onPullDown: () async {
              return await getList(init: true);
            },
            onPullUp: () async {
              return await getList();
            },
            children: [
              if (leopardList.isNotEmpty)
                tabListWidget(GUserNumberType.LEOPARD, leopardList),
              if (honorableList.isNotEmpty)
                tabListWidget(GUserNumberType.HONORABLE, honorableList),
              if (shortList.isNotEmpty)
                tabListWidget(GUserNumberType.SHORT, shortList),
              if (straightList.isNotEmpty)
                tabListWidget(GUserNumberType.STRAIGHT, straightList),
              if (excellentList.isNotEmpty)
                tabListWidget(GUserNumberType.EXCELLENT, excellentList),
              if (otherList.isNotEmpty)
                tabListWidget(GUserNumberType.OTHER, otherList),
            ],
          ),
        ),
        AnimatedFadeOut(
          animatedTime: 300,
          child: BottomButton(
            title: '兑换靓号'.tr(),
            onTap: () {
              if (integral < _selectPay) {
                tip('可用余额不足'.tr());
                return;
              }
              if (_currentTitle == '') {
                tip('请选择要兑换的靓号'.tr());
              } else {
                // _requestDataToExchange();
                if (userNumber != '') {
                  confirm(
                    context,
                    content: '当前已有靓号:$userNumber,购买靓号将替换为新的靓号'.tr(),
                    onEnter: () {
                      Navigator.pushNamed(context, GoodNumberBuy.path,
                          arguments: {
                            'currentTitle': _currentTitle,
                            'data': data
                          }).then((value) {
                        getList(init: true);
                      });
                    },
                  );
                } else {
                  Navigator.pushNamed(context, GoodNumberBuy.path, arguments: {
                    'currentTitle': _currentTitle,
                    'data': data
                  }).then((value) {
                    getList(init: true);
                  });
                }
              }
            },
            disabled: _currentTitle.isEmpty,
          ),
        ),
      ],
    );
  }

  //列表样式
  Widget tabListWidget(GUserNumberType type, List<GUserNumberModel> listData) {
    var myColors = ThemeNotifier();
    return AnimatedFadeOut(
      animatedTime: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
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
                      Flexible(
                        flex: 1,
                        child: Text(
                          goodNumberShowstring(type),
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, GoodNumberCashPageMore.path,
                        arguments: {'type': type}).then((value) {
                      getList(init: true);
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        '更多',
                        style: TextStyle(color: myColors.blueTitle),
                      ),
                      Icon(
                        Icons.chevron_right_outlined,
                        size: 25,
                        color: myColors.blueTitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          listData.length > 3
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: RowList(
                      rowNumber: 3,
                      spacing: 10,
                      lineSpacing: 10,
                      children: [
                        for (var i = 0; i < 3; i++)
                          GestureDetector(
                            onTap: () {
                              if (_currentTitle == listData[i].id) {
                                _currentTitle = '';
                                _selectPay = 0;
                                logger.i(2);
                              } else {
                                _currentTitle = listData[i].id ?? '';
                                data = listData[i];
                                logger.i(3);
                                _selectPay = toDouble(listData[i].integral);
                              }
                              setState(() {});
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
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
                              child: boxWidget(listData[i]),
                            ),
                          ),
                      ]),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: RowList(
                    rowNumber: 3,
                    spacing: 10,
                    lineSpacing: 10,
                    children: listData.map<Widget>((model) {
                      return GestureDetector(
                        onTap: () {
                          // if (model.userId != '0') {
                          //   return;
                          // }
                          if (_currentTitle == model.id) {
                            _currentTitle = '';

                            _selectPay = 0;
                          } else {
                            _currentTitle = model.id ?? '';
                            data = model;
                            _selectPay = toDouble(model.integral);
                          }
                          setState(() {});
                        },
                        child: boxWidget(model),
                      );
                    }).toList(),
                  ),
                ),
          Container(
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 15),
            color: myColors.circleBorder,
          )
        ],
      ),
    );
  }

  //选项样式
  Widget boxWidget(GUserNumberModel model) {
    var myColors = ThemeNotifier();
    return Container(
      // height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
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
          decoration: BoxDecoration(
            color: myColors.tagColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              style: model.id == _currentTitle
                  ? BorderStyle.solid
                  : BorderStyle.none,
              width: 2,
              color: myColors.vipBuySelectedBg,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        model.uid ?? '',
                        style: TextStyle(
                          color: model.id == _currentTitle
                              ? myColors.vipBuySelectedBg
                              : myColors.accountTagTitle,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 3),
                      decoration: BoxDecoration(
                        color: myColors.liangLogoBg,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '靓'.tr(),
                        style: TextStyle(
                          height: 1,
                          color: myColors.liangLogoText,
                          fontSize: 12,
                          // fontWeight: FontWeight.w500,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: myColors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '价格:'.tr(),
                      style: TextStyle(
                        color: model.id == _currentTitle
                            ? myColors.vipBuySelectedBg
                            : myColors.subIconThemeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '${model.integral ?? ''}币',
                        style: TextStyle(
                          color: model.id == _currentTitle
                              ? myColors.vipBuySelectedBg
                              : myColors.subIconThemeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
