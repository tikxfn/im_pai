import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/git_hash.dart';
import 'package:unionchat/widgets/update_version_dialog.dart';
import 'package:openapi/api.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({Key? key}) : super(key: key);
  static const String path = 'aboutApp/page';

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  GAppVersionModel? _version;
  bool _forceUpdate = false;
  bool _newVersion = false;

  //获取版本号
  _getVersion() async {
    try {
      await Global.getSystemInfo();
      if (!mounted || Global.systemInfo.appVersion == null) return;
      _version = Global.systemInfo.appVersion?.appVersion;
      var version = _version?.version ?? '';
      if (Platform.isIOS) {
        version = _version?.iosVersion ?? '';
      }
      _forceUpdate = toBool(_version?.isForceUpdate);
      if (version.isEmpty) return;
      _newVersion =
          version2int(version) > version2int(Global.versionInfo.appVersion);
      setState(() {});
    } catch (e) {
      logger.d(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: myColors.white,
      appBar: AppBar(
        title: Text('关于我们'.tr()),
      ),
      body: ThemeBody(child: createBody()),
    );
  }

  Widget createBody() {
    var myColors = ThemeNotifier();
    return ListView(
      children: [
        shadowBox(
          child: MenuUl(
            bottomBoder: true,
            marginTop: 0,
            children: [
              MenuItemData(
                onTap: () {
                  // Navigator.pushNamed(context, SettingPrivacy.path);
                  launchUrl(Uri.parse('http://www.lvdunhb.com/privacy'));
                },
                title: '隐私条款'.tr(),
              ),
              MenuItemData(
                onTap: () {
                  launchUrl(Uri.parse('http://www.lvdunhb.com/protocol'));
                  // Navigator.pushNamed(context, SettingProtocol.path);
                },
                title: '用户协议'.tr(),
              ),
              MenuItemData(
                onTap: () {
                  if (!_newVersion) {
                    tip('当前已是最新版本'.tr());
                    return;
                  }
                  showDialog(
                    barrierDismissible: !_forceUpdate,
                    context: context,
                    builder: (context) {
                      return UpdateVersionDialog(
                        _version!,
                        _forceUpdate,
                      );
                    },
                  );
                },
                title: '当前版本: v'.tr(args: [
                  '${Global.versionInfo.appVersion}(${gitHash.substring(0, 7)})'
                ]),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_newVersion)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        decoration: BoxDecoration(
                            color: myColors.red,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '新版本'.tr(),
                          style: TextStyle(
                            fontSize: 10,
                            color: myColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (apiEnv.name == 'dev')
          Container(
            padding: const EdgeInsets.all(10),
            child: Text('测试环境：${apiUrl()}'),
          )
      ],
    );
  }

  Widget createItem(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
        Expanded(child: Container()),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  //阴影盒子
  Widget shadowBox({required Widget child}) {
    var myColors = ThemeNotifier();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: myColors.themeBackgroundColor,
        ),
        child: child,
      ),
    );
  }
}
