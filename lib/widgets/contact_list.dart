import 'package:azlistview_plus/azlistview_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../notifier/theme_notifier.dart';

class ContractData extends ISuspensionBean {
  final Widget widget;
  final String name; //排序name
  String? tagIndex; //分组
  String? namePinyin;

  ContractData({
    required this.widget,
    required this.name,
    this.tagIndex = '',
    this.namePinyin,
  });

  @override
  String getSuspensionTag() => tagIndex!;
}

class ContactList extends StatefulWidget {
  //不用排序的字段
  final List<List<ContractData>> list;

  //需要排序的字段
  final List<ContractData> orderList;

  //是否显示总数
  final bool showCount;

  //朋友总个数
  final String count;

  // 是否跳转第一个
  final bool jumpFirst;

  final Widget? top;

  const ContactList({
    super.key,
    required this.list,
    required this.orderList,
    this.jumpFirst = false,
    this.count = '0',
    this.showCount = false,
    this.top,
  });

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<ContractData> listData = [];
  final ItemScrollController str = ItemScrollController();

  @override
  void initState() {
    super.initState();
    // _handleList(widget.orderList, widget.list);
    // if (mounted) {
    //   setState(() {});
    // }
  }

  //跳转到第一个
  jump() {
    if (mounted) {
      if (listData.isNotEmpty) str.jumpTo(index: 0);
    }
  }

  void _handleList(
    List<ContractData> orderList,
    List<List<ContractData>> list,
  ) {
    for (int i = 0, length = orderList.length; i < length; i++) {
      String pinyin = PinyinHelper.getPinyinE(orderList[i].name);
      if (pinyin.isEmpty) {
        orderList[i].tagIndex = '#';
        continue;
      }
      String tag = pinyin.substring(0, 1).toUpperCase();
      orderList[i].namePinyin = pinyin;
      if (RegExp('[A-Z]').hasMatch(tag)) {
        orderList[i].tagIndex = tag;
      } else {
        orderList[i].tagIndex = '#';
      }
    }

    // A-Z sort. a到z排序
    SuspensionUtil.sortListBySuspensionTag(orderList);

    // 增加星标朋友以及系统预设列.
    for (int i = list.length - 1; i >= 0; i--) {
      orderList.insertAll(0, list[i]);
    }

    // show sus tag.显示分类字母
    SuspensionUtil.setShowSuspensionStatus(orderList);

    setState(() {
      listData = orderList;
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    var myColors = ThemeNotifier();

    if (widget.jumpFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        //跳转第一个
        jump();
      });
    }

    _handleList(widget.orderList, widget.list);
    //获取索引标记
    List<String> tagIndexList = SuspensionUtil.getTagIndexList(listData);

    List<ContractData> dataList = listData;
    return AzListView(
      itemScrollController: str,

      data: dataList,
      itemCount: dataList.length,
      itemBuilder: (BuildContext context, int index) {
        ContractData model = dataList[index];
        String tag = model.getSuspensionTag();
        bool show = false;
        if (dataList.length - 1 == index && dataList.isNotEmpty) show = true;
        return Utils.getListItem(context, model, tag,
            showCount: show && widget.showCount, count: widget.count);
      },
      // padding: EdgeInsets.zero,
      //悬挂表头字母
      susItemBuilder: (BuildContext context, int index) {
        ContractData model = dataList[index];
        String tag = model.getSuspensionTag();
        return Utils.getSusItem(context, tag);
      },
      //右侧栏高度
      indexBarItemHeight: 15,
      indexBarOptions: IndexBarOptions(
        textStyle: TextStyle(
          color: myColors.subIconThemeColor,
          fontSize: 12,
        ),
      ),
      //添加右侧星标
      // indexBarData: [for (var index in tagIndexList) index, ...kIndexBarData],
      indexBarData: [
        for (var index in tagIndexList) index,
      ],
    );
  }
}

//构建列表
class Utils {
  //星标朋友字母标题列表
  static Widget getSusItem(BuildContext context, String tag,
      {double susHeight = 20}) {
    if (tag == '★') {
      tag = '★ 星标朋友';
    }
    if (tag == '∧') {
      tag = '系统';
      return Container();
    }
    return Container(
      height: susHeight,
      width: MediaQuery.of(context).size.width,
      color: ThemeNotifier().themeBackgroundColor,
      padding: const EdgeInsets.only(left: 23.5),
      alignment: Alignment.centerLeft,
      child: Text(
        tag,
        softWrap: false,
        style: TextStyle(
          fontSize: 15,
          color: ThemeNotifier().iconThemeColor,
        ),
      ),
    );
  }

  //通讯录列表
  static Widget getListItem(
      BuildContext context, ContractData model, String tag,
      {double susHeight = 30, bool showCount = false, String count = ''}) {
    var myColors = context.watch<ThemeNotifier>();
    return Column(
      children: [
        model.widget,
        if (showCount)
          Column(
            children: [
              Container(
                alignment: Alignment.center,
                // margin: const EdgeInsets.only(bottom: 70),
                height: 48,
                child: Text(
                  '个朋友'.tr(args: [count]),
                  style: TextStyle(
                    color: myColors.textGrey1,
                  ),
                ),
              ),
              // const TabBottomHeight(),
            ],
          ),
      ],
    );
  }
}
