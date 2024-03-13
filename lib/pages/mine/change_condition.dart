import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/number_condition_notifier.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

//抽屉显示模式
enum ChangeConditionDrawer {
  rule,
  number,
  length,
  amount,
}

//当前编辑规则类型
enum ConditionUserType {
  left,
  center,
  right,
}

class ChangeCondition extends StatefulWidget {
  const ChangeCondition({super.key});

  static const String path = 'change/condition';

  @override
  State<ChangeCondition> createState() => _ChangeConditionState();
}

class _ChangeConditionState extends State<ChangeCondition> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<List<int>> amountList = [
    [10, 50],
    [50, 100],
    [100, 200],
    [200, 300],
  ];
  // List<String> userTypeList = [
  //   'AAA',
  //   'AAAA',
  //   'ABC',
  //   'ABCD',
  // ];
  List<int> numberLengthList = [5, 6, 7, 8];
  List<int> endNumberList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  //抽屉显示类型
  ChangeConditionDrawer drawerModel = ChangeConditionDrawer.rule;
  // ConditionUserType conditionUserType = ConditionUserType.left;

  //抽屉组件
  Widget endDrawerWidget() {
    var notifier = context.watch<NumberConditionNotifier>();
    if (drawerModel == ChangeConditionDrawer.rule) {
      return ChangeConditionDrawerRule(
        value: notifier.rule,
        onTap: (value) {
          notifier.rule = notifier.rule == value ? GUserNumberType.NIL : value;
        },
      );
    }
    if (drawerModel == ChangeConditionDrawer.amount) {
      return StringConditionDrawerRule(
        amountList.map((e) => e.join('~')).toList(),
        value: notifier.amount.join('~'),
        onTap: (value) {
          var choiceAmount = value.split('~').map((e) => toInt(e)).toList();
          notifier.amount =
              value == notifier.amount.join('~') ? [] : choiceAmount;
        },
      );
    }
    if (drawerModel == ChangeConditionDrawer.number) {
      return ChangeConditionDrawerNumber(
        endNumberList.map((e) => e.toString()).toList(),
        value: notifier.endNumber.toString(),
        onTap: (value) {
          var val = toInt(value);
          notifier.endNumber = val == notifier.endNumber ? -1 : val;
        },
      );
    }
    if (drawerModel == ChangeConditionDrawer.length) {
      return ChangeConditionDrawerNumber(
        numberLengthList.map((e) => e.toString()).toList(),
        value: notifier.numberLength.toString(),
        onTap: (value) {
          var val = toInt(value);
          notifier.numberLength = val == notifier.numberLength ? -1 : val;
        },
      );
    }
    return const Drawer();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    var notifier = context.watch<NumberConditionNotifier>();
    return Scaffold(
      key: _key,
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('筛选'.tr()),
        actions: [
          GestureDetector(
            child: Container(),
            onTap: () {},
          )
        ],
      ),
      endDrawer: endDrawerWidget(),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(
                  height: 10,
                ),
                MenuUl(
                  marginTop: 0,
                  children: [
                    MenuItemData(
                      title: '规律'.tr(),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            goodNumberType2string(notifier.rule),
                            style: TextStyle(color: myColors.textGrey),
                          ),
                          if (goodNumberImageString(notifier.rule) != '')
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Image.asset(
                                assetPath(goodNumberImageString(notifier.rule)),
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          drawerModel = ChangeConditionDrawer.rule;
                        });
                        _key.currentState!.openEndDrawer();
                      },
                    ),
                    // MenuItemData(
                    //   title: '中间规律'.tr(),
                    //   content: Text(
                    //     notifier.middleRule,
                    //     style: const TextStyle(color: myColors.textGrey),
                    //   ),
                    //   onTap: () {
                    //     setState(() {
                    //       drawerModel = ChangeConditionDrawer.rule;
                    //       conditionUserType = ConditionUserType.center;
                    //     });
                    //     _key.currentState!.openEndDrawer();
                    //   },
                    // ),
                    // MenuItemData(
                    //   title: '尾部规律'.tr(),
                    //   content: Text(
                    //     notifier.rightRule,
                    //     style: const TextStyle(color: myColors.textGrey),
                    //   ),
                    //   onTap: () {
                    //     setState(() {
                    //       drawerModel = ChangeConditionDrawer.rule;
                    //       conditionUserType = ConditionUserType.right;
                    //     });
                    //     _key.currentState!.openEndDrawer();
                    //   },
                    // ),
                    MenuItemData(
                      title: '末尾是指定数字'.tr(),
                      content: Text(
                        notifier.endNumber >= 0
                            ? notifier.endNumber.toString()
                            : '',
                        style: TextStyle(color: myColors.textGrey),
                      ),
                      onTap: () {
                        setState(() {
                          drawerModel = ChangeConditionDrawer.number;
                        });
                        _key.currentState!.openEndDrawer();
                      },
                    ),
                    MenuItemData(
                      title: '指定长度'.tr(),
                      content: Text(
                        notifier.numberLength >= 0
                            ? notifier.numberLength.toString()
                            : '',
                        style: TextStyle(color: myColors.textGrey),
                      ),
                      onTap: () {
                        setState(() {
                          drawerModel = ChangeConditionDrawer.length;
                        });
                        _key.currentState!.openEndDrawer();
                      },
                    ),
                    MenuItemData(
                      title: '售价'.tr(),
                      content: Text(
                        notifier.amount.join('~'),
                        style: TextStyle(color: myColors.textGrey),
                      ),
                      onTap: () {
                        setState(() {
                          drawerModel = ChangeConditionDrawer.amount;
                        });
                        _key.currentState!.openEndDrawer();
                      },
                    ),
                  ],
                ),
                Container(
                  height: 10,
                  color: bgColor,
                ),
                Container(
                  padding: const EdgeInsets.all(15),
                  // color: Colors.red,
                  height: 380,
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    crossAxisSpacing: 10,
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    children: endNumberList.map((e) {
                      return GestureDetector(
                        onTap: () {
                          notifier.notContain =
                              notifier.notContain == e ? -1 : e;
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: notifier.notContain == e
                                ? myColors.blueBack
                                : myColors.yellowBack,
                          ),
                          child: Center(
                              child: Text(
                            '不含'.tr(args: [e.toString()]),
                            style: TextStyle(
                              color: notifier.notContain == e
                                  ? myColors.white
                                  : myColors.textBlack,
                              fontSize: 15,
                            ),
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        notifier.clean();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          // 设置圆角半径为10.0
                          color: const Color(0xFFE3E3E3), // 设置背景颜色
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            '清除'.tr(),
                            style: TextStyle(color: myColors.secondTextColor),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context, true);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.0),
                          // 设置圆角半径为10.0
                          color: myColors.blueBack, // 设置背景颜色
                        ),
                        width: 150,
                        height: 50,
                        child: Center(
                          child: Text(
                            '确认'.tr(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//数字抽屉
class ChangeConditionDrawerNumber extends StatelessWidget {
  final List<String> numbers;
  final String value;
  final Function(String)? onTap;

  const ChangeConditionDrawerNumber(
    this.numbers, {
    this.onTap,
    this.value = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Drawer(
      backgroundColor: myColors.tagColor,
      width: 260,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: RowList(
            rowNumber: 3,
            spacing: 10,
            lineSpacing: 10,
            children: numbers.map<Widget>((e) {
              var active = e == value;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (onTap != null) onTap!(e);
                },
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: active ? myColors.primary : myColors.grey1,
                  ),
                  child: Text(
                    e,
                    style: TextStyle(
                      fontSize: 16,
                      color: active ? myColors.white : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

//规则抽屉
class ChangeConditionDrawerRule extends StatelessWidget {
  // final List<String> rules;
  final GUserNumberType value;
  final Function(GUserNumberType)? onTap;

  const ChangeConditionDrawerRule({
    this.onTap,
    this.value = GUserNumberType.NIL,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    List<GUserNumberType> list = [
      GUserNumberType.LEOPARD,
      GUserNumberType.HONORABLE,
      GUserNumberType.SHORT,
      GUserNumberType.STRAIGHT,
      GUserNumberType.EXCELLENT,
      GUserNumberType.OTHER,
    ];
    return Drawer(
      backgroundColor: myColors.tagColor,
      width: 240,
      child: ListView(
        children: list.map((e) {
          return InkWell(
            onTap: () {
              if (onTap != null) onTap!(e);
            },
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: .5,
                    color: myColors.lineGrey,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(goodNumberType2string(e)),
                      if (goodNumberImageString(e) != '')
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Image.asset(
                            assetPath(goodNumberImageString(e)),
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                  if (value == e)
                    Icon(
                      Icons.check,
                      color: myColors.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

//规则抽屉
class StringConditionDrawerRule extends StatelessWidget {
  final List<String> rules;
  final String value;
  final Function(String)? onTap;

  const StringConditionDrawerRule(
    this.rules, {
    this.onTap,
    this.value = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Drawer(
      backgroundColor: myColors.tagColor,
      width: 240,
      child: ListView(
        children: rules.map((e) {
          return InkWell(
            onTap: () {
              if (onTap != null) onTap!(e);
            },
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: .5,
                    color: myColors.lineGrey,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e),
                  if (value == e)
                    Icon(
                      Icons.check,
                      color: myColors.primary,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
