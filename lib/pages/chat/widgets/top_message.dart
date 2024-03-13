import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:openapi/api.dart';

import '../../../notifier/theme_notifier.dart';

class TopMessageWidget extends StatefulWidget {
  final List<Message> list;
  final bool manage;
  final Function(Message)? onRemove;
  final Function(Message)? onItemTap;

  const TopMessageWidget({
    super.key,
    required this.list,
    this.manage = false,
    this.onRemove,
    this.onItemTap,
  });

  @override
  State<StatefulWidget> createState() {
    return _TopMessageWidgetState();
  }
}

class _TopMessageWidgetState extends State<TopMessageWidget> {
  double padding = 7;
  bool showList = false;

  //移除
  remove(Message v) {
    if (widget.onRemove != null) {
      widget.onRemove!(v);
    }
  }

  //消息点击
  itemTap(Message v, int length) {
    if (!showList && length > 1) {
      setState(() {
        showList = true;
      });
      return;
    }
    if (widget.onItemTap != null) {
      widget.onItemTap!(v);
    }
    setState(() {
      showList = false;
    });
  }

  //列表组件
  Widget _item(Message v, int length) {
    var myColors = ThemeNotifier();
    double height = 40;
    double itemPadding = 10;
    var content = v.content;
    if (v.type != GMessageType.TEXT) {
      content = messageType2text(v.type);
    }
    return GestureDetector(
      onTap: () => itemTap(v, length),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(top: padding),
        width: double.infinity,
        padding: EdgeInsets.only(left: itemPadding),
        height: height,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: myColors.grey1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '${v.senderUser?.nickname ?? ''}：${(content ?? '').trim().replaceAll('\n', '')}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
            if (widget.manage)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => remove(v),
                child: Container(
                  height: height,
                  padding: EdgeInsets.symmetric(horizontal: itemPadding),
                  alignment: Alignment.center,
                  child: Text(
                    '移除',
                    style: TextStyle(
                      color: myColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    var list = widget.list;
    if (list.isEmpty) return Container();
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        if (showList)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              setState(() {
                showList = false;
              });
            },
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: myColors.voiceBg,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
          decoration: BoxDecoration(
            color: myColors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < list.length; i++)
                        if (showList || i == 0) _item(list[i], list.length),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
