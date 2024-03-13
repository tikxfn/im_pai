import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/func.dart';
import 'button.dart';

class UpdateVersionDialog extends StatelessWidget {
  final GAppVersionModel version;
  final bool forceUpdate;
  const UpdateVersionDialog(this.version, this.forceUpdate, {super.key});

  //立即更新
  goDownloadUrl(GAppVersionModel model) async {
    var url = Platform.isIOS ? model.iosUrl : model.androidUrl;
    if (url == null) return;
    Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 22),
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                color: myColors.grey1,
                image: DecorationImage(
                  image: ExactAssetImage(
                    assetPath('images/my/version_bg.png'),
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 71),
                    child: Text(
                      '发现新版本'.tr(),
                      style: TextStyle(
                          fontSize: 18,
                          color: myColors.textBlack,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text(
                      'v${Platform.isIOS ? version.iosVersion : version.version}',
                      style: TextStyle(
                        fontSize: 18,
                        color: myColors.grey3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6,
                      left: 14,
                      right: 14,
                    ),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '更新内容:'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          color: myColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 14,
                      right: 14,
                    ),
                    child: Container(
                      alignment: Alignment.topLeft,
                      height: 110,
                      child: ListView(
                        children: [
                          Text.rich(
                            TextSpan(
                              text: version.mark ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: myColors.grey3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25,
                      left: 13,
                      right: 13,
                      bottom: 10,
                    ),
                    child: CircleButton(
                      onTap: () {
                        goDownloadUrl(version);
                        if (!forceUpdate) Navigator.pop(context);
                      },
                      title: '立即更新'.tr(),
                      height: 40,
                      fontSize: 16,
                      radius: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 122,
            height: 86,
            alignment: Alignment.center,
            child: Image.asset(
              assetPath('images/my/sp_shenjitubiao.png'),
              fit: BoxFit.contain,
            ),
          ),
          if (!forceUpdate)
            Positioned(
              right: 0,
              top: 22,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  // color: myColors.yellow,
                  alignment: Alignment.center,
                  child: Image.asset(
                    assetPath('images/my/btn_guanbi.png'),
                    width: 15,
                    height: 15,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
