import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

//搜索框组件
class SearchInput extends StatelessWidget {
  //组件点击
  final Function()? onTap;

  //输入框是否只读
  final bool disabled;

  //输入框提示文字
  final String hint;

  //搜索按钮或者取消按钮的文本
  final String sureStr;
//搜索按钮或者取消按钮的文本颜色
  final Color? sureStrColor;

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

  final EdgeInsetsGeometry? padding;
  final double radius;
  final double height;
  final Color? bgColor;
  final Color? inputColor;

  const SearchInput({
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
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    this.sureStr = '搜索',
    this.sureStrColor,
    this.radius = 23,
    this.height = 45,
    this.bgColor,
    this.inputColor,
  });

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
              padding: padding,
              decoration: BoxDecoration(
                color: bgColor ?? theme.backgroundColor,
              ),
              child: Container(
                height: height,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: inputColor ?? inputTheme.inputBackgroundColor,
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      assetPath('images/search_icon.png'),
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 14),
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
                              onChanged: onChanged,
                              controller: controller,
                              autofocus: autofocus,
                              onFieldSubmitted: onSubmitted,
                              style: TextStyle(
                                color: textColor,
                              ),
                              textInputAction: TextInputAction.search,
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
              sureStr.tr(),
              style: TextStyle(
                color: sureStrColor,
              ),
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

extension SearchInputThemeExt on SearchInputTheme {
  //盒子背景颜色
  Color get backgroundColor {
    switch (this) {
      case SearchInputTheme.white:
        // return myColors.white;
        return Colors.transparent;
      case SearchInputTheme.grey:
        return ThemeNotifier().themeBackgroundColor;
    }
  }

  //输入框背景颜色
  Color get inputBackgroundColor {
    switch (this) {
      case SearchInputTheme.white:
        // return myColors.imWhite0;
        return ThemeNotifier().grey0;
      case SearchInputTheme.grey:
        return ThemeNotifier().chatInputColor;
    }
  }
}
