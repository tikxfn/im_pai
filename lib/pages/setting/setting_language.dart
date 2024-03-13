import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class SettingLanguage extends StatefulWidget {
  const SettingLanguage({super.key});

  static const String path = 'setting/language';

  @override
  State<StatefulWidget> createState() => _SettingLanguageState();
}

class _SettingLanguageState extends State<SettingLanguage> {
  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    Color primary = myColors.primary;
    var support = context.supportedLocales;
    return Scaffold(
      appBar: AppBar(
        title: Text('切换语言'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: support.map((e) {
            var str = '';
            switch (e.languageCode) {
              case 'zh':
                str = '中文';
                break;
              case 'en':
                str = 'English';
                break;
            }
            var active = e.languageCode == context.locale.languageCode;
            return InkWell(
              onTap: () {
                context.setLocale(e);
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: myColors.lineGrey,
                      width: .5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      str,
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    if (active)
                      Icon(
                        Icons.check,
                        color: primary,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
