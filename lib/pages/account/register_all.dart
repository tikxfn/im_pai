import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/pages/account/phone_register.dart';
import 'package:unionchat/pages/account/register.dart';
import 'package:unionchat/pages/setting/setting_language.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class RegisterAll extends StatefulWidget {
  const RegisterAll({super.key});

  static const String path = 'account/register_all';

  @override
  State<StatefulWidget> createState() {
    return _RegisterAllState();
  }
}

class _RegisterAllState extends State<RegisterAll>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: KeyboardBlur(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage(assetPath('images/login/bg.png')),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: Adapter.isWideScreen ? 500 : 700,
              ),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(45, 70, 45, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          assetPath('images/login/logo.png'),
                          width: 43,
                          height: 43,
                          fit: BoxFit.contain,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 19,
                            bottom: 13,
                          ),
                          child: Text(
                            '欢迎使用「派聊」'.tr(),
                            style: TextStyle(
                              fontSize: 23,
                              color: myColors.iconThemeColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        TabBar(
                            controller: _tabController,
                            indicatorColor: myColors.circleBlueButtonBg,
                            isScrollable: true,
                            // indicator:
                            //     const BoxDecoration(color: Colors.transparent),
                            indicatorWeight: 3.0,
                            labelColor: myColors.iconThemeColor,
                            labelStyle: const TextStyle(
                              height: 1,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            unselectedLabelColor: myColors.textGrey,
                            unselectedLabelStyle:
                                const TextStyle(fontSize: 16, height: 1),
                            tabs: [
                              Tab(
                                text: '邮箱注册'.tr(),
                              ),
                              Tab(
                                text: '手机注册'.tr(),
                              ),
                            ]),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Flexible(
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              Register(),
                              PhoneRegister(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 47),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.pushNamed(context, SettingLanguage.path);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.language,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '语言'.tr().toUpperCase(),
                            style: const TextStyle(),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_outlined,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
