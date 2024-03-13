import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

//搜索框组件
class GlSearchInput extends StatelessWidget {
  //组件点击
  final Function()? onTap;

  //输入框是否只读
  final bool disabled;

  //输入框提示文字
  final String hint;

  final FocusNode focusNode;

  //组件皮肤
  final SearchInputTheme theme;

  //控制器
  final TextEditingController? controller;

  //是否自动获取焦点
  final bool autofocus;

  //是否显示搜索按钮
  final bool showButton;

  //按钮点击
  final Function()? buttonTap;

  final ValueChanged<String>? onChanged;

  final ValueChanged<String>? onSubmitted;

  const GlSearchInput({
    this.hint = '输入您想搜索的内容',
    this.onTap,
    this.disabled = false,
    this.theme = SearchInputTheme.white,
    this.controller,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    super.key,
    this.showButton = false,
    this.buttonTap,
    required this.focusNode,
  });

  //快速搜索
  // static searchDelay(Function doSomething, {durationTime = 500}) {
  //   timer?.cancel();
  //   timer = Timer(Duration(milliseconds: durationTime), () {
  //     doSomething?.call();
  //     timer = null;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    SearchInputTheme inputTheme =
        myColors.isDark ? SearchInputTheme.grey : SearchInputTheme.white;
    Color textColor = myColors.iconThemeColor;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
              ),
              child: Container(
                height: 34,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: inputTheme.inputBackgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: myColors.textGrey,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      flex: 1,
                      child: disabled
                          ? Text(
                              hint.tr(),
                              style: TextStyle(
                                color: myColors.textGrey,
                              ),
                            )
                          : TextFormField(
                              onEditingComplete: () {},
                              textInputAction: TextInputAction.done,
                              focusNode: focusNode,
                              onChanged: onChanged,
                              controller: controller,
                              autofocus: autofocus,
                              onFieldSubmitted: onSubmitted,
                              style: TextStyle(
                                color: textColor,
                              ),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                hintText: hint.tr(),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showButton)
          TextButton(
            onPressed: buttonTap,
            child: Text(
              '取消'.tr(),
              style: TextStyle(fontSize: 16, color: myColors.primary),
            ),
          ),
      ],
    );
  }
}

//组件皮肤枚举
enum SearchInputTheme {
  white,
  grey,
}

extension GlSearchInputThemeExt on SearchInputTheme {
  //盒子背景颜色
  Color get backgroundColor {
    switch (this) {
      case SearchInputTheme.white:
        return Colors.transparent;
      case SearchInputTheme.grey:
        return ThemeNotifier().grey1;
    }
  }

  //输入框背景颜色
  Color get inputBackgroundColor {
    var myColors = ThemeNotifier();
    switch (this) {
      case SearchInputTheme.white:
        return myColors.grey1;
      case SearchInputTheme.grey:
        return myColors.textGrey1;
    }
  }
}
