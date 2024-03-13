import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

import 'form_widget.dart';

class UndoDialog extends StatefulWidget {
  final Function(bool)? onEnter;
  final bool showUndo;
  final String tip;

  const UndoDialog({
    this.showUndo = true,
    this.onEnter,
    this.tip = '',
    super.key,
  });

  @override
  State<UndoDialog> createState() => _UndoDialogState();
}

class _UndoDialogState extends State<UndoDialog> {
  bool undo = false;

  //删除弹窗按钮
  Widget removeDialogBtn({
    required String text,
    Function()? onTap,
    Color? color,
  }) {
    var myColors = ThemeNotifier();
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color ?? myColors.textGrey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      decoration: BoxDecoration(
        color: myColors.themeBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '确定要清空聊天记录？'.tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: myColors.textGrey,
                ),
              ),
              if (widget.tip.isNotEmpty)
                Text(
                  widget.tip,
                  style: TextStyle(
                    fontSize: 11,
                    color: myColors.red,
                  ),
                ),
              if (widget.showUndo)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      undo = !undo;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppCheckbox(
                          value: undo,
                          size: 15,
                          paddingRight: 5,
                        ),
                        Text(
                          '双向清空'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: myColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                height: widget.showUndo ? 5 : 0,
                color: myColors.tagColor,
              ),
              removeDialogBtn(
                text: '确定'.tr(),
                color: myColors.red,
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onEnter != null) widget.onEnter!(undo);
                },
              ),
              removeDialogBtn(
                text: '取消'.tr(),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
