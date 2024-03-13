import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../global.dart';
import '../../../common/interceptor.dart';
import '../../../notifier/theme_notifier.dart';

class MallGrowthValue extends StatefulWidget {
  const MallGrowthValue({super.key});

  static const String path = 'mall/growth_value';

  @override
  State<MallGrowthValue> createState() => _MallGrowthValueState();
}

class _MallGrowthValueState extends State<MallGrowthValue> {
  final TextEditingController code = TextEditingController();
  double integral = 0;
  FocusNode focusNode = FocusNode();
  int selectIndex = 0;
  int limit = 20;
  bool waitStatus = false;
  List<GProductServerModel> growthList = [];

  _init() async {
    List<Future> futures = [
      // Global.loginUser(),
      _getVipPrice(),
    ];

    await Future.wait(futures);
    if (!mounted) return;
    integral = toDouble(Global.user?.integral ?? '');
    setState(() {});
  }

  //获取成长值商品
  _getVipPrice() async {
    var api = OrderApi(apiClient());
    try {
      var res = await api.orderListProductServer(
        V1ListProductServerArgs(
          type: GOrderType.GROWTH,
        ),
      );
      if (res == null) return;
      List<GProductServerModel> l = [];
      logger.i(res.list);
      for (var v in res.list) {
        if (v.type == GOrderType.GROWTH) {
          l.add(v);
        }
      }
      growthList = l;
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //立即购买
  _buyNow() async {
    bool inputed;
    inputed = selectIndex == 99999;
    if (inputed) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    if ((inputed && code.text.isEmpty) || (inputed && !isDouble(code.text))) {
      tip('请输入正确的数字'.tr());
      return;
    }
    confirm(
      context,
      title: '确定购买成长值'
          .tr(args: [inputed ? code.text : growthList[selectIndex].attr ?? '']),
      onEnter: () async {
        waitStatus = true;
        setState(() {});
        loading();
        var api = OrderApi(apiClient());
        try {
          var args = V1OrderSubmitArgs(
            payType: OrderSubmitArgsPayType.INTEGRAL,
            type: GOrderType.GROWTH,
            value: inputed ? code.text : selectIndex.toString(),
            shopId: inputed ? '0' : growthList[selectIndex].id,
          );
          logger.d(args);
          await api.orderSubmit(args);
          if (mounted) {
            _init();
            waitStatus = false;
            setState(() {});
            tipSuccess('兑换成功'.tr());
          }
        } on ApiException catch (e) {
          onError(e);
          return;
        } finally {
          loadClose();
          waitStatus = false;
          setState(() {});
        }
      },
    );
  }

  //购买选择组件
  Widget _vipSelect(int index, GProductServerModel data) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        selectIndex = index;
        FocusScope.of(context).requestFocus(FocusNode());
        if (mounted) setState(() {});
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
        child: Container(
            decoration: BoxDecoration(
              color: myColors.tagColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                style:
                    index == selectIndex ? BorderStyle.solid : BorderStyle.none,
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
                  child: Text(
                    data.attr ?? '',
                    style: TextStyle(
                      color: index == selectIndex
                          ? myColors.vipBuySelectedBg
                          : myColors.accountTagTitle,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                          color: index == selectIndex
                              ? myColors.vipBuySelectedBg
                              : myColors.subIconThemeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${data.attr ?? ''}派币',
                          style: TextStyle(
                            color: index == selectIndex
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
      ),
      // Container(
      //   padding: const EdgeInsets.fromLTRB(10, 15, 10, 30),
      //   decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(15),
      //     border: Border.all(
      //       width: 2,
      //       color: index == selectIndex
      //           ? myColors.vipBuySelectedBg
      //           : myColors.grey0,
      //     ),
      //   ),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       Text(
      //         '成长值'.tr(),
      //         style: TextStyle(
      //           color: index == selectIndex
      //               ? myColors.vipBuySelectedBg
      //               : myColors.accountTagTitle,
      //           fontSize: 15,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 20,
      //       ),
      //       Text(
      //         data.attr ?? '',
      //         style: TextStyle(
      //           color: index == selectIndex
      //               ? myColors.vipBuySelectedBg
      //               : myColors.accountTagTitle,
      //           fontSize: 16,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }

  @override
  void initState() {
    super.initState();
    _init();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        selectIndex = 99999;
        setState(() {});
      } else {}
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color inputColor = myColors.chatInputColor;
    Color textColor = myColors.iconThemeColor;
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      // backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'VIP成长值'.tr(),
        ),
      ),
      body: KeyboardBlur(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                color: bgColor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '我的余额：'.tr(args: [integral.toString()]),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
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
                              '自定义数量(1派币=1成长值)'.tr(),
                              style: TextStyle(
                                color: myColors.iconThemeColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: AppInputBox(
                          controller: code,
                          focusNode: focusNode,
                          color: inputColor,
                          fontColor: textColor,
                          hintColor: myColors.textGrey,
                          keyboardType: TextInputType.number,
                          hintText: '请输入数量'.tr(),
                          fontSize: 15,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      // selectInput(99999, '自定义数量,购买1:1'),
                      Row(
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
                              '固定选择'.tr(),
                              style: TextStyle(
                                color: myColors.iconThemeColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Container(
                        padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
                        child: SingleChildScrollView(
                          child: RowList(
                            rowNumber: 3,
                            spacing: 10,
                            lineSpacing: 10,
                            children: [
                              for (var i = 0; i < growthList.length; i++)
                                _vipSelect(i, growthList[i]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            BottomButton(
              waiting: waitStatus,
              title: '立即购买'.tr(),
              onTap: growthList.isEmpty && code.text.isEmpty
                  ? null
                  : () {
                      if (toDouble(code.text) < 100) {
                        tip('最低购买100成长值');
                        return;
                      }
                      if (selectIndex != 99999 &&
                          growthList.isNotEmpty &&
                          integral < toInt(growthList[selectIndex].integral)) {
                        tip('可用余额不足'.tr());
                        return;
                      }
                      if (selectIndex == 99999 && integral < toInt(code.text)) {
                        tip('可用余额不足'.tr());
                        return;
                      }
                      _buyNow();
                    },
              disabled: growthList.isEmpty && code.text.isEmpty,
            ),
            // SafeArea(
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            //     child: Row(
            //       children: [
            //         Expanded(
            //           flex: 1,
            //           child: CircleButton(
            //             onTap: growthList.isEmpty && code.text.isEmpty
            //                 ? null
            //                 : () {
            //                     if (toDouble(code.text) < 100) {
            //                       tip('最低购买100成长值');
            //                       return;
            //                     }
            //                     if (selectIndex != 99999 &&
            //                         growthList.isNotEmpty &&
            //                         integral <
            //                             toInt(
            //                                 growthList[selectIndex].integral)) {
            //                       tip('可用余额不足'.tr());
            //                       return;
            //                     }
            //                     if (selectIndex == 99999 &&
            //                         integral < toInt(code.text)) {
            //                       tip('可用余额不足'.tr());
            //                       return;
            //                     }
            //                     _buyNow();
            //                   },
            //             title: '立即购买'.tr(),
            //             radius: 10,
            //             fontSize: 16,
            //             height: 47,
            //             theme: growthList.isEmpty && code.text.isEmpty
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
