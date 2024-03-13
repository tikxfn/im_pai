import 'package:badges/badges.dart' as badges;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/unread_value.dart';
import 'package:unionchat/pages/application/html.dart';
import 'package:unionchat/pages/community/community_home.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/tab_bottom_height.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class ApplicationHome extends StatefulWidget {
  const ApplicationHome({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ApplicationHomeState();
  }
}

class _ApplicationHomeState extends State<ApplicationHome> {
  static List<GDiscoveryPageModel> home = [];

  //获取发现页
  getHome() async {
    await Global.getSystemInfo();
    home = Global.systemInfo.discoveryPage?.discoveryPage ?? [];
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getHome();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color bgColor = myColors.themeBackgroundColor;
    Color textColor = myColors.iconThemeColor;
    return ThemeImage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            '发现'.tr(),
            style: TextStyle(
              color: myColors.iconThemeColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
        ),
        body: Container(
          // margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder(
                valueListenable: UnreadValue.communityNotRead,
                builder: (context, communityNotRead, _) {
                  return ValueListenableBuilder(
                    valueListenable: UnreadValue.newTrendsNotRead,
                    builder: (context, newTrendsNotRead, _) {
                      final int notRead = communityNotRead + newTrendsNotRead;
                      return inkWellButton(
                        () {
                          Adapter.navigatorTo(CommunityHome.path);
                        },
                        myColors,
                        '朋友圈'.tr(),
                        bgColor: bgColor,
                        titleColor: textColor,
                        assetImg: assetPath('images/help/pengyouquan.png'),
                        notRead: notRead,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              // if (FunctionConfig.circle)
              //   Padding(
              //     padding: const EdgeInsets.only(bottom: 10),
              //     child: inkWellButton(
              //       () {
              //         Adapter.navigatorTo(HelpHome.path);
              //       },
              //       '圈子广场'.tr(),
              //       //im2
              //       assetImg: assetPath('images/help/btn_quanziguangchang.png'),
              //       notRead: circleNotRead,
              //     ),
              //   ),
              // inkWellButton(
              //   () {
              //     // DatabaseOperator.saveSetting(key, value)
              //   },
              //   '福利中心',
              //   assetImg: assetPath('images/help/sp_fulizhongxin.png'),
              // ),
              for (var v in home)
                inkWellButton(
                  () {
                    // launchUrl(
                    //   Uri.parse(v.link ?? ''),
                    //   mode: LaunchMode.externalApplication,
                    // );
                    Navigator.push(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) {
                          return HtmlPage(
                            url: v.link,
                          );
                        },
                      ),
                    );
                  },
                  myColors,
                  v.name!,
                  bgColor: bgColor,
                  titleColor: textColor,
                  networkImg: v.icon,
                ),
              const TabBottomHeight(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget inkWellButton(
  Function() onTap,
  ThemeNotifier myColors,
  String title, {
  int notRead = 0,
  assetImg,
  networkImg,
  Color? bgColor,
  Color? titleColor,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      color: bgColor,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          if (assetImg != null)
            SizedBox(
                width: 25,
                height: 25,
                child: Image.asset(
                  assetImg,
                  width: 21,
                  height: 21,
                  fit: BoxFit.contain,
                )),
          if (networkImg != null)
            SizedBox(
              width: 25,
              height: 25,
              child: AppNetworkImage(
                networkImg,
                width: 21,
                height: 21,
                fit: BoxFit.cover,
                imageSpecification: ImageSpecification.w120,
              ),
            ),
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.topRight,
              child: badges.Badge(
                showBadge: notRead > 0,
                badgeContent: Text(
                  ' ',
                  style: TextStyle(
                    color: myColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 15,
              color: myColors.lineGrey,
            ),
          ),
        ],
      ),
    ),
  );
}
