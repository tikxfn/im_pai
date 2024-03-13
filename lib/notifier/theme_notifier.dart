import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/box/box.dart';

import '../common/func.dart';

enum ThemeType {
  light,
  dark,
}

extension ThemeTypeExtension on ThemeType {
  String get toChar {
    switch (this) {
      case ThemeType.light:
        return 'light';
      case ThemeType.dark:
        return 'dark';
    }
  }

  static ThemeType toTheme(String t) {
    for (var v in ThemeType.values) {
      if (t == v.toChar) return v;
    }
    return ThemeType.light;
  }
}

class ThemeNotifier with ChangeNotifier {
  static ThemeNotifier? _instance;

  factory ThemeNotifier() {
    return _instance ??= ThemeNotifier._internal();
  }

  ThemeNotifier._internal();

  ThemeType _theme = ThemeType.light;
  ThemeType get theme => _theme;
  bool get isDark => _theme == ThemeType.dark;

  //载入主题
  Future<void> loadTheme() async {
    var t = settingsBox.get('theme') ?? 'light';
    _theme = ThemeTypeExtension.toTheme(t);
  }

  // 设置主题
  Future<void> setTheme(ThemeType t) async {
    await settingsBox.put('theme', t.toChar);
    _theme = t;
    notifyListeners();
  }

  //主题样式
  ThemeData getTheme() {
    return ThemeData(
      fontFamily: platformPhone ? '' : 'SourceHanSansCN',
      primarySwatch: generateMaterialColor(im2CircleTitlebg),
      scaffoldBackgroundColor: platformPhone ? themeBackground : winBackground,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        // backgroundColor: myColors.white,
        backgroundColor: platformPhone ? themeBackground : winBackground,
        iconTheme: IconThemeData(
          color: iconThemeColor,
        ),
        titleTextStyle: TextStyle(
          color: iconThemeColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        systemOverlayStyle: systemUiOverlayStyle,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: iconThemeColor, //输入框光标颜色
        // selectionColor: myColors.goldColor,
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          color: iconThemeColor,
          fontSize: 16,
        ),
        subtitleTextStyle: TextStyle(
          color: iconThemeColor,
        ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(
          fontSize: 14,
          color: iconThemeColor,
        ),
      ),
      // fontFamily: ,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: textGrey,
          fontSize: 14,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStatePropertyAll(
            TextStyle(
              color: blueTitle,
            ),
          ),
        ),
      ),
    );
  }

  Color get primary {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFF046bf2);
      case ThemeType.dark:
        return const Color.fromARGB(255, 65, 157, 233);
    }
  }

  //主题含有透明图片，透明色
  Color get themeBackground {
    switch (_theme) {
      case ThemeType.light:
        return Colors.transparent;
      case ThemeType.dark:
        return const Color(0xFF292929);
      // return const Color(0xFF333333);
    }
  }

  //主题背景色
  Color get themeBackgroundColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFFFFFFFF);
      case ThemeType.dark:
        return const Color(0xFF292929);
      // return const Color(0xFF333333);
    }
  }

  //win主题背景
  Color get winBackground {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFFFFFFFF);
      case ThemeType.dark:
        return const Color(0xFF333333);
    }
  }

  //tab页appbar 顶部文字、icon颜色
  Color get tabAppbarTitle => const Color(0xFFFFFFFF);

  //文字、icons、输入光标颜色
  Color get iconThemeColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFF333333);
      case ThemeType.dark:
        return const Color(0xFFd0d0d0);
    }
  }

  //预选，置顶色
  Color get winPreselectionColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color.fromARGB(255, 250, 250, 250);
      case ThemeType.dark:
        return const Color(0xFF4b4b4b);
      // return const Color.fromARGB(255, 82, 81, 81);
    }
  }

  //popup背景颜色
  Color get popupThemeColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFFFFFFFF);
      case ThemeType.dark:
        return const Color(0xFFB4B4B4);
    }
  }

  //字母tag列表
  Color get tagColor {
    switch (_theme) {
      case ThemeType.light:
        // return grey;
        return const Color(0xFFF8F9FA);
      case ThemeType.dark:
        return const Color(0xFF343434);
      //   return const Color.fromARGB(255, 82, 81, 81);
    }
  }

  //mine_box列表
  Color get mineBoxColor {
    switch (_theme) {
      case ThemeType.light:
        // return const Color(0xFFFFFFFF);
        return const Color(0xFFFAFAFA);
      case ThemeType.dark:
        return const Color(0xFF4b4b4b);
      // return const Color.fromARGB(255, 109, 106, 106);
    }
  }

  //chat_input
  Color get chatInputColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFFf8f9fa);
      case ThemeType.dark:
        return const Color(0xFF4b4b4b);
      // return const Color.fromARGB(255, 66, 65, 65);
    }
  }

  //chat_input_boder
  Color get chatInputBoderColor {
    switch (_theme) {
      case ThemeType.light:
        return const Color(0xFFEDEDED);
      case ThemeType.dark:
        return const Color(0xFF4b4b4b);
    }
  }

  //阴影颜色
  Color get readBg {
    switch (_theme) {
      case ThemeType.light:
        return const Color.fromRGBO(0, 0, 0, .2);
      case ThemeType.dark:
        return const Color(0xFF292929);
    }
  }

  SystemUiOverlayStyle get systemUiOverlayStyle {
    switch (_theme) {
      case ThemeType.light:
        return const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF000000),
          systemNavigationBarDividerColor: null,
          statusBarColor: null,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        );
      case ThemeType.dark:
        return const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF000000),
          systemNavigationBarDividerColor: null,
          statusBarColor: null,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        );
    }
  }

  //  ************************************************************************
  //背景渐变色
  Color get bgStart => const Color(0xFFe0edfd);

  Color get bgEnd => const Color(0xFFe3fdfb);

  //tab底部按钮颜色
  Color get bottom => const Color(0xFFFFFFFF);

  Color get bottomShadow => const Color(0x241761AD);

  Color get bootmText => const Color(0xFFa9a9a9);

  Color get bootmTextSelect => const Color(0xFF6f6f6f);

  //聊天
  Color get blueTitle => const Color(0xFF046bf2);

  Color get subIconThemeColor => const Color(0xFF999999);

  Color get redTitle => const Color(0xFFF20A49);

  Color get accountTagBg => const Color(0xFFF0F4F6);

  Color get accountTagTitle => const Color(0xFF666666);

  Color get greenButtonBg => const Color(0xFF16CE7E);

  //圈子

  Color get circleTagBg => const Color(0xFFe8f6fb);

  Color get circleTagTitle => const Color(0xFF1CA8DC);

  Color get circleBorder => const Color(0xFFf2f6fa);

  Color get circleLocationTagBg => const Color(0xFF046BF2);

  Color get circleBlue0ButtonBg => const Color(0xFFedf4fe);

  Color get circleBlueButtonBg => const Color(0xFF1977F3);

  Color get circleSelectCircleTagTitle => const Color(0xFF1CA8DC);

  Color get circleSelectCircleTagbg => const Color(0xFFe8f6fb);

  Color get circleSelectCityTagbg => const Color(0xFFf2f6fa);

  Color get redButtonBg => const Color(0xFFFF2C27);

  Color get circlyTypePrivateBg => const Color(0xFFFFA800);

  Color get white => const Color(0xFFFFFFFF);

  //透明阴影颜色
  Color get shade => const Color(0xFF000000);
  //公告boder
  Color get noticeBoder => const Color(0xFFCFDFED);

  Color get textBlack => const Color(0xFF333333);

  Color get textGrey => const Color(0xFFB4B4B4);

  Color get liangLogoText => const Color(0xFFe1ba94);
  Color get liangLogoBg => const Color(0xFF3e3a36);

  //坐席点击编辑按钮后，输入框颜色
  Color get chatInputSelectColor => const Color(0xFFdfe0e1);

  //聊天分组列表选择后背景颜色
  Color get listCheckedBg => const Color(0xFFf7f8fa);

  //redPacket红包背景色
  Color get redPacketdBg => const Color(0xFFF10C4F);
  //vipname
  Color get vipName => const Color.fromRGBO(227, 107, 43, 1);

  //vipbuy 界面颜色
  Color get vipBuyTitle => const Color(0xFF8B570E);

  Color get vipBuySubtitle => const Color(0xFFAB7223);

  Color get vipBuySelectedBg => const Color(0xFF1977F3);

  //vipLevel字体颜色
  //普通颜色
  Color get commonText => const Color(0xFF333333);
  Color get commonBubble => const Color(0xFFFFFFFF);

  Color get senderCommonText => const Color(0xFFFFFFFF);
  Color get senderCommonBubble => const Color(0xFF1977F3);

  //vip 1~2
  Color get vipText1 => const Color(0xFFFFFFFF);

  LinearGradient chatBubble1 = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFD615), Color(0xFFE37A24)],
  );
  //vip 3~4
  Color get vipText2 => const Color(0xFF983C21);

  LinearGradient chatBubble2 = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE75921), Color(0xFFEE9728)],
  );
  //vip 5~6
  Color get vipText3 => const Color(0xFFF2AF0D);

  LinearGradient chatBubble3 = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF752800), Color(0xFF270000)],
  );
  //  ************************************************************************

  Color get tagGrey => const Color.fromARGB(255, 82, 81, 81);

  Color get mineBoxDarkGrey => const Color.fromARGB(255, 109, 106, 106);

  Color get inputDarkColor => const Color.fromARGB(255, 66, 65, 65);

  Color get inputDarkBoderColor => const Color.fromARGB(255, 66, 65, 65);

  Color get pageBackground => const Color(0xFFFFFFFF);

  Color get black => const Color(0xFF000000);

  Color get textGrey1 => const Color(0xFF7F7F7F);

  Color get avatarBackground => const Color(0xFFDCDBDB);

  Color get lineGrey => const Color(0xFFDADADA);

  Color get imgGrey => const Color(0xFFF5F6F9);

  Color get grey0 => const Color(0xFFF8F8F8);

  Color get greyBg => const Color(0xFFFAFAFA);

  Color get grey => const Color(0xFFEDEDED);

  Color get grey1 => const Color(0xFFF5F5F5);

  Color get loginText => const Color(0xFF404040);

  Color get grey2 => const Color(0xFFEEEFF4);

  Color get grey3 => const Color(0xFFBABCC2);

  Color get grey4 => const Color(0xFFE8E9ED);

  Color get whiteOpacity => const Color.fromRGBO(255, 255, 255, .3);

  Color get whiteOpacity1 => const Color.fromRGBO(255, 255, 255, .5);

  Color get whiteOpacity2 => const Color.fromRGBO(255, 255, 255, .9);

  Color get linkGrey => const Color(0xFF606B8C);

  Color get blueGrey => const Color(0xFF8791BF);

  Color get voiceBg => const Color.fromRGBO(0, 0, 0, .5);

  Color get callRemindBackground => const Color.fromRGBO(0, 0, 0, .6);

  // Color get red => const Color.fromRGBO(252,77, 83, 1);
  Color get red => const Color.fromRGBO(235, 85, 99, 1);

  Color get green => const Color.fromRGBO(100, 194, 123, 1);

  Color get greenOpacity => const Color.fromRGBO(100, 194, 123, .7);

  Color get yellow => const Color.fromRGBO(197, 166, 130, 1.0);

  Color get yellowBack => const Color.fromRGBO(245, 245, 245, 1.0);

  Color get blueBack => const Color(0xFF3F51B5);

  Color get blueOpacity => const Color.fromRGBO(86, 102, 190, .2);

  Color get blueTarget => const Color.fromRGBO(233, 245, 254, 1);

  Color get vipStart => const Color.fromRGBO(240, 203, 149, 1.0);

  Color get vipEnd => const Color.fromRGBO(245, 238, 229, 1.0);

  Color get vipBg => const Color.fromRGBO(245, 238, 229, .5);

  Color get vipBuySelect => const Color.fromRGBO(253, 230, 199, 1);

  Color get vipBuyNumber => const Color.fromRGBO(138, 83, 9, 1);

  Color get vipBuyExp => const Color.fromRGBO(99, 202, 255, 1);

  Color get vipBuyExpBg => const Color.fromRGBO(245, 252, 255, 1);

  Color get winSelectBg => const Color.fromRGBO(66, 156, 201, 1);

  Color get goldColor => const Color.fromRGBO(240, 203, 149, 1.0);

  //红包消息的颜色
  Color get messagePacketColor => const Color.fromRGBO(255, 152, 43, 1.0);

  Color get secondTextColor => const Color.fromRGBO(178, 178, 178, 1.0);

  Color get backGroundColor => const Color(0xF4F4F4FF);

  Color get launchColor => const Color(0xFF3F51B5);

  Color get drawColor1 => const Color(0xFFF65856);

  Color get drawColor2 => const Color(0xFFF09B4C);

  Color get drawColor3 => const Color(0xFFFAC134);

  Color get drawColor4 => const Color(0xFF98D231);

  Color get drawColor5 => const Color(0xFF49C265);

  Color get drawColor6 => const Color(0xFF43AEFF);

  Color get drawColor7 => const Color(0xFF3885EF);

  Color get drawColor8 => const Color(0xFF6569F3);

  Color get drawColor9 => const Color(0xFF7F7F7F);

  //im
  Color get imGreen0 => const Color.fromRGBO(232, 238, 218, 1);

  Color get imGreen1 => const Color.fromRGBO(164, 191, 108, 1);

  Color get imGreen2 => const Color.fromRGBO(0, 0, 0, 1);

  Color get imGreenBlack => const Color(0xFF1A1F19);

  Color get imGreenWhite => const Color(0xFFE8EEDA);

  Color get imWhite0 => const Color.fromRGBO(246, 246, 246, 1);

  Color get imWhite => const Color.fromRGBO(223, 223, 223, 1);

  Color get imRed => const Color.fromRGBO(244, 31, 82, 1);

  Color get imTextGrey => const Color.fromRGBO(156, 164, 171, 1);

  Color get imTextGrey1 => const Color.fromRGBO(156, 164, 171, 1);

  Color get imTextGrey2 => const Color.fromRGBO(72, 72, 72, 1);

  //登录文字按钮颜色
  Color get im2loginTextButton => const Color.fromRGBO(22, 232, 164, 1);

  //登录输入框背景颜色
  Color get im2inputBox => const Color.fromRGBO(57, 57, 57, 1);

  //退出红按钮主题与文字
  Color get im2redText => const Color.fromRGBO(248, 37, 37, 1);

  Color get im2red => const Color.fromRGBO(247, 192, 192, 1);

  //圈子icon背景
  Color get im2CircleIcon => const Color.fromRGBO(7, 229, 161, 1);

  //圈子icon文字
  Color get im2CircleTitle => const Color.fromRGBO(21, 180, 122, 1);

  Color get im2CircleTitlebg => const Color.fromRGBO(106, 244, 204, 1);

  //动态分割线
  Color get im2Boder => const Color(0xFFEBEBEB);

  //圈子申请状态颜色
  Color get im2Apply => const Color(0xFFF1C731);

  Color get im2ApplyBg => const Color(0xFFFFF8DF);

  Color get im2Success => const Color(0xFF2FDDA9);

  Color get im2SuccessBg => const Color(0xFFDEFFF5);

  Color get im2Refuse => const Color(0xFFF97F7F);

  Color get im2LabelBg => const Color.fromRGBO(245, 248, 245, 0.50);

  //群身份背景
  Color get owner => const Color(0xFFFFB22C);

  Color get admin => const Color(0xFF43AEFF);
}
