import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

//菜单组件
class MenuUl extends StatelessWidget {
  //组件数据列表
  final List<MenuItemData> children;
  //子组件底部boder
  final bool bottomBoder;
  final double marginTop;
  final double marginBottom;
  final double leftPadding;
  final double lineSpacing;
  //盒子背景颜色
  final Color? boxColor;
  //按钮背景颜色
  final Color? buttonColor;
  final FontWeight fontWeight;

  const MenuUl({
    required this.children,
    this.bottomBoder = false,
    this.marginTop = 10,
    this.marginBottom = 0,
    this.leftPadding = 16,
    this.lineSpacing = 0,
    this.boxColor,
    this.buttonColor,
    this.fontWeight = FontWeight.normal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color textColor = myColors.iconThemeColor;

    return Container(
      padding: EdgeInsets.only(top: marginTop, bottom: marginBottom),
      decoration: BoxDecoration(
        color: boxColor ?? myColors.circleBorder,
        // border: Border(
        //   top: BorderSide(
        //     color: myColors.lineGrey,
        //     width: .5,
        //   ),
        //   bottom: BorderSide(
        //     color: myColors.lineGrey,
        //     width: .5,
        //   ),
        // ),
      ),
      child: Material(
        color: buttonColor ?? bgColor,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++)
              Container(
                padding: EdgeInsets.only(bottom: lineSpacing),
                child: InkWell(
                  onTap: children[i].onTap,
                  child: Row(
                    children: [
                      if (children[i].icon.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(left: leftPadding),
                          child: Image.asset(
                            children[i].icon,
                            color: children[i].needColor ? textColor : null,
                            width: children[i].iconSize,
                            height: children[i].iconSize,
                          ),
                        ),
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 50,
                          ),
                          margin: EdgeInsets.only(left: leftPadding),
                          padding: EdgeInsets.only(
                            right: leftPadding,
                            top: 10,
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            border: bottomBoder && i != children.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: myColors.circleBorder,
                                      width: .5,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      children[i].title,
                                      style: TextStyle(
                                        color:
                                            children[i].titleColor ?? textColor,
                                        fontSize: children[i].titleSize,
                                        fontWeight: fontWeight,
                                      ),
                                    ),
                                    if (children[i].subtitle.isNotEmpty)
                                      Text(
                                        children[i].subtitle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: children[i].subtitleSize,
                                          color: myColors.textGrey,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.only(left: leftPadding),
                                  alignment: Alignment.centerRight,
                                  child: children[i].content != null
                                      ? children[i].content!
                                      : Container(),
                                ),
                              ),
                              if (children[i].notReadNumber > 0)
                                badges.Badge(
                                  badgeContent: Text(
                                    '${children[i].notReadNumber}',
                                    style: TextStyle(
                                      color: myColors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              if (children[i].arrow)
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: myColors.lineGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

//菜单组件列表数据
class MenuItemData {
  //图标
  final String icon;
  //当黑色主题时需要改变图标颜色
  final bool needColor;

  //标题
  final String title;

  //标题大小
  final double titleSize;

  //标题颜色
  final Color? titleColor;

  //二级标题
  final String subtitle;

  //二级标题大小
  final double subtitleSize;

  //内容组件
  final Widget? content;

  //点击
  final Function()? onTap;

  //未读数量
  int notReadNumber;

  //是否显示右侧箭头
  final bool arrow;
  final double iconSize;

  MenuItemData({
    required this.title,
    this.titleSize = 16,
    this.needColor = false,
    this.icon = '',
    this.subtitle = '',
    this.subtitleSize = 14,
    this.content,
    this.onTap,
    this.arrow = true,
    this.titleColor,
    this.notReadNumber = 0,
    this.iconSize = 20,
  });
}

TextStyle menuItemGreyTextStyle = TextStyle(
  color: ThemeNotifier().textGrey,
);
